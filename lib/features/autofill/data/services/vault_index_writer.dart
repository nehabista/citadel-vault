import 'dart:convert';
import 'dart:io' show Platform;

import 'package:cryptography/cryptography.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/core_providers.dart';
import '../../../../core/providers/session_provider.dart';
import '../../../../core/session/session_state.dart';
import '../../domain/models/autofill_credential.dart';

/// Writes an AES-256-GCM encrypted credential index to the macOS App Group
/// shared container on vault unlock.
///
/// The macOS Credential Provider Extension (Plan 04-03) reads this encrypted
/// file and decrypts it using a key stored in the shared Keychain access group.
///
/// Per D-10: the encrypted index file is `autofill_vault.enc` stored in the
/// App Group container `group.com.shaivites.citadelvault`.
///
/// The vault key (already 32 bytes for AES-256) is stored in the shared Keychain
/// at:
///   - kSecAttrAccessGroup: $(AppIdentifierPrefix)com.shaivites.citadelvault.shared
///   - kSecAttrService: com.shaivites.citadelvault.autofill-key
///   - kSecAttrAccount: vault-index-key
///
/// On other platforms (Android, iOS, web), all methods are no-ops since
/// Android autofill uses MethodChannel queries directly and iOS has a
/// separate extension mechanism.
class VaultIndexWriter {
  final Ref _ref;

  /// Platform channel for writing to macOS App Group container and Keychain.
  static const _channel = MethodChannel('com.citadel/vault-index');

  VaultIndexWriter(this._ref);

  /// Whether we're running on macOS (not web).
  bool get _isMacOS => !kIsWeb && Platform.isMacOS;

  /// Write an encrypted credential index to the macOS App Group container.
  ///
  /// Process:
  /// 1. Check platform (no-op if not macOS)
  /// 2. Check session state (skip if locked)
  /// 3. Load all vault items, decrypt each to extract credential fields
  /// 4. Build credential list and serialize to JSON
  /// 5. Encrypt JSON with AES-256-GCM using the vault key
  /// 6. Write encrypted data to App Group via platform channel
  /// 7. Store vault key in shared Keychain for extension access
  Future<void> writeEncryptedIndex() async {
    if (!_isMacOS) return;

    final session = _ref.read(sessionProvider);
    if (session is! Unlocked) return;

    final vaultKey = SecretKey(session.vaultKey);
    final cryptoEngine = _ref.read(cryptoEngineProvider);
    final db = _ref.read(appDatabaseProvider);
    final totpDao = db.totpDao;

    // Load all vaults to iterate their items
    final vaults = await db.vaultDao.getAllVaults();
    final credentials = <Map<String, dynamic>>[];

    for (final vault in vaults) {
      final items = await db.vaultDao.getItemsByVault(vault.id);
      for (final item in items) {
        try {
          // Decrypt vault item fields
          final fields = await cryptoEngine.decryptFields(
            item.encryptedData,
            vaultKey,
          );

          final username = (fields['username'] as String?) ?? '';
          final password = (fields['password'] as String?) ?? '';
          final displayName = (fields['name'] as String?) ?? 'Unknown';
          final savedUrl = fields['url'] as String?;

          // Check for TOTP entries
          final totpEntries = await totpDao.getByVaultItemId(item.id);

          final credential = AutofillCredential(
            vaultItemId: item.id,
            username: username,
            password: password,
            displayName: displayName,
            domain: savedUrl,
            hasTotpEntry: totpEntries.isNotEmpty,
          );

          credentials.add(credential.toMap());
        } catch (_) {
          // Skip items that fail to decrypt
          continue;
        }
      }
    }

    // Serialize credential list to JSON bytes
    final jsonString = jsonEncode(credentials);
    final jsonBytes = Uint8List.fromList(utf8.encode(jsonString));

    // Encrypt JSON with AES-256-GCM using the vault key
    final encryptedBytes = await cryptoEngine.encrypt(jsonBytes, vaultKey);

    // Write encrypted index to macOS App Group container
    await _channel.invokeMethod('writeIndex', {
      'data': base64.encode(encryptedBytes),
    });

    // Store vault key in shared Keychain for extension decryption
    await _channel.invokeMethod('storeSharedKey', {
      'key': base64.encode(session.vaultKey),
    });
  }

  /// Clear the encrypted index and shared key.
  ///
  /// Called on vault lock to ensure no sensitive data remains accessible
  /// to the extension when the vault is locked.
  Future<void> clearIndex() async {
    if (!_isMacOS) return;

    try {
      await _channel.invokeMethod('clearIndex');
      await _channel.invokeMethod('clearSharedKey');
    } catch (_) {
      // Ignore errors during cleanup
    }
  }
}
