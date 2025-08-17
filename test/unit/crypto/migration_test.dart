import 'dart:convert';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:citadel_password_manager/core/crypto/crypto_engine.dart';
import 'package:citadel_password_manager/core/crypto/crypto_migration.dart';
import 'package:citadel_password_manager/core/crypto/legacy_crypto.dart';

void main() {
  late LegacyCrypto legacyCrypto;
  late CryptoEngine cryptoEngine;
  late SecretKey v1Key;
  late SecretKey v2Key;

  setUpAll(() async {
    legacyCrypto = LegacyCrypto();
    cryptoEngine = CryptoEngine();

    // Derive test keys
    v1Key = await legacyCrypto.deriveKey('test-master-password', base64.encode([1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16]));
    v2Key = await cryptoEngine.deriveKey('test-master-password', [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16]);
  });

  group('CryptoMigration', () {
    test('migrateItem decrypts v1 blob and re-encrypts as v2', () async {
      // Create a v1 encrypted blob
      final originalFields = {
        'name': 'Test Login',
        'username': 'user@test.com',
        'password': 'secret123',
        'url': 'https://example.com',
        'notes': 'test notes',
      };
      final v1Encrypted = await legacyCrypto.encryptForTesting(
        jsonEncode(originalFields),
        v1Key,
      );

      // Migrate the item
      final migration = CryptoMigration(
        legacyCrypto: legacyCrypto,
        cryptoEngine: cryptoEngine,
      );
      final v2Blob = await migration.migrateItemData(
        v1EncryptedString: v1Encrypted,
        v1Key: v1Key,
        v2Key: v2Key,
        plaintextMetadata: {
          'type': 'password',
          'favorite': true,
          'folder': 'personal',
        },
      );

      // Verify the v2 blob can be decrypted and contains original data
      final decrypted = await cryptoEngine.decryptFields(v2Blob, v2Key);
      expect(decrypted['name'], equals('Test Login'));
      expect(decrypted['username'], equals('user@test.com'));
      expect(decrypted['password'], equals('secret123'));
      expect(decrypted['url'], equals('https://example.com'));
      expect(decrypted['notes'], equals('test notes'));
    });

    test('migrateItem includes previously-plaintext metadata in v2 blob', () async {
      final originalFields = {
        'name': 'Bank Login',
        'username': 'banker',
        'password': 'bankpass',
      };
      final v1Encrypted = await legacyCrypto.encryptForTesting(
        jsonEncode(originalFields),
        v1Key,
      );

      final migration = CryptoMigration(
        legacyCrypto: legacyCrypto,
        cryptoEngine: cryptoEngine,
      );
      final v2Blob = await migration.migrateItemData(
        v1EncryptedString: v1Encrypted,
        v1Key: v1Key,
        v2Key: v2Key,
        plaintextMetadata: {
          'type': 'bankAccount',
          'favorite': false,
          'folder': 'finance',
        },
      );

      // Verify metadata is now inside the encrypted blob
      final decrypted = await cryptoEngine.decryptFields(v2Blob, v2Key);
      expect(decrypted['type'], equals('bankAccount'));
      expect(decrypted['favorite'], equals(false));
      expect(decrypted['folder'], equals('finance'));
    });

    test('migrateAll processes all v1 items and reports progress', () async {
      // Create multiple v1 items
      final items = <MockVaultItem>[];
      for (int i = 0; i < 3; i++) {
        final encrypted = await legacyCrypto.encryptForTesting(
          jsonEncode({'name': 'Item $i', 'username': 'user$i', 'password': 'pass$i'}),
          v1Key,
        );
        items.add(MockVaultItem(
          id: 'item-$i',
          vaultId: 'vault-1',
          encryptedData: utf8.encode(encrypted),
          encryptionVersion: 1,
          type: 'password',
          favorite: false,
          folder: '',
        ));
      }

      final migration = CryptoMigration(
        legacyCrypto: legacyCrypto,
        cryptoEngine: cryptoEngine,
      );

      final progressUpdates = <MigrationProgress>[];
      await for (final progress in migration.migrateAll(
        items: items,
        v1Key: v1Key,
        v2Key: v2Key,
      )) {
        progressUpdates.add(progress);
      }

      // Should have progress updates for each item plus final
      expect(progressUpdates.length, greaterThanOrEqualTo(3));
      expect(progressUpdates.last.current, equals(3));
      expect(progressUpdates.last.total, equals(3));
      expect(progressUpdates.last.errors, isEmpty);
    });

    test('migrateAll continues processing when one item fails', () async {
      final goodEncrypted = await legacyCrypto.encryptForTesting(
        jsonEncode({'name': 'Good Item', 'username': 'user', 'password': 'pass'}),
        v1Key,
      );

      final items = <MockVaultItem>[
        MockVaultItem(
          id: 'good-1',
          vaultId: 'vault-1',
          encryptedData: utf8.encode(goodEncrypted),
          encryptionVersion: 1,
          type: 'password',
          favorite: false,
          folder: '',
        ),
        MockVaultItem(
          id: 'bad-1',
          vaultId: 'vault-1',
          encryptedData: utf8.encode('invalid:data:format'),
          encryptionVersion: 1,
          type: 'password',
          favorite: false,
          folder: '',
        ),
        MockVaultItem(
          id: 'good-2',
          vaultId: 'vault-1',
          encryptedData: utf8.encode(goodEncrypted),
          encryptionVersion: 1,
          type: 'password',
          favorite: false,
          folder: '',
        ),
      ];

      final migration = CryptoMigration(
        legacyCrypto: legacyCrypto,
        cryptoEngine: cryptoEngine,
      );

      final progressUpdates = <MigrationProgress>[];
      await for (final progress in migration.migrateAll(
        items: items,
        v1Key: v1Key,
        v2Key: v2Key,
      )) {
        progressUpdates.add(progress);
      }

      final lastProgress = progressUpdates.last;
      // All 3 were attempted (no abort-all)
      expect(lastProgress.current, equals(3));
      // Exactly one error
      expect(lastProgress.errors.length, equals(1));
      expect(lastProgress.errors.first.itemId, equals('bad-1'));
      // 2 successful migrations
      expect(lastProgress.migratedItems.length, equals(2));
    });

    test('items already at v2 are skipped', () async {
      final v2Blob = await cryptoEngine.encryptFields(
        {'name': 'Already V2', 'username': 'user', 'password': 'pass'},
        v2Key,
      );

      final items = <MockVaultItem>[
        MockVaultItem(
          id: 'v2-item',
          vaultId: 'vault-1',
          encryptedData: v2Blob,
          encryptionVersion: 2,
          type: 'password',
          favorite: false,
          folder: '',
        ),
      ];

      final migration = CryptoMigration(
        legacyCrypto: legacyCrypto,
        cryptoEngine: cryptoEngine,
      );

      final progressUpdates = <MigrationProgress>[];
      await for (final progress in migration.migrateAll(
        items: items,
        v1Key: v1Key,
        v2Key: v2Key,
      )) {
        progressUpdates.add(progress);
      }

      // V2 items should be skipped, not migrated
      expect(progressUpdates.last.migratedItems, isEmpty);
      expect(progressUpdates.last.skipped, equals(1));
    });

    test('v1 format "iv_base64:ciphertext_base64" is correctly identified', () async {
      final v1Encrypted = await legacyCrypto.encryptForTesting(
        jsonEncode({'name': 'test'}),
        v1Key,
      );

      // v1 format should contain a colon
      expect(v1Encrypted.contains(':'), isTrue);

      // v2 format is binary, starts with 0x02
      final v2Blob = await cryptoEngine.encryptFields({'name': 'test'}, v2Key);
      expect(v2Blob[0], equals(0x02));
    });

    test('after migration, decrypting with CryptoEngine produces original plaintext', () async {
      final originalFields = {
        'name': 'My Login',
        'username': 'myuser',
        'password': 'mypass123!@#',
        'url': 'https://secure.example.com',
        'notes': 'Important login with special chars: !@#\$%^&*()',
      };

      final v1Encrypted = await legacyCrypto.encryptForTesting(
        jsonEncode(originalFields),
        v1Key,
      );

      final migration = CryptoMigration(
        legacyCrypto: legacyCrypto,
        cryptoEngine: cryptoEngine,
      );

      final v2Blob = await migration.migrateItemData(
        v1EncryptedString: v1Encrypted,
        v1Key: v1Key,
        v2Key: v2Key,
        plaintextMetadata: {'type': 'password', 'favorite': true, 'folder': 'work'},
      );

      final decrypted = await cryptoEngine.decryptFields(v2Blob, v2Key);
      expect(decrypted['name'], equals('My Login'));
      expect(decrypted['username'], equals('myuser'));
      expect(decrypted['password'], equals('mypass123!@#'));
      expect(decrypted['url'], equals('https://secure.example.com'));
      expect(decrypted['notes'], equals(originalFields['notes']));
      expect(decrypted['type'], equals('password'));
      expect(decrypted['favorite'], equals(true));
      expect(decrypted['folder'], equals('work'));
    });

    test('needsMigration returns true when v1 items exist', () {
      final items = <MockVaultItem>[
        MockVaultItem(
          id: 'v1-item',
          vaultId: 'vault-1',
          encryptedData: Uint8List(0),
          encryptionVersion: 1,
          type: 'password',
          favorite: false,
          folder: '',
        ),
      ];

      expect(CryptoMigration.needsMigration(items), isTrue);
    });

    test('needsMigration returns false when all items are v2', () {
      final items = <MockVaultItem>[
        MockVaultItem(
          id: 'v2-item',
          vaultId: 'vault-1',
          encryptedData: Uint8List(0),
          encryptionVersion: 2,
          type: 'password',
          favorite: false,
          folder: '',
        ),
      ];

      expect(CryptoMigration.needsMigration(items), isFalse);
    });

    test('needsMigration returns false for empty list', () {
      expect(CryptoMigration.needsMigration([]), isFalse);
    });

    test('MigrationProgress percent calculation', () {
      expect(
        const MigrationProgress(current: 0, total: 10).percent,
        equals(0.0),
      );
      expect(
        const MigrationProgress(current: 5, total: 10).percent,
        equals(0.5),
      );
      expect(
        const MigrationProgress(current: 10, total: 10).percent,
        equals(1.0),
      );
      // Edge case: empty vault
      expect(
        const MigrationProgress(current: 0, total: 0).percent,
        equals(1.0),
      );
    });
  });
}
