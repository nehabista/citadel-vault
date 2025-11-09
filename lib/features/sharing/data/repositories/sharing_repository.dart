// File: lib/features/sharing/data/repositories/sharing_repository.dart
// Coordinates crypto + PocketBase + local Drift cache + notifications
// for all sharing operations (user-to-user, link-based, real-time).

import 'dart:convert';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
import 'package:drift/drift.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/database/daos/sharing_dao.dart';
import '../../../notifications/data/services/notification_service.dart';
import '../models/shared_item.dart' as pb_models;
import '../services/sharing_crypto_service.dart';
import '../services/sharing_service.dart';

/// Repository that orchestrates sharing operations across:
/// - [SharingService] for PocketBase API calls
/// - [SharingCryptoService] for X25519/AES-256-GCM cryptography
/// - [SharingDao] for local Drift cache
/// - [NotificationService] for local notification triggers
class SharingRepository {
  final SharingService _service;
  final SharingCryptoService _crypto;
  final SharingDao _dao;
  final NotificationService _notificationService;
  final FlutterSecureStorage _secureStorage;

  SharingRepository({
    required SharingService service,
    required SharingCryptoService crypto,
    required SharingDao dao,
    required NotificationService notificationService,
    FlutterSecureStorage? secureStorage,
  })  : _service = service,
        _crypto = crypto,
        _dao = dao,
        _notificationService = notificationService,
        _secureStorage = secureStorage ?? const FlutterSecureStorage();

  // ---------------------------------------------------------------------------
  // Keypair Management
  // ---------------------------------------------------------------------------

  /// Ensure the user has an X25519 keypair for sharing.
  ///
  /// Checks flutter_secure_storage for an existing private key.
  /// If missing, generates a new keypair, stores the private key securely,
  /// and publishes the public key to PocketBase via [SharingService].
  Future<void> ensureKeypairExists({required String userId}) async {
    final existing = await _secureStorage.read(key: 'x25519_private_key');
    if (existing != null && existing.isNotEmpty) return;

    // Generate a new X25519 keypair.
    final keyPair = await _crypto.generateKeyPair();

    // Extract and store private key bytes.
    final privateKeyData = await keyPair.extractPrivateKeyBytes();
    final privateKeyBytes = privateKeyData;
    await _secureStorage.write(
      key: 'x25519_private_key',
      value: base64Encode(privateKeyBytes),
    );

    // Extract and publish public key.
    final publicKey = await _crypto.extractPublicKey(keyPair);
    final publicKeyBytes = publicKey.bytes;
    await _secureStorage.write(
      key: 'x25519_public_key',
      value: base64Encode(publicKeyBytes),
    );

    await _service.publishPublicKey(userId, base64Encode(publicKeyBytes));
  }

  /// Return the local X25519 public key as a base64 string.
  ///
  /// Throws [StateError] if the keypair has not been generated yet.
  /// Call [ensureKeypairExists] first.
  Future<String> getLocalPublicKeyBase64() async {
    final publicKeyBase64 =
        await _secureStorage.read(key: 'x25519_public_key');
    if (publicKeyBase64 == null || publicKeyBase64.isEmpty) {
      throw StateError(
        'X25519 public key not found. Call ensureKeypairExists() first.',
      );
    }
    return publicKeyBase64;
  }

  /// Load the local X25519 keypair from flutter_secure_storage.
  Future<SimpleKeyPair> getLocalKeyPair() async {
    final privateKeyBase64 =
        await _secureStorage.read(key: 'x25519_private_key');
    final publicKeyBase64 =
        await _secureStorage.read(key: 'x25519_public_key');

    if (privateKeyBase64 == null || publicKeyBase64 == null) {
      throw StateError(
        'X25519 keypair not found. Call ensureKeypairExists() first.',
      );
    }

    final privateKeyBytes = base64Decode(privateKeyBase64);
    final publicKeyBytes = base64Decode(publicKeyBase64);

    return SimpleKeyPairData(
      privateKeyBytes,
      publicKey: SimplePublicKey(publicKeyBytes, type: KeyPairType.x25519),
      type: KeyPairType.x25519,
    );
  }

