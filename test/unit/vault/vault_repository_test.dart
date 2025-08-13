import 'dart:async';
import 'dart:typed_data';

import 'package:citadel_password_manager/core/crypto/crypto_engine.dart';
import 'package:citadel_password_manager/core/database/app_database.dart';
import 'package:citadel_password_manager/core/database/daos/sync_dao.dart';
import 'package:citadel_password_manager/core/database/daos/vault_dao.dart';
import 'package:citadel_password_manager/features/vault/data/repositories/vault_repository_impl.dart';
import 'package:citadel_password_manager/features/vault/domain/entities/vault_item.dart';
import 'package:cryptography/cryptography.dart';
import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockVaultDao extends Mock implements VaultDao {}

class MockSyncDao extends Mock implements SyncDao {}

class MockCryptoEngine extends Mock implements CryptoEngine {}

class FakeVaultItemsCompanion extends Fake implements VaultItemsCompanion {}

class FakeSecretKey extends Fake implements SecretKey {}

void main() {
  late VaultRepositoryImpl repository;
  late MockVaultDao mockVaultDao;
  late MockSyncDao mockSyncDao;
  late MockCryptoEngine mockCryptoEngine;
  late SecretKey testKey;

  final testEncryptedData = Uint8List.fromList([1, 2, 3, 4, 5]);
  final testFieldsMap = {
    'name': 'Test Item',
    'url': 'https://example.com',
    'username': 'user@example.com',
    'password': 'secret123',
    'notes': null,
    'type': 'password',
    'isFavorite': false,
    'folder': null,
    'customFields': null,
  };

  final testEntity = VaultItemEntity(
    id: 'item-1',
    vaultId: 'vault-1',
    name: 'Test Item',
    url: 'https://example.com',
    username: 'user@example.com',
    password: 'secret123',
    type: VaultItemType.password,
    createdAt: DateTime(2026, 1, 1),
    updatedAt: DateTime(2026, 1, 1),
  );

  setUpAll(() {
    registerFallbackValue(FakeVaultItemsCompanion());
    registerFallbackValue(FakeSecretKey());
    registerFallbackValue(<String, dynamic>{});
  });

  setUp(() {
    mockVaultDao = MockVaultDao();
    mockSyncDao = MockSyncDao();
    mockCryptoEngine = MockCryptoEngine();
    testKey = SecretKey(List.generate(32, (i) => i));

    repository = VaultRepositoryImpl(
      vaultDao: mockVaultDao,
      syncDao: mockSyncDao,
      cryptoEngine: mockCryptoEngine,
    );
  });

  group('createItem', () {
    test('encrypts fields with CryptoEngine then writes to VaultDao then enqueues sync',
        () async {
      when(() => mockCryptoEngine.encryptFields(any(), any()))
          .thenAnswer((_) async => testEncryptedData);
      when(() => mockVaultDao.insertVaultItem(any()))
          .thenAnswer((_) async {});
      when(() => mockSyncDao.enqueue(any(), any(), any()))
          .thenAnswer((_) async {});

      await repository.createItem(testEntity, testKey);

      // Verify order: encrypt -> write -> enqueue.
      verifyInOrder([
        () => mockCryptoEngine.encryptFields(any(), any()),
        () => mockVaultDao.insertVaultItem(any()),
        () => mockSyncDao.enqueue('item-1', 'vault_items', 'create'),
      ]);
    });

    test('stores encryptionVersion=2 in the database', () async {
      VaultItemsCompanion? capturedCompanion;

      when(() => mockCryptoEngine.encryptFields(any(), any()))
          .thenAnswer((_) async => testEncryptedData);
      when(() => mockVaultDao.insertVaultItem(any()))
          .thenAnswer((invocation) async {
        capturedCompanion =
            invocation.positionalArguments[0] as VaultItemsCompanion;
      });
      when(() => mockSyncDao.enqueue(any(), any(), any()))
          .thenAnswer((_) async {});

      await repository.createItem(testEntity, testKey);

      expect(capturedCompanion, isNotNull);
      expect(capturedCompanion!.encryptionVersion.value, 2);
    });
  });

  group('getItems', () {
    test('reads from VaultDao and decrypts each item', () async {
      final dbItem = VaultItem(
        id: 'item-1',
        vaultId: 'vault-1',
        encryptedData: testEncryptedData,
        encryptionVersion: 2,
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
        remoteId: null,
        isDeleted: false,
      );

      when(() => mockVaultDao.getItemsByVault('vault-1'))
          .thenAnswer((_) async => [dbItem]);
      when(() => mockCryptoEngine.decryptFields(testEncryptedData, any()))
          .thenAnswer((_) async => testFieldsMap);

      final items = await repository.getItems('vault-1', testKey);

      expect(items.length, 1);
      expect(items[0].name, 'Test Item');
      expect(items[0].url, 'https://example.com');
      expect(items[0].username, 'user@example.com');
      expect(items[0].password, 'secret123');
      expect(items[0].type, VaultItemType.password);
      verify(() => mockCryptoEngine.decryptFields(testEncryptedData, any()))
          .called(1);
    });
  });

  group('updateItem', () {
    test('re-encrypts fields, updates local DB, and enqueues update sync',
        () async {
      final updatedEntity = testEntity.copyWith(
        name: 'Updated Item',
        updatedAt: DateTime(2026, 6, 15),
      );

      when(() => mockCryptoEngine.encryptFields(any(), any()))
          .thenAnswer((_) async => testEncryptedData);
      when(() => mockVaultDao.updateVaultItem(any()))
          .thenAnswer((_) async => true);
      when(() => mockSyncDao.enqueue(any(), any(), any()))
          .thenAnswer((_) async {});

      await repository.updateItem(updatedEntity, testKey);

      verifyInOrder([
        () => mockCryptoEngine.encryptFields(any(), any()),
        () => mockVaultDao.updateVaultItem(any()),
        () => mockSyncDao.enqueue('item-1', 'vault_items', 'update'),
      ]);
    });
  });

  group('deleteItem', () {
    test('calls softDeleteItem on VaultDao and enqueues delete sync', () async {
      when(() => mockVaultDao.softDeleteItem('item-1'))
          .thenAnswer((_) async {});
      when(() => mockSyncDao.enqueue(any(), any(), any()))
          .thenAnswer((_) async {});

      await repository.deleteItem('item-1');

      verifyInOrder([
        () => mockVaultDao.softDeleteItem('item-1'),
        () => mockSyncDao.enqueue('item-1', 'vault_items', 'delete'),
      ]);
    });
  });

  group('watchItems', () {
    test('returns a stream that emits decrypted items when DB changes',
        () async {
      final dbItem = VaultItem(
        id: 'item-1',
        vaultId: 'vault-1',
        encryptedData: testEncryptedData,
        encryptionVersion: 2,
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
        remoteId: null,
        isDeleted: false,
      );

      final controller = StreamController<List<VaultItem>>();

      when(() => mockVaultDao.watchItemsByVault('vault-1'))
          .thenAnswer((_) => controller.stream);
      when(() => mockCryptoEngine.decryptFields(testEncryptedData, any()))
          .thenAnswer((_) async => testFieldsMap);

      final stream = repository.watchItems('vault-1', testKey);

      // Listen and collect first emission.
      final resultFuture = stream.first;

      // Emit DB change.
      controller.add([dbItem]);

      final result = await resultFuture;

      expect(result.length, 1);
      expect(result[0].name, 'Test Item');
      expect(result[0].id, 'item-1');

      await controller.close();
    });
  });

  group('encrypt-at-boundary verification', () {
    test('VaultItemEntity holds plaintext, only repository calls CryptoEngine',
        () async {
      // Verify the entity has plaintext fields.
      expect(testEntity.name, 'Test Item');
      expect(testEntity.password, 'secret123');

      // Verify toFieldsMap produces the expected structure.
      final fieldsMap = testEntity.toFieldsMap();
      expect(fieldsMap['name'], 'Test Item');
      expect(fieldsMap['password'], 'secret123');
      expect(fieldsMap['type'], 'password');

      // Verify that createItem calls encryptFields (repository boundary).
      when(() => mockCryptoEngine.encryptFields(any(), any()))
          .thenAnswer((_) async => testEncryptedData);
      when(() => mockVaultDao.insertVaultItem(any()))
          .thenAnswer((_) async {});
      when(() => mockSyncDao.enqueue(any(), any(), any()))
          .thenAnswer((_) async {});

      await repository.createItem(testEntity, testKey);

      verify(() => mockCryptoEngine.encryptFields(any(), any())).called(1);
    });
  });
}
