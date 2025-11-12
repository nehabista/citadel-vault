// File: lib/features/sharing/data/repositories/emergency_repository.dart
// Emergency access lifecycle repository with crypto key escrow,
// auto-grant checking, countdown helpers, and local notifications.
// Per D-11, D-12: X25519 encrypted vault key, configurable waiting period.

import 'dart:convert';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart' as db;
import '../../../../core/database/daos/sharing_dao.dart';
import '../../../notifications/data/services/notification_service.dart';
import '../models/emergency_contact.dart';
import '../services/emergency_service.dart';
import '../services/sharing_crypto_service.dart';

/// Repository that orchestrates the emergency access feature.
///
/// Combines PocketBase operations (via [EmergencyService]), X25519 crypto
/// (via [SharingCryptoService]), local caching (via [SharingDao]), and
/// local notifications (via [NotificationService]).
class EmergencyRepository {
  final EmergencyService _service;
  final SharingCryptoService _crypto;
  final SharingDao _dao;
  final NotificationService _notificationService;

  EmergencyRepository({
    required EmergencyService service,
    required SharingCryptoService crypto,
    required SharingDao dao,
    required NotificationService notificationService,
  })  : _service = service,
        _crypto = crypto,
        _dao = dao,
        _notificationService = notificationService;

  // ---------------------------------------------------------------------------
  // Grantor operations
  // ---------------------------------------------------------------------------

  /// Add a trusted contact who can request emergency vault access.
  ///
  /// Looks up the grantee by email, retrieves their public key,
  /// and creates the emergency contact record with status 'pending'.
  Future<void> addTrustedContact({
    required String granteeEmail,
    required int waitingPeriodDays,
    required String currentUserId,
    required String granteePublicKey,
    required String granteeId,
  }) async {
    final record = await _service.createEmergencyContact(
      grantorId: currentUserId,
      granteeId: granteeId,
      waitingPeriodDays: waitingPeriodDays,
      granteePublicKey: granteePublicKey,
    );

    // Cache locally in Drift
    final contact = EmergencyContact.fromRecord(record);
    await _cacheContact(contact);
  }

  /// Reject an emergency access request during the waiting period.
  Future<void> rejectRequest(String contactId) async {
    await _service.rejectAccess(contactId);

    await _notificationService.showEmergencyNotification(
      title: 'Emergency Access Rejected',
      body: 'You have rejected the emergency access request.',
      payload: 'emergency:$contactId:rejected',
    );
  }

  /// Revoke an existing emergency contact relationship.
  Future<void> revokeContact(String contactId) async {
    await _service.revokeAccess(contactId);

    await _notificationService.showEmergencyNotification(
      title: 'Emergency Access Revoked',
      body: 'Emergency access has been revoked.',
      payload: 'emergency:$contactId:revoked',
    );
  }

  /// Manually release the encrypted vault key to a grantee.
  ///
  /// Called by the grantor after the waiting period has expired.
  /// Encrypts the vault key with the grantee's X25519 public key and
  /// stores it via [EmergencyService.releaseVaultKey], which verifies
  /// the waiting period server-side before accepting the key.
  ///
  /// Returns an error message on failure, or null on success.
  Future<String?> releaseVaultKey({
    required EmergencyContact contact,
    required SimpleKeyPair grantorKeyPair,
    required Map<String, dynamic> vaultKeyData,
  }) async {
    try {
      if (contact.granteePublicKey == null) {
        return 'Grantee public key not available';
      }

      final granteePublicKeyBytes = base64Decode(contact.granteePublicKey!);
      final granteePublicKey = SimplePublicKey(
        granteePublicKeyBytes,
        type: KeyPairType.x25519,
      );

      // Derive shared key with emergency context (per D-12)
      final sharedKey = await _crypto.deriveSharedKey(
        localKeyPair: grantorKeyPair,
        remotePublicKey: granteePublicKey,
        context: utf8.encode('citadel-emergency-v1'),
      );

      // Encrypt vault key for grantee
      final encryptedVaultKey = await _crypto.encryptForSharing(
        vaultKeyData,
        sharedKey,
      );

      final encryptedVaultKeyBase64 = base64Encode(encryptedVaultKey);

      await _service.releaseVaultKey(contact.id, encryptedVaultKeyBase64);

      await _notificationService.showEmergencyNotification(
        title: 'Emergency Access Released',
        body: 'Vault key has been released to the emergency contact.',
        payload: 'emergency:${contact.id}:released',
      );

      return null; // success
    } on StateError catch (e) {
      return e.message;
    } catch (e) {
      return 'Failed to release vault key: $e';
    }
  }

