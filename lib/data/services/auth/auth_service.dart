// File: lib/data/services/auth/auth_service.dart
import 'dart:convert';
import 'dart:developer' show log;

import 'package:pocketbase/pocketbase.dart';

import '../../../core/crypto/crypto_engine.dart';
import '../../../utils/dicebear_avatar/preset_gen_dicebear.dart';
import '../../models/user_model.dart';
import 'local_auth_service.dart';

/// Handles all user authentication flows.
/// Uses CryptoEngine (Argon2id + AES-256-GCM) for key derivation.
class AuthService {
  final PocketBase pb;
  final CryptoEngine cryptoEngine;
  final LocalAuthService localAuthService;

  AuthService({
    required this.pb,
    required this.cryptoEngine,
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
    // Generate a salt using CryptoEngine and encode as base64.
    final saltBytes = cryptoEngine.generateSalt();
    final salt = base64.encode(saltBytes);
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
    // Key derivation now handled by SessionNotifier.unlock() in the auth provider.
    // AuthService just authenticates with PocketBase and loads the user record.
  }

  /// Returns the master password on success (for Riverpod session unlock), null on failure.
  Future<String?> unlockWithBiometrics() async {
    if (currentUser == null) return null;
    return localAuthService.authenticateWithBiometrics();
  }

  /// Returns the master password on success, null on failure.
  Future<String?> unlockWithPin(String pin) async {
    if (currentUser == null) return null;
    return localAuthService.authenticateWithPin(pin);
  }

  Future<void> resendVerification(String email) async {
    await pb.collection('users').requestVerification(email);
  }

  void logout() {
    pb.authStore.clear();
    currentUser = null;
  }
}
