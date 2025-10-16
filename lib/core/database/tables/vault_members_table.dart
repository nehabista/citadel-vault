import 'package:drift/drift.dart';

/// Local cache of vault membership records for shared vaults.
/// Mirrors the `vault_members` PocketBase collection.
class VaultMembers extends Table {
  /// PocketBase record ID
  TextColumn get id => text()();

  /// ID of the shared vault
  TextColumn get vaultId => text()();

  /// ID of the member user
  TextColumn get userId => text()();

  /// Role in the vault: owner, editor, viewer
  TextColumn get role =>
      text().withDefault(const Constant('viewer'))();

  /// Base64-encoded vault key encrypted with X25519 shared secret
  TextColumn get encryptedVaultKey => text()();

  /// Base64-encoded X25519 public key of the vault owner
  TextColumn get ownerPublicKey => text()();

  /// When the invitation was sent
  DateTimeColumn get invitedAt => dateTime()();

  /// When the member accepted (null if pending)
  DateTimeColumn get acceptedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
