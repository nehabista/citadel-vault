/// Comprehensive end-to-end verification of Citadel Password Manager
/// data pipelines (Phases 1-3).
///
/// Each test is independent and validates a core subsystem.
@TestOn('vm')
library;

import 'dart:convert';
import 'dart:typed_data';

import 'package:citadel_password_manager/core/crypto/crypto_engine.dart';
import 'package:citadel_password_manager/core/crypto/encrypted_blob.dart';
import 'package:citadel_password_manager/core/crypto/legacy_crypto.dart';
import 'package:citadel_password_manager/core/database/app_database.dart';
import 'package:citadel_password_manager/features/import_export/data/parsers/format_detector.dart';
import 'package:citadel_password_manager/features/password_generator/data/password_generator_service.dart';
import 'package:citadel_password_manager/features/password_generator/data/password_strength_service.dart';
import 'package:citadel_password_manager/features/password_generator/domain/entities/password_strength.dart';
import 'package:citadel_password_manager/features/security/data/services/breach_service.dart';
import 'package:citadel_password_manager/features/security/data/services/totp_service.dart';
import 'package:citadel_password_manager/features/security/data/services/watchtower_service.dart';
import 'package:citadel_password_manager/features/vault/data/repositories/vault_repository_impl.dart';
import 'package:citadel_password_manager/features/vault/domain/entities/vault_item.dart';
import 'package:cryptography/cryptography.dart';
import 'package:csv/csv.dart';
import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';