  // ---------------------------------------------------------------------------
  // Share With User (X25519 ECDH)
  // ---------------------------------------------------------------------------

  /// Share a vault item with another Citadel user by email.
  ///
  /// Flow:
  /// 1. Look up recipient by email
  /// 2. Fetch recipient's X25519 public key
  /// 3. Derive shared secret via ECDH
  /// 4. Encrypt item data with AES-256-GCM
  /// 5. Create shared_items record in PocketBase
  /// 6. Show local notification confirming the share
  Future<void> shareItemWithUser({
    required String recipientEmail,
    required Map<String, dynamic> itemData,
  }) async {
    // 1. Look up recipient.
    final recipientId = await _service.lookupUserByEmail(recipientEmail);
    if (recipientId == null) {
      throw SharingRepositoryException(
        'No Citadel user found with email: $recipientEmail',
      );
    }

    // 2. Get recipient's public key.
    final recipientPublicKeyBase64 = await _service.getPublicKey(recipientId);
    if (recipientPublicKeyBase64 == null) {
      throw SharingRepositoryException(
        'Recipient has not enabled sharing. They need to open Citadel first.',
      );
    }

    // 3. Derive shared key via X25519 ECDH + HKDF.
    final localKeyPair = await getLocalKeyPair();
    final recipientPublicKey = SimplePublicKey(
      base64Decode(recipientPublicKeyBase64),
      type: KeyPairType.x25519,
    );
    final sharedKey = await _crypto.deriveSharedKey(
      localKeyPair: localKeyPair,
      remotePublicKey: recipientPublicKey,
      context: utf8.encode('citadel-share-v1'),
    );

    // 4. Encrypt item data.
    final encryptedBlob = await _crypto.encryptForSharing(itemData, sharedKey);

    // 5. Get sender's public key for the record.
    final senderPublicKey = await localKeyPair.extractPublicKey();
    final senderPublicKeyBase64 = base64Encode(senderPublicKey.bytes);

    // 6. Create PocketBase record.
    await _service.createSharedItem(
      senderId: (await _secureStorage.read(key: 'current_user_id')) ?? '',
      recipientId: recipientId,
      encryptedData: base64Encode(encryptedBlob),
      senderPublicKey: senderPublicKeyBase64,
    );

    // 7. Show local notification confirming share.
    await _notificationService.showSharingNotification(
      title: 'Item Shared',
      body: 'Successfully shared item with $recipientEmail',
      payload: 'sharing:sent',
    );
  }

  /// Get all items shared with the current user (from PocketBase, cached in Drift).
  Future<List<pb_models.SharedItem>> getReceivedItems(String userId) async {
    // Fetch from PocketBase.
    final records = await _service.getReceivedItems(userId);
    final items =
        records.map((r) => pb_models.SharedItem.fromRecord(r)).toList();

    // Cache each item locally in Drift (fire-and-forget).
    for (final item in items) {
      try {
        await _dao.upsertSharedItem(
          SharedItemsCompanion.insert(
            id: item.id,
            senderId: item.senderId,
            recipientId: item.recipientId,
            encryptedData: item.encryptedData,
            senderPublicKey: item.senderPublicKey,
            status: Value(item.status),
            createdAt: item.createdAt,
          ),
        );
      } catch (_) {
        // Caching failure is non-critical.
      }
    }

    return items;
  }

