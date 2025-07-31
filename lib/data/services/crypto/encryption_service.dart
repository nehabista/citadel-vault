// File: lib/data/services/crypto/encryption_service.dart
import 'dart:convert';
import 'dart:typed_data';
import 'dart:math';
import 'package:encrypter_plus/encrypter_plus.dart' as encrypt_lib;
import 'package:get/get.dart' show GetxService;
import 'package:pointycastle/export.dart';

class EncryptionService extends GetxService {
  static const int _keyLength = 32; 
  static const int _saltLength = 16; 
  static const int _pbkdf2Iterations = 1000000; // one  million iterations

  String generateSecureSalt() {
    final random = Random.secure();
    final saltBytes = List<int>.generate(
      _saltLength,
      (_) => random.nextInt(256),
    );
    return base64.encode(saltBytes);
  }

  encrypt_lib.IV generateIV() {
    return encrypt_lib.IV.fromSecureRandom(16);
  }

  Uint8List deriveKey(String masterPassword, String salt) {
    final keyDerivator = PBKDF2KeyDerivator(
      HMac(SHA256Digest(), 64),
    )..init(
      Pbkdf2Parameters(base64.decode(salt), _pbkdf2Iterations, _keyLength),
    );
    return keyDerivator.process(Uint8List.fromList(utf8.encode(masterPassword)));
  }

  String encrypt(String plainText, Uint8List derivedKey, encrypt_lib.IV iv) {
    final key = encrypt_lib.Key(derivedKey);
    final encrypter = encrypt_lib.Encrypter(
      encrypt_lib.AES(key, mode: encrypt_lib.AESMode.cbc),
    );
    final encrypted = encrypter.encrypt(plainText, iv: iv);
    return '${iv.base64}:${encrypted.base64}';
  }

  String decrypt(String encryptedText, Uint8List derivedKey) {
    final parts = encryptedText.split(':');
    if (parts.length != 2) throw Exception("Invalid encrypted data format.");
    final iv = encrypt_lib.IV.fromBase64(parts[0]);
    final encryptedData = encrypt_lib.Encrypted.fromBase64(parts[1]);
    final key = encrypt_lib.Key(derivedKey);
    final encrypter = encrypt_lib.Encrypter(
      encrypt_lib.AES(key, mode: encrypt_lib.AESMode.cbc),
    );
    return encrypter.decrypt(encryptedData, iv: iv);
  }
}
