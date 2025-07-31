// File: lib/data/services/vault/vault_service.dart
import 'dart:convert';
import 'package:get/get.dart';
import 'package:pocketbase/pocketbase.dart';
import '../../models/vault_item_model.dart';
import '../api/pocketbase_service.dart';
import '../crypto/encryption_service.dart';
import '../auth/session_service.dart';

class VaultService extends GetxService {
  final PocketBase _pb = Get.find<PocketBaseService>().client;
  final EncryptionService _encryptionService = Get.find<EncryptionService>();
  final SessionService _sessionService = Get.find<SessionService>();

  Future<List<VaultItem>> fetchAndDecryptVaultItems() async {
    if (!_sessionService.isVaultUnlocked) throw Exception("Vault is locked.");

    final records = await _pb
        .collection('vault_items')
        .getFullList(
          filter: 'owner = "${_pb.authStore.model!.id}"',
          sort: '-created',
        );
    final key = _sessionService.encryptionKey;

    return records.map((record) {
      final encryptedName = record.getStringValue('name_encrypted');
      final decryptedName = _encryptionService.decrypt(encryptedName, key);
      return VaultItem.fromRecord(record, decryptedName);
    }).toList();
  }

  Map<String, dynamic> decryptVaultItemFields(VaultItem item) {
    if (!_sessionService.isVaultUnlocked) throw Exception("Vault is locked.");
    final key = _sessionService.encryptionKey;
    final decryptedJson = _encryptionService.decrypt(item.encryptedFields, key);
    return jsonDecode(decryptedJson) as Map<String, dynamic>;
  }

  Future<void> createVaultItem({
    required VaultItemType type,
    required String name,
    required Map<String, dynamic> fields,
  }) async {
    if (!_sessionService.isVaultUnlocked) throw Exception("Vault is locked.");

    final key = _sessionService.encryptionKey;
    final iv = _encryptionService.generateIV();
    final jsonFields = jsonEncode(fields);

    final encryptedName = _encryptionService.encrypt(name, key, iv);
    final encryptedFields = _encryptionService.encrypt(jsonFields, key, iv);

    await _pb
        .collection('vault_items')
        .create(
          body: {
            'owner': _pb.authStore.model!.id,
            'type': type.toShortString(),
            'name_encrypted': encryptedName,
            'iv': iv.base64,
            'fields_encrypted': encryptedFields,
            'favorite': false,
          },
        );
  }

  Future<void> deleteVaultItem(String itemId) async {
    await _pb.collection('vault_items').delete(itemId);
  }
}