  /// Decrypt a received shared item using the sender's public key.
  ///
  /// Derives the shared secret from the local private key and the
  /// sender's X25519 public key, then decrypts the AES-256-GCM blob.
  Future<Map<String, dynamic>> decryptReceivedItem(
    pb_models.SharedItem item,
  ) async {
    final localKeyPair = await getLocalKeyPair();
    final senderPublicKey = SimplePublicKey(
      base64Decode(item.senderPublicKey),
      type: KeyPairType.x25519,
    );

    final sharedKey = await _crypto.deriveSharedKey(
      localKeyPair: localKeyPair,
      remotePublicKey: senderPublicKey,
      context: utf8.encode('citadel-share-v1'),
    );

    final encryptedBlob =
        Uint8List.fromList(base64Decode(item.encryptedData));
    return _crypto.decryptFromSharing(encryptedBlob, sharedKey);
  }

  /// Accept a shared item (update status to 'accepted').
  Future<void> acceptItem(String itemId) async {
    await _service.updateItemStatus(itemId, 'accepted');
  }

  /// Decline a shared item (update status to 'declined').
  Future<void> declineItem(String itemId) async {
    await _service.updateItemStatus(itemId, 'declined');
  }

  // ---------------------------------------------------------------------------
  // Link Sharing
  // ---------------------------------------------------------------------------

  /// Create a shareable link for a vault item.
  ///
  /// Per D-05: The URL format is `https://citadel.app/share#{base64UrlKey}?id={recordId}`
  /// The decryption key lives ONLY in the URL fragment (never sent to server).
  Future<String> createShareLink({
    required Map<String, dynamic> itemData,
    required Duration ttl,
    required bool oneTimeView,
  }) async {
    // Encrypt with a random AES-256-GCM key.
    final result = await _crypto.encryptForLink(itemData);

    // Create PB record with encrypted blob (no key).
    final expiresAt = DateTime.now().toUtc().add(ttl);
    final record = await _service.createSharedLink(
      encryptedData: base64Encode(result.encryptedBlob),
      creatorId: (await _secureStorage.read(key: 'current_user_id')) ?? '',
      expiresAt: expiresAt,
      oneTimeView: oneTimeView,
    );

    // Build URL with key in fragment (per D-05).
    final base64UrlKey = base64Url.encode(result.keyBytes);
    return 'https://citadel.app/share#$base64UrlKey?id=${record.id}';
  }

  /// Open (decrypt) a shared link using the record ID and key from the URL fragment.
  Future<Map<String, dynamic>> openShareLink(
    String recordId,
    String base64Key,
  ) async {
    // Fetch encrypted blob from PocketBase.
    final record = await _service.getSharedLink(recordId);
    if (record == null) {
      throw SharingRepositoryException(
        'Link has expired or has already been viewed.',
      );
    }

    // Decrypt with the key from the URL fragment.
    final encryptedBlob = Uint8List.fromList(
      base64Decode(record.getStringValue('encryptedData')),
    );
    final keyBytes = Uint8List.fromList(base64Url.decode(base64Key));
    final decrypted = await _crypto.decryptFromLink(encryptedBlob, keyBytes);

    // Mark as viewed (for one-time links).
    await _service.markLinkViewed(recordId);

    return decrypted;
  }

  // ---------------------------------------------------------------------------
  // Real-Time Subscriptions
  // ---------------------------------------------------------------------------

  /// Start listening for new shared items via PocketBase real-time.
  ///
  /// When a new item is received, a local notification is triggered
  /// via [NotificationService].
  Future<void> startListening(String userId) async {
    await _service.subscribeToSharedItems(userId, (event) async {
      if (event.action == 'create') {
        final recipientId = event.record?.getStringValue('recipientId');
        if (recipientId == userId) {
          await _notificationService.showSharingNotification(
            title: 'New Shared Item',
            body: 'Someone shared a credential with you',
            payload: 'sharing:received:${event.record?.id}',
          );
        }
      }
    });
  }

  /// Stop listening for real-time shared item events.
  void stopListening() {
    _service.unsubscribeAll();
  }
}

/// Exception type for [SharingRepository] errors.
class SharingRepositoryException implements Exception {
  final String message;
  const SharingRepositoryException(this.message);

  @override
  String toString() => 'SharingRepositoryException: $message';
}
