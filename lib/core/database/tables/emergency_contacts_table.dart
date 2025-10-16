import 'package:drift/drift.dart';

/// Local cache of emergency contact relationships.
/// Mirrors the `emergency_contacts` PocketBase collection.
class EmergencyContacts extends Table {
  /// PocketBase record ID
  TextColumn get id => text()();

  /// ID of the user granting emergency access
  TextColumn get grantorId => text()();

  /// ID of the trusted person who can request access
  TextColumn get granteeId => text()();

  /// Days the grantor has to reject before access is granted (1-30)
  IntColumn get waitingPeriodDays =>
      integer().withDefault(const Constant(7))();

  /// Status: pending, active, waiting, rejected, revoked
  TextColumn get status =>
      text().withDefault(const Constant('pending'))();

  /// Base64-encoded vault key (only populated after waiting period elapses)
  TextColumn get encryptedVaultKey => text().nullable()();

  /// Base64-encoded X25519 public key of the grantee
  TextColumn get granteePublicKey => text().nullable()();

  /// When the grantee requested emergency access
  DateTimeColumn get requestedAt => dateTime().nullable()();

  /// When the emergency contact relationship was created
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
