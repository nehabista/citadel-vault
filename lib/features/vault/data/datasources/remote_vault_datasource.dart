import 'dart:convert';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
import 'package:pocketbase/pocketbase.dart';

import '../../../../core/crypto/crypto_engine.dart';

/// Remote data source wrapping PocketBase for vault_items collection.
///
/// Per D-18: PocketBase stores opaque encrypted blobs.
/// Sends/receives base64-encoded encrypted data -- no server-side decryption.
/// Per D-11: vault names are encrypted before being sent to PocketBase.
///
/// PocketBase collection fields:
///   vault_items: id, vaultId (relation), owner (relation), encryptedData (text/base64), encryptionVersion (number)
///   vault_collections: id, name (encrypted), owner (relation), colorHex, iconName
class RemoteVaultDatasource {
  final PocketBase _pb;
  final CryptoEngine _cryptoEngine;
  static const String _itemsCollection = 'vault_items';
  static const String _collectionsCollection = 'vault_collections';

  RemoteVaultDatasource({
    required PocketBase pb,
    required CryptoEngine cryptoEngine,
  })  : _pb = pb,
        _cryptoEngine = cryptoEngine;

  /// The current authenticated user's ID.
  String? get _currentUserId => _pb.authStore.record?.id;

  /// Create a vault item record on PocketBase.
  Future<RecordModel> createItem({
    required String vaultId,
    required Uint8List encryptedData,
    required int encryptionVersion,
  }) {
    return _pb.collection(_itemsCollection).create(
      body: {
        'vaultId': vaultId,
        'owner': _currentUserId,
        'encryptedData': base64Encode(encryptedData),
        'encryptionVersion': encryptionVersion,
      },
    );
  }

  /// Update a vault item record on PocketBase.
  Future<RecordModel> updateItem({
    required String remoteId,
    required Uint8List encryptedData,
    required int encryptionVersion,
  }) {
    return _pb.collection(_itemsCollection).update(
      remoteId,
      body: {
        'encryptedData': base64Encode(encryptedData),
        'encryptionVersion': encryptionVersion,
        'owner': _currentUserId,
      },
    );
  }

  /// Delete a vault item record from PocketBase.
  Future<void> deleteItem(String remoteId) {
    return _pb.collection(_itemsCollection).delete(remoteId);
  }

  /// Fetch all vault items for the current user updated since a given timestamp.
  Future<List<RecordModel>> getItemsSince(String? lastSync) {
    final userId = _currentUserId;
    if (userId == null) return Future.value([]);

    String filter = 'owner = "$userId"';
    if (lastSync != null) {
      filter += ' && updated > "$lastSync"';
    }
    return _pb.collection(_itemsCollection).getFullList(filter: filter);
  }

  /// Encrypt a vault name before sending to PocketBase.
  ///
  /// Per D-11: vault names are identifying metadata that must not be stored
  /// as plaintext on the server. Returns a base64-encoded encrypted blob.
  Future<String> _encryptVaultName(String name, SecretKey key) async {
    final plaintext = Uint8List.fromList(utf8.encode(name));
    final encrypted = await _cryptoEngine.encrypt(plaintext, key);
    return base64Encode(encrypted);
  }

  /// Decrypt a vault name received from PocketBase.
  ///
  /// Falls back to returning the raw value if decryption fails (backward
  /// compatibility with pre-encryption plaintext names).
  Future<String> decryptVaultName(String encodedName, SecretKey key) async {
    try {
      final encrypted = base64Decode(encodedName);
      final decrypted = await _cryptoEngine.decrypt(encrypted, key);
      return utf8.decode(decrypted);
    } catch (_) {
      // Legacy plaintext name — return as-is.
      return encodedName;
    }
  }

  /// Create a vault collection on PocketBase.
  ///
  /// The [vaultKey] is used to encrypt the vault name (D-11).
  Future<RecordModel> createVaultCollection({
    required String name,
    required SecretKey vaultKey,
    String colorHex = '#4D4DCD',
    String iconName = 'shield',
  }) async {
    final encryptedName = await _encryptVaultName(name, vaultKey);
    return _pb.collection(_collectionsCollection).create(
      body: {
        'name': encryptedName,
        'owner': _currentUserId,
        'colorHex': colorHex,
        'iconName': iconName,
      },
    );
  }

  /// Delete a vault collection from PocketBase.
  Future<void> deleteVaultCollection(String remoteId) {
    return _pb.collection(_collectionsCollection).delete(remoteId);
  }
}
