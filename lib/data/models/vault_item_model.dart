// File: lib/data/models/vault_item_model.dart
import 'package:pocketbase/pocketbase.dart';

enum VaultItemType {
  password,
  secureNote,
  contactInfo,
  bankAccount,
  paymentCard,
  wifiPassword,
  softwareLicense,
}

extension VaultItemTypeExtension on VaultItemType {
  String toShortString() => toString().split('.').last;
}

VaultItemType vaultItemTypeFromString(String type) {
  return VaultItemType.values.firstWhere(
    (e) => e.toShortString() == type,
    orElse: () => VaultItemType.password,
  );
}

class VaultItem {
  final String id;
  final VaultItemType type;
  final String iv;
  final String encryptedFields;
  final bool isFavorite;
  final String decryptedName;

  VaultItem({
    required this.id,
    required this.type,
    required this.iv,
    required this.encryptedFields,
    required this.isFavorite,
    required this.decryptedName,
  });

  factory VaultItem.fromRecord(RecordModel record, String decryptedName) {
    return VaultItem(
      id: record.id,
      type: vaultItemTypeFromString(record.getStringValue('type')),
      iv: record.getStringValue('iv'),
      encryptedFields: record.getStringValue('fields_encrypted'),
      isFavorite: record.getBoolValue('favorite'),
      decryptedName: decryptedName,
    );
  }
}
