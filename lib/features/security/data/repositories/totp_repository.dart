import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
import 'package:drift/drift.dart';

import '../../../../core/crypto/crypto_engine.dart';
import '../../../../core/database/daos/totp_dao.dart';
import '../../../../core/database/tables/totp_entries_table.dart';
import '../models/totp_entry_entity.dart';

/// Repository for TOTP entries with encrypt-at-boundary pattern.
///
/// Per D-10: TOTP secrets are encrypted before storage and decrypted
/// after retrieval. The domain layer only sees plaintext TotpEntryEntity.
class TotpRepository {
  final TotpDao _totpDao;
  final CryptoEngine _cryptoEngine;

  TotpRepository({
    required TotpDao totpDao,
    required CryptoEngine cryptoEngine,
  })  : _totpDao = totpDao,
        _cryptoEngine = cryptoEngine;

  /// Get all TOTP entries for a vault item, decrypting secrets.
  Future<List<TotpEntryEntity>> getByVaultItemId(
    String vaultItemId,
    SecretKey vaultKey,
  ) async {
    final entries = await _totpDao.getByVaultItemId(vaultItemId);
    final result = <TotpEntryEntity>[];

    for (final entry in entries) {
      final decryptedBytes = await _cryptoEngine.decrypt(
        Uint8List.fromList(entry.encryptedSecret),
        vaultKey,
      );
      final secret = utf8.decode(decryptedBytes);

      result.add(TotpEntryEntity(
        id: entry.id,
        vaultItemId: entry.vaultItemId,
        secret: secret,
        digits: entry.digits,
        period: entry.period,
        algorithm: entry.algorithm,
      ));
    }

    return result;
  }

  /// Add a new TOTP entry, encrypting the secret before storage.
  Future<void> addEntry(
    TotpEntryEntity entity,
    SecretKey vaultKey,
  ) async {
    final secretBytes = Uint8List.fromList(utf8.encode(entity.secret));
    final encryptedSecret = await _cryptoEngine.encrypt(secretBytes, vaultKey);

    final id = entity.id.isNotEmpty ? entity.id : _generateId();

    await _totpDao.insertEntry(TotpEntriesCompanion.insert(
      id: id,
      vaultItemId: entity.vaultItemId,
      encryptedSecret: encryptedSecret,
      digits: Value(entity.digits),
      period: Value(entity.period),
      algorithm: Value(entity.algorithm),
    ));
  }

  /// Delete a TOTP entry by its ID.
  Future<void> deleteEntry(String id) async {
    await _totpDao.deleteEntry(id);
  }

  /// Get all TOTP entries (for Watchtower count), decrypting secrets.
  Future<List<TotpEntryEntity>> getAllEntries(SecretKey vaultKey) async {
    final entries = await _totpDao.getAllEntries();
    final result = <TotpEntryEntity>[];

    for (final entry in entries) {
      final decryptedBytes = await _cryptoEngine.decrypt(
        Uint8List.fromList(entry.encryptedSecret),
        vaultKey,
      );
      final secret = utf8.decode(decryptedBytes);

      result.add(TotpEntryEntity(
        id: entry.id,
        vaultItemId: entry.vaultItemId,
        secret: secret,
        digits: entry.digits,
        period: entry.period,
        algorithm: entry.algorithm,
      ));
    }

    return result;
  }

  /// Generate a random hex ID (16 bytes = 32 hex chars).
  String _generateId() {
    final random = Random.secure();
    final bytes = List.generate(16, (_) => random.nextInt(256));
    return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }
}
