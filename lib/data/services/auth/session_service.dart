// File: lib/data/services/auth/session_service.dart
import 'dart:typed_data';
import 'package:get/get.dart';

class SessionService extends GetxService {
  Uint8List? _encryptionKey;
  bool get isVaultUnlocked => _encryptionKey != null;

  Uint8List get encryptionKey {
    if (!isVaultUnlocked || _encryptionKey == null) {
      throw Exception("Vault is locked. No encryption key available.");
    }
    return _encryptionKey!;
  }

  void startSession(Uint8List key) {
    _encryptionKey = key;
  }

  void endSession() {
    _encryptionKey = null;
  }
}
