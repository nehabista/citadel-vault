// File: lib/data/services/auth/auth_service.dart
import 'dart:developer' show log;
import 'dart:typed_data';

import 'package:get/get.dart';
import 'package:pocketbase/pocketbase.dart';

import '../../../utils/dicebear_avatar/preset_gen_dicebear.dart';
import '../../models/user_model.dart';
import '../api/pocketbase_service.dart';
import '../crypto/encryption_service.dart';
import 'local_auth_service.dart';
import 'session_service.dart';

/// Handles all user authentication flows, including registration with name,
/// login, logout, and managing the current user's session data.
class AuthService extends GetxService {
  final PocketBase _pb = Get.find<PocketBaseService>().client;
  final EncryptionService _encryptionService = Get.find<EncryptionService>();
  final SessionService _sessionService = Get.find<SessionService>();
  final LocalAuthService _localAuthService = Get.find<LocalAuthService>();

  // Holds the current logged-in user's data.
  final Rx<UserModel?> currentUser = Rx<UserModel?>(null);

  bool get isLoggedIn => _pb.authStore.isValid;

  void loadCurrentUser() {
    if (_pb.authStore.isValid) {
      currentUser.value = UserModel.fromRecord(_pb.authStore.record!);
    }
  }

  Future<void> register({
    required String name,
    required String email,
    required String accountPassword,
    required String masterPassword,
  }) async {
    final salt = _encryptionService.generateSecureSalt();
    // Generate a unique avatar seed based on the email
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

    await _pb.collection('users').create(body: body);
    await _pb.collection('users').requestVerification(email);

    // await loginWithMasterPassword(
    //   email: email,
    //   password: accountPassword,
    //   masterPassword: masterPassword,
    // );
  }

  Future<void> loginWithMasterPassword({
    required String email,
    required String password,
    required String masterPassword,
  }) async {
    final authData = await _pb
        .collection('users')
        .authWithPassword(email, password);
    currentUser.value = UserModel.fromRecord(authData.record);
    final salt = currentUser.value!.salt;
    final Uint8List derivedKey = _encryptionService.deriveKey(
      masterPassword,
      salt,
    );

    _sessionService.startSession(derivedKey);
  }

  Future<void> markQuickUnlockAsComplete() async {
    if (currentUser.value == null) {
      throw Exception("Cannot mark setup as complete. User not logged in.");
    }
    await _pb
        .collection('users')
        .update(currentUser.value!.id, body: {'isQuickUnlockSetup': true});
    // Refresh the local user model to reflect the change
    currentUser.update((user) {
      if (user != null) {
        // This is a bit of a workaround since we can't easily recreate the model
        // A better approach might be to refetch the user record, but this is efficient.
        final updatedUser = UserModel(
          id: user.id,
          email: user.email,
          name: user.name,
          salt: user.salt,
          avatarUrl: user.avatarUrl,
          isQuickUnlockSetup: true, // Manually update the flag
        );
        currentUser.value = updatedUser;
      }
    });
  }

  Future<bool> unlockWithBiometrics() async {
    if (currentUser.value == null) {
      return false; // Can't unlock if not logged in before
    }
    final masterPassword = await _localAuthService.authenticateWithBiometrics();
    if (masterPassword != null) {
      final salt = currentUser.value!.salt;
      final Uint8List derivedKey = _encryptionService.deriveKey(
        masterPassword,
        salt,
      );
      _sessionService.startSession(derivedKey);
      return true;
    }
    return false;
  }

  Future<bool> unlockWithPin(String pin) async {
    if (currentUser.value == null) return false;
    final masterPassword = await _localAuthService.authenticateWithPin(pin);
    if (masterPassword != null) {
      final salt = currentUser.value!.salt;
      final Uint8List derivedKey = _encryptionService.deriveKey(
        masterPassword,
        salt,
      );
      _sessionService.startSession(derivedKey);
      return true;
    }
    return false;
  }

  /// A new method to allow users to resend the verification email.
  Future<void> resendVerification(String email) async {
    await _pb.collection('users').requestVerification(email);
  }

  void logout() {
    _pb.authStore.clear();
    _sessionService.endSession();
    currentUser.value = null;
  }
}
