// File: lib/data/services/auth/auth_service.dart
import 'dart:developer' show log;
import 'dart:typed_data';

import 'package:pocketbase/pocketbase.dart';

import '../../../utils/dicebear_avatar/preset_gen_dicebear.dart';
import '../../models/user_model.dart';
import '../crypto/encryption_service.dart';
import 'local_auth_service.dart';
import 'session_service.dart';

/// Handles all user authentication flows.
/// Plain Dart class -- no GetX dependency.
class AuthService {
  final PocketBase pb;
  final EncryptionService encryptionService;
  final SessionService sessionService;
  final LocalAuthService localAuthService;

  AuthService({
    required this.pb,
    required this.encryptionService,
    required this.sessionService,
    required this.localAuthService,
  });

  UserModel? currentUser;

  bool get isLoggedIn => pb.authStore.isValid;

  void loadCurrentUser() {
    if (pb.authStore.isValid && pb.authStore.record != null) {
      currentUser = UserModel.fromRecord(pb.authStore.record!);
    }
  }

  Future<void> register({
    required String name,
    required String email,
    required String accountPassword,
    required String masterPassword,
  }) async {
    final salt = encryptionService.generateSecureSalt();
    final pngUrl =
        AvatarPresets.colorfulRoundedAvatar(seed: email).buildPngUrl();
    final body = <String, dynamic>{
      "email": email,
      "emailVisibility": true,
      "password": accountPassword,
      "passwordConfirm": accountPassword,
      "name": name,
      "salt": salt,
      "avatar": pngUrl,
      "usesSecretKey": false,
    };
    log(body.toString());

    await pb.collection('users').create(body: body);
    await pb.collection('users').requestVerification(email);
  }

  Future<void> loginWithMasterPassword({
    required String email,
    required String password,
    required String masterPassword,
  }) async {
    final authData =
        await pb.collection('users').authWithPassword(email, password);
    currentUser = UserModel.fromRecord(authData.record);
    final salt = currentUser!.salt;
    final Uint8List derivedKey = encryptionService.deriveKey(
      masterPassword,
      salt,
    );
    sessionService.startSession(derivedKey);
  }

  Future<void> markQuickUnlockAsComplete() async {
    if (currentUser == null) {
      throw Exception("Cannot mark setup as complete. User not logged in.");
    }
    await pb
        .collection('users')
        .update(currentUser!.id, body: {'isQuickUnlockSetup': true});
    currentUser = UserModel(
      id: currentUser!.id,
      email: currentUser!.email,
      name: currentUser!.name,
      salt: currentUser!.salt,
      avatarUrl: currentUser!.avatarUrl,
      isQuickUnlockSetup: true,
    );
  }

  /// Returns the master password on success (for Riverpod session unlock), null on failure.
  Future<String?> unlockWithBiometrics() async {
    if (currentUser == null) return null;
    final masterPassword = await localAuthService.authenticateWithBiometrics();
    if (masterPassword != null) {
      final salt = currentUser!.salt;
      final Uint8List derivedKey = encryptionService.deriveKey(
        masterPassword,
        salt,
      );
      sessionService.startSession(derivedKey);
      return masterPassword;
    }
    return null;
  }

  /// Returns the master password on success, null on failure.
  Future<String?> unlockWithPin(String pin) async {
    if (currentUser == null) return null;
    final masterPassword = await localAuthService.authenticateWithPin(pin);
    if (masterPassword != null) {
      final salt = currentUser!.salt;
      final Uint8List derivedKey = encryptionService.deriveKey(
        masterPassword,
        salt,
      );
      sessionService.startSession(derivedKey);
      return masterPassword;
    }
    return null;
  }

  Future<void> resendVerification(String email) async {
    await pb.collection('users').requestVerification(email);
  }

  void logout() {
    pb.authStore.clear();
    sessionService.endSession();
    currentUser = null;
  }
}
