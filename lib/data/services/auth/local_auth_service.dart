// File: lib/data/services/auth/local_auth_service.dart
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../core/crypto/crypto_engine.dart';

// NOTE: This version uses CryptoEngine (Argon2id + AES-256-GCM) instead of
// the legacy EncryptionService (PBKDF2 + AES-CBC).
// PIN and Biometrics are separate, mutually exclusive quick unlock methods.

enum UnlockMethod { masterPassword, biometrics, pin }

class LocalAuthService {
  final LocalAuthentication _localAuth = LocalAuthentication();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final CryptoEngine _cryptoEngine;

  LocalAuthService({required CryptoEngine cryptoEngine})
      : _cryptoEngine = cryptoEngine;

  static const _unlockMethodKey = 'unlock_method';
  static const _biometricMasterPasswordKey = 'biometric_master_password';
  static const _pinEncryptedMasterPasswordKey = 'pin_encrypted_master_password';
  static const _pinSaltKey = 'pin_salt';
  static const _pinVerificationHashKey = 'pin_verification_hash';

  Future<bool> canUseBiometrics() async {
    return await _localAuth.canCheckBiometrics &&
        await _localAuth.isDeviceSupported();
  }

  Future<UnlockMethod> getSavedUnlockMethod() async {
    final method = await _secureStorage.read(key: _unlockMethodKey);
    if (method == 'biometrics') return UnlockMethod.biometrics;
    if (method == 'pin') return UnlockMethod.pin;
    return UnlockMethod.masterPassword;
  }

  /// Returns true if the user has set up PIN or biometrics.
  Future<bool> hasQuickUnlockSetup() async {
    final method = await getSavedUnlockMethod();
    return method != UnlockMethod.masterPassword;
  }

  Future<bool> enableBiometricUnlock(String masterPassword) async {
    try {
      final didAuth = await _localAuth.authenticate(
          localizedReason: 'Authenticate to enable quick unlock',
          options: const AuthenticationOptions(biometricOnly: true));
      if (didAuth) {
        await disableQuickUnlock();
        await _secureStorage.write(
            key: _biometricMasterPasswordKey, value: masterPassword);
        await _secureStorage.write(
            key: _unlockMethodKey, value: 'biometrics');
        return true;
      }
      return false;
    } on PlatformException {
      return false;
    }
  }

  Future<void> enablePinUnlock(String pin, String masterPassword) async {
    await disableQuickUnlock();

    // Use CryptoEngine to derive a key from the PIN for verification.
    final pinVerificationSalt = _cryptoEngine.generateSalt();
    final pinKey = await _cryptoEngine.deriveKey(
      pin,
      pinVerificationSalt,
    );
    final pinKeyBytes = await pinKey.extractBytes();
    final storedHash =
        '${base64.encode(pinVerificationSalt)}:${base64.encode(pinKeyBytes)}';

    // Derive a separate key from PIN to encrypt the master password.
    final pinEncryptionSalt = _cryptoEngine.generateSalt();
    final encryptionKey = await _cryptoEngine.deriveKey(
      pin,
      pinEncryptionSalt,
    );
    final encryptedMasterPassword = await _cryptoEngine.encrypt(
      Uint8List.fromList(utf8.encode(masterPassword)),
      encryptionKey,
    );

    await _secureStorage.write(
        key: _pinVerificationHashKey, value: storedHash);
    await _secureStorage.write(
        key: _pinSaltKey, value: base64.encode(pinEncryptionSalt));
    await _secureStorage.write(
        key: _pinEncryptedMasterPasswordKey,
        value: base64.encode(encryptedMasterPassword));
    await _secureStorage.write(key: _unlockMethodKey, value: 'pin');
  }

  Future<String?> authenticateWithBiometrics() async {
    try {
      final didAuthenticate = await _localAuth.authenticate(
        localizedReason: 'Unlock Citadel',
        options: const AuthenticationOptions(biometricOnly: true),
      );
      if (didAuthenticate) {
        return await _secureStorage.read(key: _biometricMasterPasswordKey);
      }
      return null;
    } on PlatformException {
      return null;
    }
  }

  Future<String?> authenticateWithPin(String pin) async {
    // Verify the PIN by re-deriving the key and comparing.
    final storedHash =
        await _secureStorage.read(key: _pinVerificationHashKey);
    if (storedHash == null) return null;

    final parts = storedHash.split(':');
    if (parts.length != 2) return null;
    final verificationSalt = base64.decode(parts[0]);
    final expectedHashBytes = base64.decode(parts[1]);

    final enteredPinKey = await _cryptoEngine.deriveKey(pin, verificationSalt);
    final enteredPinKeyBytes = await enteredPinKey.extractBytes();

    // Constant-time comparison.
    bool match = expectedHashBytes.length == enteredPinKeyBytes.length;
    for (int i = 0; i < expectedHashBytes.length && i < enteredPinKeyBytes.length; i++) {
      if (expectedHashBytes[i] != enteredPinKeyBytes[i]) match = false;
    }
    if (!match) return null;

    // Decrypt the master password using the PIN-derived encryption key.
    final pinEncryptionSaltB64 =
        await _secureStorage.read(key: _pinSaltKey);
    final encryptedMasterPasswordB64 =
        await _secureStorage.read(key: _pinEncryptedMasterPasswordKey);
    if (pinEncryptionSaltB64 == null || encryptedMasterPasswordB64 == null) {
      return null;
    }

    final pinEncryptionSalt = base64.decode(pinEncryptionSaltB64);
    final encryptedMasterPassword = base64.decode(encryptedMasterPasswordB64);

    final decryptionKey =
        await _cryptoEngine.deriveKey(pin, pinEncryptionSalt);
    final decryptedBytes =
        await _cryptoEngine.decrypt(encryptedMasterPassword, decryptionKey);
    return utf8.decode(decryptedBytes);
  }

  Future<void> disableQuickUnlock() async {
    await _secureStorage.delete(key: _unlockMethodKey);
    await _secureStorage.delete(key: _biometricMasterPasswordKey);
    await _secureStorage.delete(key: _pinEncryptedMasterPasswordKey);
    await _secureStorage.delete(key: _pinVerificationHashKey);
    await _secureStorage.delete(key: _pinSaltKey);
  }
}
