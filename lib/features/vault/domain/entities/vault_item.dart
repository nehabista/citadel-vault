import 'custom_field.dart';

/// Plaintext domain entity representing a vault item.
///
/// This is the PLAINTEXT representation used within the app.
/// Encryption/decryption happens at the repository boundary (Pattern 2).
/// The data layer stores encrypted blobs; the domain layer works with
/// plain Dart objects.
class VaultItemEntity {
  final String id;
  final String vaultId;
  final String name;
  final String? url;
  final String? username;
  final String? password;
  final String? notes;
  final VaultItemType type;
  final bool isFavorite;
  final String? folder;
  final List<CustomField>? customFields;
  final int? expiryDays;
  final DateTime createdAt;
  final DateTime updatedAt;

  const VaultItemEntity({
    required this.id,
    required this.vaultId,
    required this.name,
    this.url,
    this.username,
    this.password,
    this.notes,
    required this.type,
    this.isFavorite = false,
    this.folder,
    this.customFields,
    this.expiryDays,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Serialize all plaintext fields to a map for encryption.
  Map<String, dynamic> toFieldsMap() {
    return {
      'name': name,
      'url': url,
      'username': username,
      'password': password,
      'notes': notes,
      'type': type.name,
      'isFavorite': isFavorite,
      'folder': folder,
      'customFields': customFields?.map((f) => f.toJson()).toList(),
      'expiryDays': expiryDays,
    };
  }

  /// Deserialize from decrypted fields map.
  factory VaultItemEntity.fromFields({
    required String id,
    required String vaultId,
    required Map<String, dynamic> fields,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) {
    return VaultItemEntity(
      id: id,
      vaultId: vaultId,
      name: fields['name'] as String? ?? '',
      url: fields['url'] as String?,
      username: fields['username'] as String?,
      password: fields['password'] as String?,
      notes: fields['notes'] as String?,
      type: VaultItemType.values.firstWhere(
        (t) => t.name == (fields['type'] as String? ?? 'password'),
        orElse: () => VaultItemType.password,
      ),
      isFavorite: fields['isFavorite'] as bool? ?? false,
      folder: fields['folder'] as String?,
      customFields: (fields['customFields'] as List<dynamic>?)
          ?.map((f) => CustomField.fromJson(f as Map<String, dynamic>))
          .toList(),
      expiryDays: fields['expiryDays'] as int?,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  VaultItemEntity copyWith({
    String? id,
    String? vaultId,
    String? name,
    String? url,
    String? username,
    String? password,
    String? notes,
    VaultItemType? type,
    bool? isFavorite,
    String? folder,
    List<CustomField>? customFields,
    int? expiryDays,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return VaultItemEntity(
      id: id ?? this.id,
      vaultId: vaultId ?? this.vaultId,
      name: name ?? this.name,
      url: url ?? this.url,
      username: username ?? this.username,
      password: password ?? this.password,
      notes: notes ?? this.notes,
      type: type ?? this.type,
      isFavorite: isFavorite ?? this.isFavorite,
      folder: folder ?? this.folder,
      customFields: customFields ?? this.customFields,
      expiryDays: expiryDays ?? this.expiryDays,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// Types of items stored in the vault.
enum VaultItemType {
  password,
  secureNote,
  contactInfo,
  bankAccount,
  paymentCard,
  wifiPassword,
  softwareLicense,
}
