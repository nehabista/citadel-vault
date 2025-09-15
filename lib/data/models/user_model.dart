import 'package:pocketbase/pocketbase.dart';

/// Represents a user of the Citadel application.
/// This model holds non-sensitive user data fetched from the server.
///
/// PocketBase `users` collection fields:
///   id, created, updated, username, email, emailVisibility, verified,
///   name, salt, avatar, usesSecretKey
class UserModel {
  final String id;
  final String email;
  final String name;
  final String salt;
  final String avatarUrl;
  final bool usesSecretKey;

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    required this.salt,
    required this.avatarUrl,
    this.usesSecretKey = false,
  });

  /// Creates a UserModel instance from a PocketBase RecordModel.
  factory UserModel.fromRecord(RecordModel record) {
    return UserModel(
      id: record.id,
      email: record.getStringValue('email'),
      name: record.getStringValue('name'),
      salt: record.getStringValue('salt'),
      avatarUrl: record.getStringValue('avatar'),
      usesSecretKey: record.getBoolValue('usesSecretKey'),
    );
  }
}
