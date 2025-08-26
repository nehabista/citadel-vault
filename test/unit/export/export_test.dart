import 'dart:convert';

import 'package:citadel_password_manager/core/crypto/crypto_engine.dart';
import 'package:citadel_password_manager/features/import_export/data/services/export_service.dart';
import 'package:citadel_password_manager/features/import_export/data/services/import_service.dart';
import 'package:citadel_password_manager/features/vault/domain/entities/vault_item.dart';
import 'package:citadel_password_manager/features/vault/domain/repositories/vault_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late ExportService exportService;
  late CryptoEngine crypto;

  setUp(() {
    crypto = CryptoEngine();
    exportService = ExportService(crypto: crypto);
  });

  final testItems = [
    VaultItemEntity(
      id: 'item-1',
      vaultId: 'vault-1',
      name: 'GitHub',
      url: 'https://github.com',
      username: 'dev@test.com',
      password: 'secret123',
      notes: 'Dev account',
      type: VaultItemType.password,
      createdAt: DateTime(2024, 1, 15),
      updatedAt: DateTime(2024, 6, 20),
    ),
    VaultItemEntity(
      id: 'item-2',
      vaultId: 'vault-1',
      name: 'Google',
      url: 'https://google.com',
      username: 'user@gmail.com',
      password: 'gpass456',
      notes: null,
      type: VaultItemType.password,
      createdAt: DateTime(2024, 3, 10),
      updatedAt: DateTime(2024, 3, 10),
    ),
  ];

  group('CSV Export', () {
    test('produces valid CSV with correct headers', () async {
      final bytes = await exportService.exportCsv(testItems);
      final csvString = utf8.decode(bytes);
      final lines = csvString.split('\n');

      expect(lines[0].trim(), 'name,url,username,password,notes,type');
    });

    test('produces correct data rows', () async {
      final bytes = await exportService.exportCsv(testItems);
      final csvString = utf8.decode(bytes);
      final lines = csvString.split('\n');

      // Second line should be first item
      expect(lines[1], contains('GitHub'));
      expect(lines[1], contains('https://github.com'));
      expect(lines[1], contains('dev@test.com'));
      expect(lines[1], contains('secret123'));
      expect(lines[1], contains('Dev account'));
      expect(lines[1], contains('password'));
    });

    test('exports correct number of rows', () async {
      final bytes = await exportService.exportCsv(testItems);
      final csvString = utf8.decode(bytes);
      final lines =
          csvString.split('\n').where((l) => l.trim().isNotEmpty).toList();

      // 1 header + 2 data rows
      expect(lines.length, 3);
    });
  });

  group('Encrypted Backup', () {
    test('round-trip: export then import produces same data', () async {
      final backupPassword = 'TestBackup!2024';

      // Export
      final encrypted = await exportService.exportEncryptedBackup(
        testItems,
        backupPassword,
      );

      // Verify it's not empty and starts with salt
      expect(encrypted.length, greaterThan(16));

      // Import
      final importService = ImportService(
        repository: _NoOpVaultRepository(),
      );
      final restored = await importService.parseEncryptedBackup(
        encrypted,
        backupPassword,
        crypto,
      );

      expect(restored, hasLength(2));
      expect(restored[0].name, 'GitHub');
      expect(restored[0].url, 'https://github.com');
      expect(restored[0].username, 'dev@test.com');
      expect(restored[0].password, 'secret123');
      expect(restored[1].name, 'Google');
      expect(restored[1].username, 'user@gmail.com');
    });

    test('wrong password fails to decrypt', () async {
      final encrypted = await exportService.exportEncryptedBackup(
        testItems,
        'CorrectPassword!',
      );

      final importService = ImportService(
        repository: _NoOpVaultRepository(),
      );

      expect(
        () => importService.parseEncryptedBackup(
          encrypted,
          'WrongPassword!',
          crypto,
        ),
        throwsA(anything),
      );
    });
  });
}

/// Minimal no-op repository for testing import service without a database.
class _NoOpVaultRepository implements VaultRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}
