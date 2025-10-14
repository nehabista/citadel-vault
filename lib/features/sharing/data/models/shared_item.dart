import 'package:pocketbase/pocketbase.dart';

/// Model representing a user-to-user shared vault item.
///
/// Maps to the `shared_items` PocketBase collection (per D-03).
/// The [encryptedData] field contains AES-256-GCM encrypted JSON,
/// decryptable only by the recipient using X25519 key exchange.
class SharedItem {
  /// Unique identifier (PocketBase record ID).
  final String id;

  /// ID of the user who shared the item.
  final String senderId;

  /// ID of the user receiving the shared item.
  final String recipientId;

  /// Base64-encoded encrypted item data (AES-256-GCM blob).
  final String encryptedData;

  /// Base64-encoded X25519 public key of the sender.
  final String senderPublicKey;

  /// When the share was created.
  final DateTime createdAt;

  /// Optional expiration time for the share.
  final DateTime? expiresAt;

  /// Share status: pending, accepted, declined.
  final String status;

  const SharedItem({
    required this.id,
    required this.senderId,
    required this.recipientId,
    required this.encryptedData,
    required this.senderPublicKey,
    required this.createdAt,
    this.expiresAt,
    this.status = 'pending',
  });

  /// Deserialize from a PocketBase RecordModel.
  factory SharedItem.fromRecord(RecordModel record) {
    return SharedItem(
      id: record.id,
      senderId: record.getStringValue('senderId'),
      recipientId: record.getStringValue('recipientId'),
      encryptedData: record.getStringValue('encryptedData'),
      senderPublicKey: record.getStringValue('senderPublicKey'),
      createdAt: DateTime.parse(record.getStringValue('created')),
      expiresAt: record.getStringValue('expiresAt').isNotEmpty
          ? DateTime.parse(record.getStringValue('expiresAt'))
          : null,
      status: record.getStringValue('status'),
    );
  }

  /// Serialize to a PocketBase request body.
  Map<String, dynamic> toBody() {
    return {
      'senderId': senderId,
      'recipientId': recipientId,
      'encryptedData': encryptedData,
      'senderPublicKey': senderPublicKey,
      'expiresAt': expiresAt?.toUtc().toIso8601String(),
      'status': status,
    };
  }

  SharedItem copyWith({
    String? id,
    String? senderId,
    String? recipientId,
    String? encryptedData,
    String? senderPublicKey,
    DateTime? createdAt,
    DateTime? expiresAt,
    String? status,
  }) {
    return SharedItem(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      recipientId: recipientId ?? this.recipientId,
      encryptedData: encryptedData ?? this.encryptedData,
      senderPublicKey: senderPublicKey ?? this.senderPublicKey,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
      status: status ?? this.status,
    );
  }
}
