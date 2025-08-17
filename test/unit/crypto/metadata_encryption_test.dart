import 'dart:convert';

import 'package:cryptography/cryptography.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:citadel_password_manager/core/crypto/crypto_engine.dart';
import 'package:citadel_password_manager/core/crypto/crypto_migration.dart';
import 'package:citadel_password_manager/core/crypto/legacy_crypto.dart';

void main() {
  late LegacyCrypto legacyCrypto;
  late CryptoEngine cryptoEngine;
  late SecretKey v1Key;
  late SecretKey v2Key;

  setUpAll(() async {
    legacyCrypto = LegacyCrypto();
    cryptoEngine = CryptoEngine();

    v1Key = await legacyCrypto.deriveKey(
      'test-password',
      base64.encode([1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16]),
    );
    v2Key = await cryptoEngine.deriveKey(
      'test-password',
      [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16],
    );
  });

  group('Metadata encryption after migration (D-11)', () {
    test('v2 blob contains type, favorite, folder fields that were plaintext in v1', () async {
      // In v1, only these fields were encrypted
      final v1EncryptedFields = {
        'name': 'My WiFi Password',
        'username': '',
        'password': 'wifi-secret-key',
        'url': '',
        'notes': 'Home network',
      };

      final v1Encrypted = await legacyCrypto.encryptForTesting(
        jsonEncode(v1EncryptedFields),
        v1Key,
      );

      // These fields were stored as PLAINTEXT on PocketBase records in v1
      final plaintextMetadata = {
        'type': 'wifiPassword',
        'favorite': true,
        'folder': 'home-network',
      };

      final migration = CryptoMigration(
        legacyCrypto: legacyCrypto,
        cryptoEngine: cryptoEngine,
      );

      final v2Blob = await migration.migrateItemData(
        v1EncryptedString: v1Encrypted,
        v1Key: v1Key,
        v2Key: v2Key,
        plaintextMetadata: plaintextMetadata,
      );

      // Decrypt v2 blob and verify ALL metadata is now encrypted
      final decrypted = await cryptoEngine.decryptFields(v2Blob, v2Key);

      // Original encrypted fields preserved
      expect(decrypted['name'], equals('My WiFi Password'));
      expect(decrypted['username'], equals(''));
      expect(decrypted['password'], equals('wifi-secret-key'));
      expect(decrypted['url'], equals(''));
      expect(decrypted['notes'], equals('Home network'));

      // Previously plaintext metadata now encrypted in v2 blob
      expect(decrypted['type'], equals('wifiPassword'));
      expect(decrypted['favorite'], equals(true));
      expect(decrypted['folder'], equals('home-network'));
    });

    test('all VaultItemType values are preserved through migration', () async {
      final types = [
        'password',
        'secureNote',
        'contactInfo',
        'bankAccount',
        'paymentCard',
        'wifiPassword',
        'softwareLicense',
      ];

      final migration = CryptoMigration(
        legacyCrypto: legacyCrypto,
        cryptoEngine: cryptoEngine,
      );

      for (final itemType in types) {
        final v1Encrypted = await legacyCrypto.encryptForTesting(
          jsonEncode({'name': 'Test $itemType', 'password': 'pass'}),
          v1Key,
        );

        final v2Blob = await migration.migrateItemData(
          v1EncryptedString: v1Encrypted,
          v1Key: v1Key,
          v2Key: v2Key,
          plaintextMetadata: {
            'type': itemType,
            'favorite': false,
            'folder': '',
          },
        );

        final decrypted = await cryptoEngine.decryptFields(v2Blob, v2Key);
        expect(decrypted['type'], equals(itemType),
            reason: 'Type "$itemType" was not preserved through migration');
      }
    });

    test('CryptoEngine.decryptFields returns all metadata fields after migration', () async {
      final v1Encrypted = await legacyCrypto.encryptForTesting(
        jsonEncode({
          'name': 'Complete Item',
          'username': 'complete-user',
          'password': 'complete-pass',
          'url': 'https://complete.example.com',
          'notes': 'Complete notes with special chars: <>!@#',
        }),
        v1Key,
      );

      final migration = CryptoMigration(
        legacyCrypto: legacyCrypto,
        cryptoEngine: cryptoEngine,
      );

      final v2Blob = await migration.migrateItemData(
        v1EncryptedString: v1Encrypted,
        v1Key: v1Key,
        v2Key: v2Key,
        plaintextMetadata: {
          'type': 'password',
          'favorite': true,
          'folder': 'work/engineering',
        },
      );

      final decrypted = await cryptoEngine.decryptFields(v2Blob, v2Key);

      // Verify ALL expected fields are present
      final requiredFields = [
        'name',
        'username',
        'password',
        'url',
        'notes',
        'type',
        'favorite',
        'folder',
      ];

      for (final field in requiredFields) {
        expect(decrypted.containsKey(field), isTrue,
            reason: 'Missing required field: $field');
      }
    });

    test('favorite boolean value is preserved correctly', () async {
      final migration = CryptoMigration(
        legacyCrypto: legacyCrypto,
        cryptoEngine: cryptoEngine,
      );

      for (final favValue in [true, false]) {
        final v1Encrypted = await legacyCrypto.encryptForTesting(
          jsonEncode({'name': 'Fav test', 'password': 'p'}),
          v1Key,
        );

        final v2Blob = await migration.migrateItemData(
          v1EncryptedString: v1Encrypted,
          v1Key: v1Key,
          v2Key: v2Key,
          plaintextMetadata: {
            'type': 'password',
            'favorite': favValue,
            'folder': '',
          },
        );

        final decrypted = await cryptoEngine.decryptFields(v2Blob, v2Key);
        expect(decrypted['favorite'], equals(favValue),
            reason: 'favorite=$favValue was not preserved');
        // Verify it's actually a bool, not a string
        expect(decrypted['favorite'], isA<bool>());
      }
    });
  });
}
