import 'dart:convert';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';

import 'crypto_engine.dart';
import 'legacy_crypto.dart';

/// Progress report emitted during v1-to-v2 migration.
class MigrationProgress {
  final int current;
  final int total;
  final String? currentItemName;
  final List<MigrationError> errors;
  final List<MigratedItem> migratedItems;
  final int skipped;

  const MigrationProgress({
    this.current = 0,
    this.total = 0,
    this.currentItemName,
    this.errors = const [],
    this.migratedItems = const [],
    this.skipped = 0,
  });

  /// Returns progress as a fraction from 0.0 to 1.0.
  /// Returns 1.0 if there are no items to migrate (empty vault).
  double get percent => total == 0 ? 1.0 : current / total;

  MigrationProgress copyWith({
    int? current,
    int? total,
    String? currentItemName,
    List<MigrationError>? errors,
    List<MigratedItem>? migratedItems,
    int? skipped,
  }) {
    return MigrationProgress(
      current: current ?? this.current,
      total: total ?? this.total,
      currentItemName: currentItemName ?? this.currentItemName,
      errors: errors ?? this.errors,
      migratedItems: migratedItems ?? this.migratedItems,
      skipped: skipped ?? this.skipped,
    );
  }
}

/// Records a migration failure for a single item.
class MigrationError {
  final String itemId;
  final String error;

  const MigrationError({required this.itemId, required this.error});
}

/// Records a successfully migrated item with its new v2 blob.
class MigratedItem {
  final String itemId;
  final Uint8List v2EncryptedData;

  const MigratedItem({required this.itemId, required this.v2EncryptedData});
}

/// Minimal interface for vault items used during migration.
/// Decouples migration logic from Drift-generated classes.
class MockVaultItem {
  final String id;
  final String vaultId;
  final Uint8List encryptedData;
  final int encryptionVersion;
  final String type;
  final bool favorite;
  final String folder;

  const MockVaultItem({
    required this.id,
    required this.vaultId,
    required this.encryptedData,
    required this.encryptionVersion,
    this.type = 'password',
    this.favorite = false,
    this.folder = '',
  });
}

/// Orchestrates v1 (PBKDF2+AES-CBC) to v2 (Argon2id+AES-256-GCM) migration.
///
/// Per D-12, D-13: Migration is per-item transactional. If one item fails,
/// remaining items are still processed (no abort-all). Failed items retain
/// their v1 format and can be retried later.
///
/// Per D-11: After migration, ALL metadata (name, url, type, favorite, folder,
/// notes) is encrypted inside the v2 blob. Previously, type/favorite/folder
/// were stored as plaintext on the PocketBase record.
class CryptoMigration {
  final LegacyCrypto _legacyCrypto;
  final CryptoEngine _cryptoEngine;

  CryptoMigration({
    required LegacyCrypto legacyCrypto,
    required CryptoEngine cryptoEngine,
  })  : _legacyCrypto = legacyCrypto,
        _cryptoEngine = cryptoEngine;

  /// Check if any items in the list need v1-to-v2 migration.
  static bool needsMigration(List<MockVaultItem> items) {
    return items.any((item) => item.encryptionVersion == 1);
  }

  /// Migrate a single item's encrypted data from v1 to v2 format.
  ///
  /// 1. Decrypts the v1 "iv_base64:ciphertext_base64" string with LegacyCrypto
  /// 2. Parses the decrypted JSON to a field map
  /// 3. Merges in plaintext metadata (type, favorite, folder) per D-11
  /// 4. Re-encrypts all fields with CryptoEngine as v2 binary blob
  ///
  /// [v1EncryptedString] is the v1 format string "iv_base64:ciphertext_base64"
  /// [plaintextMetadata] contains type, favorite, folder that were stored
  /// as plaintext in v1 and must now be encrypted in the v2 blob.
  Future<Uint8List> migrateItemData({
    required String v1EncryptedString,
    required SecretKey v1Key,
    required SecretKey v2Key,
    Map<String, dynamic> plaintextMetadata = const {},
  }) async {
    // Step 1: Decrypt v1 data
    final decryptedJson =
        await _legacyCrypto.decrypt(v1EncryptedString, v1Key);

    // Step 2: Parse JSON to field map
    final fields = jsonDecode(decryptedJson) as Map<String, dynamic>;

    // Step 3: Merge in previously-plaintext metadata (D-11)
    // Plaintext metadata takes precedence only if not already in fields
    for (final entry in plaintextMetadata.entries) {
      fields.putIfAbsent(entry.key, () => entry.value);
    }

    // Ensure all required metadata fields exist
    fields.putIfAbsent('type', () => 'password');
    fields.putIfAbsent('favorite', () => false);
    fields.putIfAbsent('folder', () => '');
    fields.putIfAbsent('name', () => '');
    fields.putIfAbsent('url', () => '');
    fields.putIfAbsent('notes', () => '');

    // Step 4: Re-encrypt as v2
    return _cryptoEngine.encryptFields(fields, v2Key);
  }

  /// Migrate all v1 items to v2 format, yielding progress updates.
  ///
  /// Per D-13: If one item fails, remaining items are still processed.
  /// Failed items are recorded in MigrationProgress.errors.
  /// V2 items are skipped (not re-encrypted).
  ///
  /// The caller is responsible for persisting migrated items to the database
  /// using the MigratedItem.v2EncryptedData and updating encryptionVersion.
  Stream<MigrationProgress> migrateAll({
    required List<MockVaultItem> items,
    required SecretKey v1Key,
    required SecretKey v2Key,
  }) async* {
    final total = items.length;
    final errors = <MigrationError>[];
    final migratedItems = <MigratedItem>[];
    var skipped = 0;
    var current = 0;

    for (final item in items) {
      current++;

      // Skip items already at v2
      if (item.encryptionVersion != 1) {
        skipped++;
        yield MigrationProgress(
          current: current,
          total: total,
          errors: List.unmodifiable(errors),
          migratedItems: List.unmodifiable(migratedItems),
          skipped: skipped,
        );
        continue;
      }

      try {
        // Convert blob back to string for v1 format
        final v1String = utf8.decode(item.encryptedData);

        final v2Blob = await migrateItemData(
          v1EncryptedString: v1String,
          v1Key: v1Key,
          v2Key: v2Key,
          plaintextMetadata: {
            'type': item.type,
            'favorite': item.favorite,
            'folder': item.folder,
          },
        );

        migratedItems.add(MigratedItem(
          itemId: item.id,
          v2EncryptedData: v2Blob,
        ));

        // Try to extract name for progress display
        String? itemName;
        try {
          final decrypted = await _cryptoEngine.decryptFields(v2Blob, v2Key);
          itemName = decrypted['name'] as String?;
        } catch (_) {
          // Non-critical: just for display
        }

        yield MigrationProgress(
          current: current,
          total: total,
          currentItemName: itemName,
          errors: List.unmodifiable(errors),
          migratedItems: List.unmodifiable(migratedItems),
          skipped: skipped,
        );
      } catch (e) {
        errors.add(MigrationError(itemId: item.id, error: e.toString()));
        yield MigrationProgress(
          current: current,
          total: total,
          errors: List.unmodifiable(errors),
          migratedItems: List.unmodifiable(migratedItems),
          skipped: skipped,
        );
      }
    }
  }
}
