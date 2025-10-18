// File: lib/features/sharing/data/services/emergency_service.dart
// PocketBase CRUD service for emergency_contacts collection.
// Manages the full emergency access lifecycle: create, request, approve, reject, revoke.
// Per D-10, D-11, D-15: configurable waiting period, real-time subscriptions.

import 'package:pocketbase/pocketbase.dart';

/// Service that handles PocketBase operations for emergency contacts.
///
/// Manages the lifecycle: pending -> waiting -> active/rejected/revoked.
/// Provides real-time subscriptions for emergency access events.
class EmergencyService {
  final PocketBase _pb;

  static const String _collection = 'emergency_contacts';

  EmergencyService({required PocketBase pb}) : _pb = pb;

  /// Create a new emergency contact relationship.
  ///
  /// Sets initial status to 'pending' (invitation sent, awaiting grantee request).
  Future<RecordModel> createEmergencyContact({
    required String grantorId,
    required String granteeId,
    required int waitingPeriodDays,
    required String granteePublicKey,
  }) async {
    return await _pb.collection(_collection).create(body: {
      'grantorId': grantorId,
      'granteeId': granteeId,
      'waitingPeriodDays': waitingPeriodDays,
      'granteePublicKey': granteePublicKey,
      'status': 'pending',
    });
  }

  /// Grantee requests emergency access -- sets status to 'waiting' and records timestamp.
  Future<RecordModel> requestAccess(String contactId) async {
    return await _pb.collection(_collection).update(contactId, body: {
      'status': 'waiting',
      'requestedAt': DateTime.now().toUtc().toIso8601String(),
    });
  }

  /// Approve emergency access -- sets status to 'active' and stores encrypted vault key.
  ///
  /// Called either manually by grantor or automatically after waiting period expires.
  Future<void> approveAccess(
    String contactId,
    String encryptedVaultKey,
  ) async {
    await _pb.collection(_collection).update(contactId, body: {
      'status': 'active',
      'encryptedVaultKey': encryptedVaultKey,
    });
  }

  /// Grantor rejects the emergency access request during waiting period.
  Future<void> rejectAccess(String contactId) async {
    await _pb.collection(_collection).update(contactId, body: {
      'status': 'rejected',
    });
  }

  /// Grantor revokes an existing emergency contact relationship.
  Future<void> revokeAccess(String contactId) async {
    await _pb.collection(_collection).update(contactId, body: {
      'status': 'revoked',
      'encryptedVaultKey': '',
    });
  }

  /// Get all emergency contacts where the user is the grantor.
  Future<List<RecordModel>> getContactsAsGrantor(String userId) async {
    return await _pb.collection(_collection).getFullList(
          filter: 'grantorId = "$userId"',
          sort: '-created',
        );
  }

  /// Get all emergency contacts where the user is the grantee.
  Future<List<RecordModel>> getContactsAsGrantee(String userId) async {
    return await _pb.collection(_collection).getFullList(
          filter: 'granteeId = "$userId"',
          sort: '-created',
        );
  }

  /// Get a single emergency contact by ID.
  Future<RecordModel?> getContact(String contactId) async {
    try {
      return await _pb.collection(_collection).getOne(contactId);
    } catch (_) {
      return null;
    }
  }

  /// Delete an emergency contact record.
  Future<void> deleteContact(String contactId) async {
    await _pb.collection(_collection).delete(contactId);
  }

  /// Subscribe to real-time emergency contact events for a user.
  ///
  /// Fires on any create/update/delete in the emergency_contacts collection.
  /// The caller should filter events by userId (grantor or grantee).
  void subscribeToEmergencyEvents(
    String userId,
    void Function(RecordSubscriptionEvent) callback,
  ) {
    _pb.collection(_collection).subscribe('*', callback);
  }

  /// Unsubscribe from real-time emergency contact events.
  void unsubscribe() {
    _pb.collection(_collection).unsubscribe('*');
  }
}
