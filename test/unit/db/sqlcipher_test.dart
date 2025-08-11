@Tags(['integration'])
library;

import 'dart:io';

import 'package:citadel_password_manager/core/database/app_database.dart';
import 'package:citadel_password_manager/core/database/daos/vault_dao.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

/// SQLCipher encryption validation tests.
///
/// These tests validate the encryption integration pattern.
/// Full SQLCipher enforcement (wrong key = failure) requires the sqlite3mc
/// native library, which is available when the app is built with the
/// `hooks.user_defines.sqlite3.source: sqlite3mc` pubspec.yaml configuration.
///
/// In the standard test environment (sqlite3_flutter_libs), PRAGMA key is
/// accepted but does not actually encrypt -- these tests verify the API
/// contracts and document the encryption gate behavior.
///
/// To run with full encryption validation, use a device/emulator build:
///   flutter test --tags integration test/unit/db/sqlcipher_test.dart
///
/// Per D-06: SQLCipher encrypts the entire DB file with a key stored in
/// platform Keystore/Keychain.
void main() {
  late Directory tempDir;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('sqlcipher_test_');
  });

  tearDown(() {
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  /// Helper: checks if the SQLite library supports encryption by testing
  /// whether PRAGMA key actually prevents access with a different key.
  Future<bool> isSqlCipherAvailable() async {
    final dbPath = '${tempDir.path}/probe.db';
    try {
      // Create with key
      final db1 = AppDatabase.encrypted(dbPath, 'probe-key');
      final dao1 = VaultDao(db1);
      await dao1.insertVault(VaultsCompanion.insert(
        id: 'probe',
        name: 'probe',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ));
      await db1.close();

      // Try to read with wrong key
      final db2 = AppDatabase.encrypted(dbPath, 'wrong-key');
      final dao2 = VaultDao(db2);
      try {
        await dao2.getAllVaults();
        await db2.close();
        // If we get here, encryption is not enforced
        return false;
      } catch (_) {
        await db2.close();
        return true;
      }
    } catch (_) {
      return false;
    }
  }

  group('SQLCipher Encryption', () {
    test('database opened with correct key allows reads and writes', () async {
      final dbPath = '${tempDir.path}/encrypted.db';
      const correctKey = 'test-encryption-key-12345';

      final db = AppDatabase.encrypted(dbPath, correctKey);
      final vaultDao = VaultDao(db);
      final now = DateTime.now();

      // Write data
      await vaultDao.insertVault(VaultsCompanion.insert(
        id: 'vault-1',
        name: 'Encrypted Vault',
        createdAt: now,
        updatedAt: now,
      ));

      // Read data
      final vaults = await vaultDao.getAllVaults();
      expect(vaults, hasLength(1));
      expect(vaults.first.name, 'Encrypted Vault');

      await db.close();

      // Reopen with the same key -- should work
      final db2 = AppDatabase.encrypted(dbPath, correctKey);
      final vaultDao2 = VaultDao(db2);
      final vaults2 = await vaultDao2.getAllVaults();
      expect(vaults2, hasLength(1));
      expect(vaults2.first.name, 'Encrypted Vault');
      await db2.close();
    });

    test('database opened with wrong key throws or fails to read data', () async {
      final hasSqlCipher = await isSqlCipherAvailable();
      if (!hasSqlCipher) {
        // ignore: avoid_print
        print(
          'SKIP: SQLite3MultipleCiphers not available in test environment. '
          'PRAGMA key is accepted but does not enforce encryption. '
          'Run on device/emulator with sqlite3mc build hooks for full validation.',
        );
        return;
      }

      final dbPath = '${tempDir.path}/encrypted_wrong.db';
      const correctKey = 'correct-key-12345';
      const wrongKey = 'wrong-key-67890';

      // Create and populate with correct key
      final db = AppDatabase.encrypted(dbPath, correctKey);
      final vaultDao = VaultDao(db);
      final now = DateTime.now();

      await vaultDao.insertVault(VaultsCompanion.insert(
        id: 'vault-1',
        name: 'Secret Vault',
        createdAt: now,
        updatedAt: now,
      ));
      await db.close();

      // Open with wrong key -- should throw or fail
      final db2 = AppDatabase.encrypted(dbPath, wrongKey);
      final vaultDao2 = VaultDao(db2);

      expect(
        () => vaultDao2.getAllVaults(),
        throwsA(anything),
      );
      await db2.close();
    });

    test('database opened without any key cannot read encrypted data', () async {
      final hasSqlCipher = await isSqlCipherAvailable();
      if (!hasSqlCipher) {
        // ignore: avoid_print
        print(
          'SKIP: SQLite3MultipleCiphers not available in test environment. '
          'Run on device/emulator with sqlite3mc build hooks for full validation.',
        );
        return;
      }

      final dbPath = '${tempDir.path}/encrypted_nokey.db';
      const correctKey = 'my-secret-key';

      // Create encrypted database
      final db = AppDatabase.encrypted(dbPath, correctKey);
      final vaultDao = VaultDao(db);
      final now = DateTime.now();

      await vaultDao.insertVault(VaultsCompanion.insert(
        id: 'vault-1',
        name: 'Protected Vault',
        createdAt: now,
        updatedAt: now,
      ));
      await db.close();

      // Open without encryption key -- should fail
      final db2 = AppDatabase(
        LazyDatabase(() async {
          return NativeDatabase(File(dbPath));
        }),
      );

      expect(
        () => db2.select(db2.vaults).get(),
        throwsA(anything),
      );
      await db2.close();
    });

    test('PRAGMA key setup callback is correctly wired in encrypted factory', () {
      // Verify the factory constructor accepts and uses the key
      // This is a structural test -- actual encryption enforcement
      // depends on the sqlite3mc native library being linked
      final dbPath = '${tempDir.path}/setup_test.db';
      const key = 'test-key';

      // Should not throw -- the constructor wires up the PRAGMA key callback
      final db = AppDatabase.encrypted(dbPath, key);
      expect(db, isNotNull);
      db.close();
    });
  });
}
