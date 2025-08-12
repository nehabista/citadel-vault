// File: lib/data/services/vault/vault_service.dart
import 'dart:convert';
import 'package:pocketbase/pocketbase.dart';
import '../../models/vault_item_model.dart';
import '../crypto/encryption_service.dart';
import '../auth/session_service.dart';

/// Handles vault item CRUD operations with encryption/decryption.
/// Plain Dart class -- no GetX dependency.
class VaultService {
  final PocketBase pb;
  final EncryptionService encryptionService;
  final SessionService sessionService;

  VaultService({
    required this.pb,
    required this.encryptionService,
    required this.sessionService,
  });

  Future<List<VaultItem>> fetchAndDecryptVaultItems() async {
    if (!sessionService.isVaultUnlocked) throw Exception("Vault is locked.");

    final records = await pb.collection('vault_items').getFullList(
          filter: 'owner = "${pb.authStore.model!.id}"',
          sort: '-created',
        );
    final key = sessionService.encryptionKey;

    return records.map((record) {
      final encryptedName = record.getStringValue('name_encrypted');
      final decryptedName = encryptionService.decrypt(encryptedName, key);
      return VaultItem.fromRecord(record, decryptedName);
    }).toList();
  }

  Map<String, dynamic> decryptVaultItemFields(VaultItem item) {
    if (!sessionService.isVaultUnlocked) throw Exception("Vault is locked.");
    final key = sessionService.encryptionKey;
    final decryptedJson = encryptionService.decrypt(item.encryptedFields, key);
    return jsonDecode(decryptedJson) as Map<String, dynamic>;
  }

  Future<void> createVaultItem({
    required VaultItemType type,
    required String name,
    required Map<String, dynamic> fields,
  }) async {
    if (!sessionService.isVaultUnlocked) throw Exception("Vault is locked.");

    final key = sessionService.encryptionKey;
    final iv = encryptionService.generateIV();
    final jsonFields = jsonEncode(fields);

    final encryptedName = encryptionService.encrypt(name, key, iv);
    final encryptedFields = encryptionService.encrypt(jsonFields, key, iv);

    await pb.collection('vault_items').create(
          body: {
            'owner': pb.authStore.model!.id,
            'type': type.toShortString(),
            'name_encrypted': encryptedName,
            'iv': iv.base64,
            'fields_encrypted': encryptedFields,
            'favorite': false,
          },
        );
  }

  Future<void> deleteVaultItem(String itemId) async {
    await pb.collection('vault_items').delete(itemId);
  }
}