// ---------------------------------------------------------------------------
// 1. CryptoEngine roundtrip
// ---------------------------------------------------------------------------
void main() {
  group('1. CryptoEngine roundtrip', () {
    late CryptoEngine engine;
    late SecretKey key;

    setUpAll(() async {
      engine = CryptoEngine();
      final salt = engine.generateSalt();
      key = await engine.deriveKey('test-master-password', salt);
    });

    test('derive key -> encrypt fields -> decrypt fields -> verify match',
        () async {
      final fields = {
        'name': 'GitHub',
        'url': 'https://github.com',
        'username': 'alice',
        'password': 'sup3rS3cret!',
        'notes': 'Main dev account',
        'type': 'password',
        'isFavorite': true,
        'folder': 'dev',
      };

      final blob = await engine.encryptFields(fields, key);
      expect(blob.length, greaterThan(29)); // version + nonce + tag at minimum

      final decrypted = await engine.decryptFields(blob, key);
      expect(decrypted['name'], 'GitHub');
      expect(decrypted['url'], 'https://github.com');
      expect(decrypted['username'], 'alice');
      expect(decrypted['password'], 'sup3rS3cret!');
      expect(decrypted['notes'], 'Main dev account');
      expect(decrypted['isFavorite'], true);
    });

    test('encrypt/decrypt raw bytes roundtrip', () async {
      final plaintext =
          Uint8List.fromList(utf8.encode('Hello, Citadel vault!'));
      final encrypted = await engine.encrypt(plaintext, key);
      final decrypted = await engine.decrypt(encrypted, key);
      expect(utf8.decode(decrypted), 'Hello, Citadel vault!');
    });

    test('decryption with wrong key fails', () async {
      final plaintext = Uint8List.fromList(utf8.encode('secret'));
      final encrypted = await engine.encrypt(plaintext, key);

      final wrongKey =
          await engine.deriveKey('wrong-password', engine.generateSalt());
      expect(
        () => engine.decrypt(encrypted, wrongKey),
        throwsA(isA<SecretBoxAuthenticationError>()),
      );
    });
  });

  // ---------------------------------------------------------------------------
  // 2. Legacy crypto compat
  // ---------------------------------------------------------------------------
  group('2. Legacy crypto compat', () {
    late LegacyCrypto legacy;
    late SecretKey legacyKey;
    late String legacySalt;

    setUpAll(() async {
      legacy = LegacyCrypto();
      // Legacy uses base64-encoded salt string
      legacySalt = base64.encode(List.generate(16, (i) => i + 1));
      legacyKey = await legacy.deriveKey('legacy-password', legacySalt);
    });

    test('create v1 encrypted data -> detect version -> decrypt', () async {
      const original = 'my-legacy-password-123';
      final v1Cipher = await legacy.encryptForTesting(original, legacyKey);

      // Verify v1 format detection
      expect(EncryptedBlob.isV1Format(v1Cipher), isTrue);
      expect(EncryptedBlob.isV1Format('not-base64'), isFalse);
      expect(EncryptedBlob.isV1Format('plaintext-no-colon'), isFalse);

      // Decrypt with LegacyCrypto
      final decrypted = await legacy.decrypt(v1Cipher, legacyKey);
      expect(decrypted, original);
    });

    test('v1 decrypt -> v2 encrypt -> v2 decrypt roundtrip (migration)',
        () async {
      const original = '{"name":"test","password":"legacy123"}';
      final v1Cipher = await legacy.encryptForTesting(original, legacyKey);

      // Step 1: Decrypt with legacy
      final plaintext = await legacy.decrypt(v1Cipher, legacyKey);
      expect(plaintext, original);

      // Step 2: Re-encrypt with v2 engine
      final engine = CryptoEngine();
      final v2Key =
          await engine.deriveKey('new-password', engine.generateSalt());
      final v2Blob =
          await engine.encrypt(Uint8List.fromList(utf8.encode(plaintext)), v2Key);

      // Step 3: Verify v2 blob structure
      final parsed = EncryptedBlob.fromBytes(v2Blob);
      expect(parsed.version, CryptoVersion.v2);

      // Step 4: Decrypt with v2 and verify
      final result = await engine.decrypt(v2Blob, v2Key);
      expect(utf8.decode(result), original);
    });
  });

  // ---------------------------------------------------------------------------
  // 3. Drift database
  // ---------------------------------------------------------------------------
  group('3. Drift database', () {
    late AppDatabase db;

    setUp(() {
      db = AppDatabase.inMemory();
    });

    tearDown(() async {
      await db.close();
    });

    test('open in-memory DB -> create vault -> create item -> query -> verify',
        () async {
      final now = DateTime.now();
      const vaultId = 'test-vault-001';
      const itemId = 'test-item-001';

      // Create vault
      await db.vaultDao.insertVault(VaultsCompanion(
        id: const Value('test-vault-001'),
        name: const Value('Test Vault'),
        createdAt: Value(now),
        updatedAt: Value(now),
      ));

      // Verify vault exists
      final vaults = await db.vaultDao.getAllVaults();
      expect(vaults, hasLength(1));
      expect(vaults.first.name, 'Test Vault');

      // Create item with encrypted data
      final fakeEncrypted = Uint8List.fromList([0x02, ...List.filled(28, 0)]);
      await db.vaultDao.insertVaultItem(VaultItemsCompanion(
        id: const Value(itemId),
        vaultId: const Value(vaultId),
        encryptedData: Value(fakeEncrypted),
        encryptionVersion: const Value(2),
        createdAt: Value(now),
        updatedAt: Value(now),
      ));

      // Query items
      final items = await db.vaultDao.getItemsByVault(vaultId);
      expect(items, hasLength(1));
      expect(items.first.id, itemId);
      expect(items.first.vaultId, vaultId);
      expect(items.first.encryptionVersion, 2);
    });

    test('soft delete sets isDeleted flag', () async {
      final now = DateTime.now();
      const vaultId = 'vault-sd';
      const itemId = 'item-sd';

      await db.vaultDao.insertVault(VaultsCompanion(
        id: const Value(vaultId),
        name: const Value('SD Vault'),
        createdAt: Value(now),
        updatedAt: Value(now),
      ));

      await db.vaultDao.insertVaultItem(VaultItemsCompanion(
        id: const Value(itemId),
        vaultId: const Value(vaultId),
        encryptedData: Value(Uint8List.fromList([0x02, ...List.filled(28, 0)])),
        encryptionVersion: const Value(2),
        createdAt: Value(now),
        updatedAt: Value(now),
      ));

      // Soft delete
      await db.vaultDao.softDeleteItem(itemId);

      // getItemsByVault filters out deleted items
      final items = await db.vaultDao.getItemsByVault(vaultId);
      expect(items, isEmpty);
    });
  });

  // ---------------------------------------------------------------------------
  // 4. VaultRepository
  // ---------------------------------------------------------------------------
  group('4. VaultRepository', () {
    late AppDatabase db;
    late VaultRepositoryImpl repo;
    late CryptoEngine engine;
    late SecretKey vaultKey;

    setUpAll(() async {
      engine = CryptoEngine();
      vaultKey =
          await engine.deriveKey('repo-test-password', engine.generateSalt());
    });

    setUp(() {
      db = AppDatabase.inMemory();
      repo = VaultRepositoryImpl(
        vaultDao: db.vaultDao,
        syncDao: db.syncDao,
        cryptoEngine: engine,
        passwordHistoryDao: db.passwordHistoryDao,
      );
    });

    tearDown(() async {
      await db.close();
    });

    test(
        'create item via repository -> get items -> verify decrypted data matches',
        () async {
      const vaultId = 'vault-repo-01';
      final now = DateTime.now();

      // Create vault first
      await repo.createVault(id: vaultId, name: 'Repo Test Vault');

      // Create vault item
      final entity = VaultItemEntity(
        id: 'item-repo-01',
        vaultId: vaultId,
        name: 'Gmail',
        url: 'https://gmail.com',
        username: 'bob@gmail.com',
        password: 'GmailP@ss99!',
        notes: 'Primary email',
        type: VaultItemType.password,
        isFavorite: true,
        createdAt: now,
        updatedAt: now,
      );

      await repo.createItem(entity, vaultKey);

      // Read back and verify decryption
      final items = await repo.getItems(vaultId, vaultKey);
      expect(items, hasLength(1));

      final retrieved = items.first;
      expect(retrieved.name, 'Gmail');
      expect(retrieved.url, 'https://gmail.com');
      expect(retrieved.username, 'bob@gmail.com');
      expect(retrieved.password, 'GmailP@ss99!');
      expect(retrieved.notes, 'Primary email');
      expect(retrieved.isFavorite, true);
      expect(retrieved.type, VaultItemType.password);
    });
  });

  // ---------------------------------------------------------------------------
  // 5. Password generator
  // ---------------------------------------------------------------------------
  group('5. Password generator', () {
    test('generate password with correct length and character pools', () {
      final pwd = generatePassword(
        length: 24,
        upper: true,
        lower: true,
        digits: true,
        symbols: true,
        pronounceable: false,
      );

      expect(pwd.length, 24);
      expect(pwd.contains(RegExp(r'[A-Z]')), isTrue);
      expect(pwd.contains(RegExp(r'[a-z]')), isTrue);
      expect(pwd.contains(RegExp(r'\d')), isTrue);
      // At least one symbol from the pool
      expect(pwd.contains(RegExp(r'[!@#$%^&*()\-_=+\[\]{};:,<.>/?~]')), isTrue);
    });

    test('generate password with only lowercase', () {
      final pwd = generatePassword(
        length: 16,
        upper: false,
        lower: true,
        digits: false,
        symbols: false,
        pronounceable: false,
      );
      expect(pwd.length, 16);
      expect(pwd, matches(RegExp(r'^[a-z]+$')));
    });

    test('generate passphrase', () {
      final phrase = generatePassword(
        length: 20,
        upper: true,
        lower: true,
        digits: true,
        symbols: true,
        pronounceable: true,
      );
      // Passphrases contain separator dashes
      expect(phrase.contains('-'), isTrue);
      // Should have at least 4 parts (words + digit + symbol)
      expect(phrase.split('-').length, greaterThanOrEqualTo(4));
    });
  });

  // ---------------------------------------------------------------------------
  // 6. Password strength
  // ---------------------------------------------------------------------------
  group('6. Password strength', () {
    test('"password123" is weak', () {
      const pwd = 'password123';
      final checks = runChecks(pwd);
      final bits = estimateEntropyBits(pwd);
      final strength = classifyStrength(checks, bits);

      expect(strength, Strength.weak);
      // password123 has lower + digit but no upper, no special, length < 12
      expect(checks.hasUpper, isFalse);
      expect(checks.hasSpecial, isFalse);
    });

    test('32-char random with all pools is strong', () {
      // A known 32-char password with all character classes
      const pwd = 'Xk9#mLq2@Rw5!Yv8*Zn3&Fp6^Jh1\$Bt';
      final checks = runChecks(pwd);
      final bits = estimateEntropyBits(pwd);
      final strength = classifyStrength(checks, bits);

      expect(strength, Strength.strong);
      expect(bits, greaterThan(80));
      expect(checks.passedCount, 5); // all checks pass
    });

    test('empty password has 0 entropy', () {
      expect(estimateEntropyBits(''), 0.0);
    });
  });

  // ---------------------------------------------------------------------------
  // 7. HIBP breach check (live API)
  // ---------------------------------------------------------------------------
  group('7. HIBP breach check', () {
    test('password "password" has >0 breach count', () async {
      final service = BreachService();
      final count = await service.pwnedPasswordCount('password');
      expect(count, greaterThan(0),
          reason: '"password" is one of the most breached passwords');
    });

    test('random 64-char password has 0 breach count', () async {
      // Generate a truly random password that would never appear in breaches
      final randomPwd = generatePassword(
        length: 64,
        upper: true,
        lower: true,
        digits: true,
        symbols: true,
        pronounceable: false,
      );
      final service = BreachService();
      final count = await service.pwnedPasswordCount(randomPwd);
      expect(count, 0);
    });
  });

  // ---------------------------------------------------------------------------
  // 8. TOTP generation
  // ---------------------------------------------------------------------------
  group('8. TOTP generation', () {
    test('generate code from secret -> verify 6 digits', () {
      final service = TotpService();
      // Known Base32 test secret (RFC 6238 test vector)
      const secret = 'JBSWY3DPEHPK3PXP';

      final code = service.generateCode(base32Secret: secret);
      expect(code.length, 6);
      expect(code, matches(RegExp(r'^\d{6}$')));
    });

    test('generate 8-digit code', () {
      final service = TotpService();
      const secret = 'JBSWY3DPEHPK3PXP';

      final code = service.generateCode(base32Secret: secret, digits: 8);
      expect(code.length, 8);
      expect(code, matches(RegExp(r'^\d{8}$')));
    });

    test('remainingSeconds is within period range', () {
      final service = TotpService();
      final remaining = service.remainingSeconds();
      expect(remaining, greaterThan(0));
      expect(remaining, lessThanOrEqualTo(30));
    });
  });

  // ---------------------------------------------------------------------------
  // 9. Import/export - CSV format detection
  // ---------------------------------------------------------------------------
  group('9. Import/export', () {
    test('detect Chrome CSV format from headers', () {
      final headers = ['name', 'url', 'username', 'password'];
      final format = detectFormat(headers);
      expect(format, ImportFormat.chrome);
    });

    test('detect Bitwarden CSV format', () {
      final headers = [
        'folder',
        'favorite',
        'type',
        'name',
        'notes',
        'fields',
        'reprompt',
        'login_uri',
        'login_username',
        'login_password',
        'login_totp',
      ];
      final format = detectFormat(headers);
      expect(format, ImportFormat.bitwarden);
    });

    test('detect LastPass CSV format', () {
      final headers = ['url', 'username', 'password', 'extra', 'name', 'grouping', 'fav'];
      final format = detectFormat(headers);
      expect(format, ImportFormat.lastPass);
    });

    test('unknown format for random headers', () {
      final headers = ['col1', 'col2', 'col3'];
      final format = detectFormat(headers);
      expect(format, ImportFormat.unknown);
    });

    test('parse Chrome CSV string -> extract items', () {
      const csvContent = 'name,url,username,password\n'
          'GitHub,https://github.com,alice,gh_pass123\n'
          'Gmail,https://gmail.com,bob@gmail.com,gmail_secret\n';

      final converter = const CsvToListConverter(eol: '\n');
      final rows = converter.convert(csvContent);
      final headers = rows.first.map((e) => e.toString()).toList();

      expect(detectFormat(headers), ImportFormat.chrome);
      // Data rows (skip header)
      expect(rows.length, greaterThanOrEqualTo(3)); // header + 2 data rows
    });
  });

  // ---------------------------------------------------------------------------
  // 10. Watchtower scoring
  // ---------------------------------------------------------------------------
  group('10. Watchtower scoring', () {
    test('items with weak/reused passwords -> health score < 100', () {
      final service = WatchtowerService();
      final now = DateTime.now();

      // Create items with deliberately weak and reused passwords
      final items = [
        VaultItemEntity(
          id: '1',
          vaultId: 'v1',
          name: 'Site1',
          password: 'abc', // weak: too short, no upper/digit/special
          type: VaultItemType.password,
          createdAt: now,
          updatedAt: now,
        ),
        VaultItemEntity(
          id: '2',
          vaultId: 'v1',
          name: 'Site2',
          password: 'abc', // reused (same as Site1)
          type: VaultItemType.password,
          createdAt: now,
          updatedAt: now,
        ),
        VaultItemEntity(
          id: '3',
          vaultId: 'v1',
          name: 'Site3',
          password: '123', // weak
          type: VaultItemType.password,
          createdAt: now,
          updatedAt: now.subtract(const Duration(days: 120)), // old
        ),
      ];

      final score = service.computeScore(items);
      expect(score.score, lessThan(100));
      expect(score.weakItems, isNotEmpty);
      expect(score.reusedItems, isNotEmpty);
    });

    test('empty vault has score of 100', () {
      final service = WatchtowerService();
      final score = service.computeScore([]);
      expect(score.score, 100);
    });

    test('all strong unique recent passwords give high score', () {
      final service = WatchtowerService();
      final now = DateTime.now();

      final items = [
        VaultItemEntity(
          id: '1',
          vaultId: 'v1',
          name: 'Site1',
          password: 'Xk9#mLq2@Rw5!Yv8', // strong
          type: VaultItemType.password,
          createdAt: now,
          updatedAt: now,
        ),
        VaultItemEntity(
          id: '2',
          vaultId: 'v1',
          name: 'Site2',
          password: 'Ab3\$Zn7!Fp9*Jh6^', // strong, unique
          type: VaultItemType.password,
          createdAt: now,
          updatedAt: now,
        ),
      ];

      final score = service.computeScore(items);
      expect(score.score, greaterThanOrEqualTo(85));
      expect(score.weakItems, isEmpty);
      expect(score.reusedItems, isEmpty);
    });

    test('withBreachedItems reduces score', () {
      final service = WatchtowerService();
      final now = DateTime.now();

      final items = [
        VaultItemEntity(
          id: '1',
          vaultId: 'v1',
          name: 'Site1',
          password: 'Xk9#mLq2@Rw5!Yv8',
          type: VaultItemType.password,
          createdAt: now,
          updatedAt: now,
        ),
        VaultItemEntity(
          id: '2',
          vaultId: 'v1',
          name: 'Site2',
          password: 'Ab3\$Zn7!Fp9*Jh6^',
          type: VaultItemType.password,
          createdAt: now,
          updatedAt: now,
        ),
      ];

      final baseScore = service.computeScore(items);
      final breachedScore = baseScore.withBreachedItems([items.first]);
      expect(breachedScore.score, lessThan(baseScore.score));
      expect(breachedScore.breachedItems, hasLength(1));
    });
  });
}