  // ---------------------------------------------------------------------------
  // Grantee operations
  // ---------------------------------------------------------------------------

  /// Grantee requests emergency access -- starts the waiting period countdown.
  ///
  /// Per D-11: this triggers a notification to the grantor via real-time subscription.
  Future<void> requestAccess(String contactId) async {
    await _service.requestAccess(contactId);
  }

  /// Grantee attempts to access the grantor's vault after approval.
  ///
  /// Checks that status is 'active' and the waiting period has elapsed.
  /// Decrypts the vault key using X25519 shared secret derived from
  /// the grantor's public key and the grantee's local private key,
  /// with context 'citadel-emergency-v1'.
  ///
  /// Returns the decrypted vault data, or null if access is not yet available.
  Future<Map<String, dynamic>?> accessVault(
    EmergencyContact contact, {
    required SimpleKeyPair localKeyPair,
    required SimplePublicKey grantorPublicKey,
  }) async {
    if (contact.status != 'active') return null;

    if (contact.requestedAt == null || contact.encryptedVaultKey == null) {
      return null;
    }

    // Verify waiting period has elapsed
    final elapsed = DateTime.now().difference(contact.requestedAt!);
    if (elapsed < Duration(days: contact.waitingPeriodDays)) {
      return null;
    }

    // Derive shared key with emergency context
    final sharedKey = await _crypto.deriveSharedKey(
      localKeyPair: localKeyPair,
      remotePublicKey: grantorPublicKey,
      context: utf8.encode('citadel-emergency-v1'),
    );

    // Decrypt the vault key blob
    final encryptedBytes = base64Decode(contact.encryptedVaultKey!);
    final decryptedData = await _crypto.decryptFromSharing(
      Uint8List.fromList(encryptedBytes),
      sharedKey,
    );

    return decryptedData;
  }

  // ---------------------------------------------------------------------------
  // Auto-grant check (called on app open)
  // ---------------------------------------------------------------------------

  /// Check for pending emergency requests that have passed the waiting period.
  ///
  /// For each expired request where the current user is the grantor:
  /// derives a shared key with the grantee's public key, encrypts the
  /// vault key, and auto-approves the access.
  Future<void> checkPendingRequests({
    required String userId,
    required SimpleKeyPair grantorKeyPair,
    required Map<String, dynamic> vaultKeyData,
  }) async {
    final records = await _service.getContactsAsGrantor(userId);
    final contacts = records.map(EmergencyContact.fromRecord).toList();

    for (final contact in contacts) {
      if (contact.status != 'waiting') continue;
      if (contact.requestedAt == null) continue;

      final elapsed = DateTime.now().difference(contact.requestedAt!);
      if (elapsed < Duration(days: contact.waitingPeriodDays)) continue;

      // Waiting period has elapsed -- auto-approve
      if (contact.granteePublicKey == null) continue;

      final granteePublicKeyBytes = base64Decode(contact.granteePublicKey!);
      final granteePublicKey = SimplePublicKey(
        granteePublicKeyBytes,
        type: KeyPairType.x25519,
      );

      // Derive shared key with emergency context (per D-12)
      final sharedKey = await _crypto.deriveSharedKey(
        localKeyPair: grantorKeyPair,
        remotePublicKey: granteePublicKey,
        context: utf8.encode('citadel-emergency-v1'),
      );

      // Encrypt vault key for grantee
      final encryptedVaultKey = await _crypto.encryptForSharing(
        vaultKeyData,
        sharedKey,
      );

      final encryptedVaultKeyBase64 = base64Encode(encryptedVaultKey);

      await _service.releaseVaultKey(contact.id, encryptedVaultKeyBase64);

      await _notificationService.showEmergencyNotification(
        title: 'Emergency Access Granted',
        body: 'Emergency access has been automatically granted after the waiting period.',
        payload: 'emergency:${contact.id}:granted',
      );
    }
  }

