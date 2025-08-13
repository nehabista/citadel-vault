import 'dart:convert';
import 'dart:typed_data';

import 'package:pocketbase/pocketbase.dart';

/// Remote data source wrapping PocketBase for vault_items collection.
///
/// Per D-18: PocketBase stores opaque encrypted blobs.
/// Sends/receives base64-encoded encrypted data -- no server-side decryption.
class RemoteVaultDatasource {
  final PocketBase _pb;
  static const String _collection = 'vault_items';

  RemoteVaultDatasource({required PocketBase pb}) : _pb = pb;

  /// Create a vault item record on PocketBase.
  Future<RecordModel> createItem({
    required String itemId,
    required String vaultId,
    required Uint8List encryptedData,
    required int encryptionVersion,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) {
    return _pb.collection(_collection).create(
      body: {
        'item_id': itemId,
        'vault_id': vaultId,
        'encrypted_data': base64Encode(encryptedData),
        'encryption_version': encryptionVersion,
        'created_at': createdAt.toUtc().toIso8601String(),
        'updated_at': updatedAt.toUtc().toIso8601String(),
      },
    );
  }

  /// Update a vault item record on PocketBase.
  Future<RecordModel> updateItem({
    required String remoteId,
    required Uint8List encryptedData,
    required int encryptionVersion,
    required DateTime updatedAt,
  }) {
    return _pb.collection(_collection).update(
      remoteId,
      body: {
        'encrypted_data': base64Encode(encryptedData),
        'encryption_version': encryptionVersion,
        'updated_at': updatedAt.toUtc().toIso8601String(),
      },
    );
  }

  /// Delete a vault item record from PocketBase.
  Future<void> deleteItem(String remoteId) {
    return _pb.collection(_collection).delete(remoteId);
  }

  /// Fetch all vault items updated since a given timestamp.
  Future<List<RecordModel>> getItemsSince(String? lastSync) {
    String? filter;
    if (lastSync != null) {
      filter = 'updated > "$lastSync"';
    }
    return _pb.collection(_collection).getFullList(filter: filter);
  }
}
