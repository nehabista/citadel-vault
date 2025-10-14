import 'package:pocketbase/pocketbase.dart';

/// Model representing an emergency access contact.
///
/// Maps to the `emergency_contacts` PocketBase collection (per D-10, D-11, D-12).
/// Emergency access allows a trusted person to request vault access.
/// After a configurable waiting period (1-30 days), if the grantor does
/// not reject, the grantee receives the encrypted vault key.
class EmergencyContact {
  /// Unique identifier (PocketBase record ID).
  final String id;

  /// ID of the user granting emergency access.
  final String grantorId;

  /// ID of the trusted person who can request access.
  final String granteeId;

  /// Days the grantor has to reject before access is granted (1-30, default 7).
  final int waitingPeriodDays;

  /// Status: pending, active, waiting, rejected, revoked.
  /// - pending: invitation sent, not yet accepted by grantee
  /// - active: grantee accepted, no access requested
  /// - waiting: grantee requested access, countdown started
  /// - rejected: grantor rejected the access request
  /// - revoked: grantor revoked emergency contact status
  final String status;

  /// Base64-encoded vault key encrypted with X25519 shared secret.
  /// Only populated after the waiting period elapses without rejection.
  final String? encryptedVaultKey;

  /// Base64-encoded X25519 public key of the grantee.
  final String? granteePublicKey;

  /// When the grantee requested emergency access (starts the countdown).
  final DateTime? requestedAt;

  /// When the emergency contact relationship was created.
  final DateTime createdAt;

  const EmergencyContact({
    required this.id,
    required this.grantorId,
    required this.granteeId,
    this.waitingPeriodDays = 7,
    this.status = 'pending',
    this.encryptedVaultKey,
    this.granteePublicKey,
    this.requestedAt,
    required this.createdAt,
  });

  /// Deserialize from a PocketBase RecordModel.
  factory EmergencyContact.fromRecord(RecordModel record) {
    return EmergencyContact(
      id: record.id,
      grantorId: record.getStringValue('grantorId'),
      granteeId: record.getStringValue('granteeId'),
      waitingPeriodDays: record.getIntValue('waitingPeriodDays'),
      status: record.getStringValue('status'),
      encryptedVaultKey: record.getStringValue('encryptedVaultKey').isNotEmpty
          ? record.getStringValue('encryptedVaultKey')
          : null,
      granteePublicKey: record.getStringValue('granteePublicKey').isNotEmpty
          ? record.getStringValue('granteePublicKey')
          : null,
      requestedAt: record.getStringValue('requestedAt').isNotEmpty
          ? DateTime.parse(record.getStringValue('requestedAt'))
          : null,
      createdAt: DateTime.parse(record.getStringValue('created')),
    );
  }

  /// Serialize to a PocketBase request body.
  Map<String, dynamic> toBody() {
    return {
      'grantorId': grantorId,
      'granteeId': granteeId,
      'waitingPeriodDays': waitingPeriodDays,
      'status': status,
      'encryptedVaultKey': encryptedVaultKey,
      'granteePublicKey': granteePublicKey,
      'requestedAt': requestedAt?.toUtc().toIso8601String(),
    };
  }

  EmergencyContact copyWith({
    String? id,
    String? grantorId,
    String? granteeId,
    int? waitingPeriodDays,
    String? status,
    String? encryptedVaultKey,
    String? granteePublicKey,
    DateTime? requestedAt,
    DateTime? createdAt,
  }) {
    return EmergencyContact(
      id: id ?? this.id,
      grantorId: grantorId ?? this.grantorId,
      granteeId: granteeId ?? this.granteeId,
      waitingPeriodDays: waitingPeriodDays ?? this.waitingPeriodDays,
      status: status ?? this.status,
      encryptedVaultKey: encryptedVaultKey ?? this.encryptedVaultKey,
      granteePublicKey: granteePublicKey ?? this.granteePublicKey,
      requestedAt: requestedAt ?? this.requestedAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
