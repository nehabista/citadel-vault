// File: lib/data/services/auth/local_auth_service.dart
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../crypto/encryption_service.dart';

// NOTE: This version uses a simpler, more direct security model where
// PIN and Biometrics are separate, mutually exclusive quick unlock methods.

enum UnlockMethod { masterPassword, biometrics, pin }

class LocalAuthService {
  final LocalAuthentication _localAuth = LocalAuthentication();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final EncryptionService _encryptionService;

  LocalAuthService({required EncryptionService encryptionService})
      : _encryptionService = encryptionService;

  static const _unlockMethodKey = 'unlock_method';
  static const _biometricMasterPasswordKey = 'biometric_master_password';
  static const _pinEncryptedMasterPasswordKey = 'pin_encrypted_master_password';
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
    final pinVerificationSalt = _encryptionService.generateSecureSalt();
    final pinHash = _encryptionService.deriveKey(pin, pinVerificationSalt);
    final storedHash = '$pinVerificationSalt:${base64.encode(pinHash)}';
    final pinEncryptionSalt = _encryptionService.generateSecureSalt();
    final pinDerivedKey = _encryptionService.deriveKey(pin, pinEncryptionSalt);
    final iv = _encryptionService.generateIV();
    final encryptedMasterPassword =
        _encryptionService.encrypt(masterPassword, pinDerivedKey, iv);
    await _secureStorage.write(
        key: _pinVerificationHashKey, value: storedHash);
    await _secureStorage.write(
        key: _pinEncryptedMasterPasswordKey,
        value: '$pinEncryptionSalt:$encryptedMasterPassword');
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
    final storedHash =
        await _secureStorage.read(key: _pinVerificationHashKey);
    if (storedHash == null) return null;
    final parts = storedHash.split(':');
    final salt = parts[0];
    final expectedHashBytes = base64.decode(parts[1]);
    final enteredPinHashBytes = _encryptionService.deriveKey(pin, salt);
    bool match = true;
    if (expectedHashBytes.length != enteredPinHashBytes.length) match = false;
    for (int i = 0; i < expectedHashBytes.length; i++) {
      if (expectedHashBytes[i] != enteredPinHashBytes[i]) match = false;
    }
    if (!match) return null;
    final storedEncryptedMasterPassword =
        await _secureStorage.read(key: _pinEncryptedMasterPasswordKey);
    if (storedEncryptedMasterPassword == null) return null;
    final encryptionParts = storedEncryptedMasterPassword.split(':');
    final pinEncryptionSalt = encryptionParts[0];
    final encryptedData = '${encryptionParts[1]}:${encryptionParts[2]}';
    final pinDerivedKey =
        _encryptionService.deriveKey(pin, pinEncryptionSalt);
    return _encryptionService.decrypt(encryptedData, pinDerivedKey);
  }

  Future<void> disableQuickUnlock() async {
    await _secureStorage.delete(key: _unlockMethodKey);
    await _secureStorage.delete(key: _biometricMasterPasswordKey);
    await _secureStorage.delete(key: _pinEncryptedMasterPasswordKey);
    await _secureStorage.delete(key: _pinVerificationHashKey);
  }
}
