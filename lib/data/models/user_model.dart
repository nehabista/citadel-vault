import 'package:pocketbase/pocketbase.dart';

/// Represents a user of the Citadel application.
/// This model holds non-sensitive user data fetched from the server.
class UserModel {
  final String id;
  final String email;
  final String name;
  final String salt;
  final String avatarUrl;
  final bool isQuickUnlockSetup;

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    required this.salt,
    required this.avatarUrl,
    required this.isQuickUnlockSetup,
  });

  /// Creates a UserModel instance from a PocketBase RecordModel.
  factory UserModel.fromRecord(RecordModel record) {
    return UserModel(
      id: record.id,
      email: record.getStringValue('email'),
      name: record.getStringValue('name'),
      salt: record.getStringValue('salt'),
      avatarUrl: record.getStringValue('avatar'),
      isQuickUnlockSetup: record.getBoolValue('isQuickUnlockSetup'),
    );
  }
}