  // ---------------------------------------------------------------------------
  // Real-time listener
  // ---------------------------------------------------------------------------

  /// Start listening for real-time emergency contact events.
  ///
  /// On status change to 'waiting' (for grantor): shows local notification.
  /// On status change to 'active' (for grantee): shows local notification.
  Future<void> startListening({
    required String userId,
    required void Function({
      required String message,
      required String actionLabel,
      required String route,
    }) showAlert,
  }) async {
    await _service.subscribeToEmergencyEvents(userId, (event) async {
      if (event.action == 'update' && event.record != null) {
        final contact = EmergencyContact.fromRecord(event.record!);

        // Grantor receives notification when grantee requests access
        if (contact.grantorId == userId && contact.status == 'waiting') {
          await _notificationService.showEmergencyNotification(
            title: 'Emergency Access Requested',
            body:
                'Someone has requested emergency access to your vault. You can reject within ${contact.waitingPeriodDays} days.',
            payload: 'emergency:${contact.id}:requested',
          );
          showAlert(
            message: 'Emergency access requested! Review now.',
            actionLabel: 'Review',
            route: '/emergency-access',
          );
        }

        // Grantee receives notification when access is granted
        if (contact.granteeId == userId && contact.status == 'active') {
          await _notificationService.showEmergencyNotification(
            title: 'Emergency Access Granted',
            body: 'Your emergency access request has been approved.',
            payload: 'emergency:${contact.id}:granted',
          );
        }

        // Cache the updated contact locally
        await _cacheContact(contact);
      }
    });
  }

  /// Stop listening for real-time emergency contact events.
  void stopListening() {
    _service.unsubscribe();
  }

  // ---------------------------------------------------------------------------
  // Countdown helper
  // ---------------------------------------------------------------------------

  /// Calculate the remaining wait time for an emergency contact in 'waiting' status.
  ///
  /// Returns the remaining duration, or null if not in waiting state.
  /// A negative or zero duration means the waiting period has elapsed.
  Duration? remainingWaitTime(EmergencyContact contact) {
    if (contact.status != 'waiting' || contact.requestedAt == null) {
      return null;
    }

    final deadline = contact.requestedAt!
        .add(Duration(days: contact.waitingPeriodDays));
    return deadline.difference(DateTime.now());
  }

  // ---------------------------------------------------------------------------
  // Data fetching
  // ---------------------------------------------------------------------------

  /// Fetch emergency contacts where the current user is the grantor.
  Future<List<EmergencyContact>> getGrantorContacts(String userId) async {
    final records = await _service.getContactsAsGrantor(userId);
    return records.map(EmergencyContact.fromRecord).toList();
  }

  /// Fetch emergency contacts where the current user is the grantee.
  Future<List<EmergencyContact>> getGranteeContacts(String userId) async {
    final records = await _service.getContactsAsGrantee(userId);
    return records.map(EmergencyContact.fromRecord).toList();
  }

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  /// Cache an emergency contact in the local Drift database.
  Future<void> _cacheContact(EmergencyContact contact) async {
    try {
      await _dao.upsertEmergencyContact(
        _contactToCompanion(contact),
      );
    } catch (_) {
      // Caching failures are non-fatal
    }
  }

  /// Convert an EmergencyContact model to a Drift companion for upserting.
  db.EmergencyContactsCompanion _contactToCompanion(EmergencyContact contact) {
    return db.EmergencyContactsCompanion(
      id: Value(contact.id),
      grantorId: Value(contact.grantorId),
      granteeId: Value(contact.granteeId),
      waitingPeriodDays: Value(contact.waitingPeriodDays),
      status: Value(contact.status),
      encryptedVaultKey: Value(contact.encryptedVaultKey),
      granteePublicKey: Value(contact.granteePublicKey),
      requestedAt: Value(contact.requestedAt),
      createdAt: Value(contact.createdAt),
    );
  }
}
