// File: lib/features/sharing/data/services/sharing_service.dart
// PocketBase CRUD service for shared_items, shared_links, and user_keys collections.
// Per D-02, D-03, D-04, D-05, D-06, D-15.

import 'dart:developer' as dev;

import 'package:pocketbase/pocketbase.dart';

import '../../../../core/utils/pb_filter_sanitizer.dart';

/// Service responsible for PocketBase API calls related to sharing.
///
/// Manages three PB collections:
/// - `user_keys` — X25519 public keys for ECDH key exchange
/// - `shared_items` — encrypted item shares between Citadel users
/// - `shared_links` — encrypted link-based shares for non-Citadel users
class SharingService {
  final PocketBase _pb;

  SharingService({required PocketBase pb}) : _pb = pb;

  // ---------------------------------------------------------------------------
  // User Keys Management
  // ---------------------------------------------------------------------------

  /// Publish (upsert) the user's X25519 public key to the `user_keys` collection.
  ///
  /// This key is used by other users to derive a shared secret via ECDH
  /// for encrypting items before sharing.
  Future<void> publishPublicKey(String userId, String base64PublicKey) async {
    try {
      // Try to find existing key record for this user.
      final safeUserId = sanitizePbFilter(userId);
      final existing = await _pb.collection('user_keys').getFullList(
        filter: 'userId = "$safeUserId"',
      );
      if (existing.isNotEmpty) {
        await _pb.collection('user_keys').update(existing.first.id, body: {
          'x25519PublicKey': base64PublicKey,
        });
      } else {
        await _pb.collection('user_keys').create(body: {
          'userId': userId,
          'x25519PublicKey': base64PublicKey,
        });
      }
    } catch (e) {
      throw SharingServiceException('Failed to publish public key: $e');
    }
  }

  /// Fetch a user's X25519 public key from the `user_keys` collection.
  ///
  /// Returns the base64-encoded public key, or null if the user
  /// hasn't published a key yet (not a Citadel user or hasn't enabled sharing).
  Future<String?> getPublicKey(String userId) async {
    try {
      final safeUserId = sanitizePbFilter(userId);
      final records = await _pb.collection('user_keys').getFullList(
        filter: 'userId = "$safeUserId"',
      );
      if (records.isEmpty) return null;
      return records.first.getStringValue('x25519PublicKey');
    } catch (e) {
      throw SharingServiceException('Failed to get public key: $e');
    }
  }

  /// Look up a Citadel user by email address.
  ///
  /// Returns the user ID if found, null otherwise.
  /// Used by the share flow to resolve a recipient email to an ID.
  Future<String?> lookupUserByEmail(String email) async {
    try {
      final safeEmail = sanitizePbFilter(email);
      final records = await _pb.collection('users').getFullList(
        filter: 'email = "$safeEmail"',
      );
      if (records.isEmpty) return null;
      return records.first.id;
    } catch (e) {
      throw SharingServiceException('Failed to lookup user: $e');
    }
  }

  // ---------------------------------------------------------------------------
  // Shared Items (User-to-User)
  // ---------------------------------------------------------------------------

  /// Create a new shared item record in the `shared_items` collection.
  ///
  /// The [encryptedData] is an AES-256-GCM blob encrypted with the shared
  /// key derived from X25519 ECDH between sender and recipient.
  Future<RecordModel> createSharedItem({
    required String senderId,
    required String recipientId,
    required String encryptedData,
    required String senderPublicKey,
    DateTime? expiresAt,
  }) async {
    try {
      return await _pb.collection('shared_items').create(body: {
        'senderId': senderId,
        'recipientId': recipientId,
        'encryptedData': encryptedData,
        'senderPublicKey': senderPublicKey,
        'status': 'pending',
        if (expiresAt != null)
          'expiresAt': expiresAt.toUtc().toIso8601String(),
      });
    } catch (e) {
      throw SharingServiceException('Failed to create shared item: $e');
    }
  }

  /// Get all items shared with a specific user, sorted by creation date desc.
  Future<List<RecordModel>> getReceivedItems(String userId) async {
    try {
      final safeUserId = sanitizePbFilter(userId);
      return await _pb.collection('shared_items').getFullList(
        filter: 'recipientId = "$safeUserId"',
        sort: '-created',
      );
    } catch (e) {
      throw SharingServiceException('Failed to get received items: $e');
    }
  }

  /// Get all items sent (shared) by a specific user.
  Future<List<RecordModel>> getSentItems(String userId) async {
    try {
      final safeUserId = sanitizePbFilter(userId);
      return await _pb.collection('shared_items').getFullList(
        filter: 'senderId = "$safeUserId"',
        sort: '-created',
      );
    } catch (e) {
      throw SharingServiceException('Failed to get sent items: $e');
    }
  }

