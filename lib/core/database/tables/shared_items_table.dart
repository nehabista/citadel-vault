import 'package:drift/drift.dart';

/// Local cache of shared items received from or sent to other users.
/// Mirrors the `shared_items` PocketBase collection for offline access.
class SharedItems extends Table {
  /// PocketBase record ID
  TextColumn get id => text()();

  /// ID of the user who shared the item
  TextColumn get senderId => text()();

  /// ID of the user receiving the shared item
  TextColumn get recipientId => text()();

  /// Base64-encoded AES-256-GCM encrypted item data
  TextColumn get encryptedData => text()();

  /// Base64-encoded X25519 public key of the sender
  TextColumn get senderPublicKey => text()();

  /// When the share was created
  DateTimeColumn get createdAt => dateTime()();

  /// Optional expiration time
  DateTimeColumn get expiresAt => dateTime().nullable()();

  /// Share status: pending, accepted, declined
  TextColumn get status =>
      text().withDefault(const Constant('pending'))();

  @override
  Set<Column> get primaryKey => {id};
}
