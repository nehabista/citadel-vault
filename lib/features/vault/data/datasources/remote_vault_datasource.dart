import 'dart:convert';
import 'dart:typed_data';

import 'package:pocketbase/pocketbase.dart';

/// Remote data source wrapping PocketBase for vault_items collection.
///
/// Per D-18: PocketBase stores opaque encrypted blobs.
/// Sends/receives base64-encoded encrypted data -- no server-side decryption.
///
/// PocketBase collection fields:
///   vault_items: id, vaultId (relation), owner (relation), encryptedData (text/base64), encryptionVersion (number)
///   vault_collections: id, name, owner (relation), colorHex, iconName
class RemoteVaultDatasource {
  final PocketBase _pb;
  static const String _itemsCollection = 'vault_items';
  static const String _collectionsCollection = 'vault_collections';

  RemoteVaultDatasource({required PocketBase pb}) : _pb = pb;

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

  /// Create a vault collection on PocketBase.
  Future<RecordModel> createVaultCollection({
    required String name,
    String colorHex = '#4D4DCD',
    String iconName = 'shield',
  }) {
    return _pb.collection(_collectionsCollection).create(
      body: {
        'name': name,
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