  /// Update the status of a shared item (accepted/declined).
  Future<void> updateItemStatus(String id, String status) async {
    try {
      await _pb.collection('shared_items').update(id, body: {
        'status': status,
      });
    } catch (e) {
      throw SharingServiceException('Failed to update item status: $e');
    }
  }

  /// Delete a shared item by ID.
  Future<void> deleteSharedItem(String id) async {
    try {
      await _pb.collection('shared_items').delete(id);
    } catch (e) {
      throw SharingServiceException('Failed to delete shared item: $e');
    }
  }

  // ---------------------------------------------------------------------------
  // Shared Links
  // ---------------------------------------------------------------------------

  /// Create a new shared link record in the `shared_links` collection.
  ///
  /// The decryption key is NOT stored server-side; it is returned to the
  /// caller and placed in the URL fragment (per D-04, D-05).
  ///
  /// SECURITY NOTE (accepted risk): PocketBase generates record IDs
  /// server-side (15-char alphanumeric, ~82 bits of entropy). The
  /// `shared_links.viewRule` is empty, so anyone who guesses a record ID
  /// can fetch the encrypted blob. However, the blob is AES-256-GCM
  /// encrypted and the decryption key is only present in the URL fragment
  /// (never sent to the server). Without the key, the encrypted data is
  /// cryptographically useless. Brute-forcing both the ID and the 256-bit
  /// key is computationally infeasible. Additionally, links have expiration
  /// and optional one-time-view enforcement. This risk is therefore accepted.
  Future<RecordModel> createSharedLink({
    required String encryptedData,
    required String creatorId,
    required DateTime expiresAt,
    required bool oneTimeView,
  }) async {
    try {
      return await _pb.collection('shared_links').create(body: {
        'encryptedData': encryptedData,
        'creatorId': creatorId,
        'expiresAt': expiresAt.toUtc().toIso8601String(),
        'oneTimeView': oneTimeView,
        'viewed': false,
      });
    } catch (e) {
      throw SharingServiceException('Failed to create shared link: $e');
    }
  }

  /// Fetch a shared link by ID.
  ///
  /// Returns null if the link has expired or has already been viewed
  /// (when oneTimeView is true).
  Future<RecordModel?> getSharedLink(String id) async {
    try {
      final record = await _pb.collection('shared_links').getOne(id);

      // Check expiration.
      final expiresAt = DateTime.parse(record.getStringValue('expiresAt'));
      if (DateTime.now().toUtc().isAfter(expiresAt)) return null;

      // Check one-time view.
      final oneTimeView = record.getBoolValue('oneTimeView');
      final viewed = record.getBoolValue('viewed');
      if (oneTimeView && viewed) return null;

      return record;
    } on ClientException catch (e) {
      // 404 means link doesn't exist.
      if (e.statusCode == 404) return null;
      throw SharingServiceException('Failed to get shared link: $e');
    } catch (e) {
      throw SharingServiceException('Failed to get shared link: $e');
    }
  }

  /// Mark a shared link as viewed.
  Future<void> markLinkViewed(String id) async {
    try {
      await _pb.collection('shared_links').update(id, body: {
        'viewed': true,
      });
    } catch (e) {
      throw SharingServiceException('Failed to mark link viewed: $e');
    }
  }

  /// Delete a shared link by ID.
  Future<void> deleteSharedLink(String id) async {
    try {
      await _pb.collection('shared_links').delete(id);
    } catch (e) {
      throw SharingServiceException('Failed to delete shared link: $e');
    }
  }

  // ---------------------------------------------------------------------------
  // Real-Time Subscriptions
  // ---------------------------------------------------------------------------

  /// Subscribe to real-time changes on the `shared_items` collection.
  ///
  /// The callback fires on any create/update/delete. Client-side
  /// filtering by recipientId is applied in the repository layer.
  Future<void> subscribeToSharedItems(
    String userId,
    void Function(RecordSubscriptionEvent) callback,
  ) async {
    try {
      await _pb.collection('shared_items').subscribe('*', callback);
    } catch (e) {
      // Realtime not available — fall back to polling
      dev.log('[Sharing] Realtime unavailable: $e');
    }
  }

  /// Unsubscribe from all `shared_items` real-time events.
  void unsubscribeAll() {
    _pb.collection('shared_items').unsubscribe('*');
  }
}

/// Exception type for [SharingService] errors.
class SharingServiceException implements Exception {
  final String message;
  const SharingServiceException(this.message);

  @override
  String toString() => 'SharingServiceException: $message';
}
