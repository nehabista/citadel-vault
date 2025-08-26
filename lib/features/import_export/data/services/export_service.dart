import 'dart:convert';
import 'dart:typed_data';

import 'package:csv/csv.dart';

import '../../../../core/crypto/crypto_engine.dart';
import '../../../vault/domain/entities/vault_item.dart';

/// Provides vault export functionality: plain CSV and encrypted backup.
class ExportService {
  final CryptoEngine _crypto;

  ExportService({required CryptoEngine crypto}) : _crypto = crypto;

  /// Export vault items as a plain CSV file.
  ///
  /// Headers: name,url,username,password,notes,type
  /// Returns UTF-8 encoded bytes.
  Future<Uint8List> exportCsv(List<VaultItemEntity> items) async {
    final rows = <List<String>>[
      // Header row
      ['name', 'url', 'username', 'password', 'notes', 'type'],
      // Data rows
      ...items.map((item) => [
            item.name,
            item.url ?? '',
            item.username ?? '',
            item.password ?? '',
            item.notes ?? '',
            item.type.name,
          ]),
    ];

    final csvString = const ListToCsvConverter().convert(rows);
    return Uint8List.fromList(utf8.encode(csvString));
  }

  /// Export vault items as an AES-256-GCM encrypted backup.
  ///
  /// Format: [16-byte salt][encrypted data]
  /// The encrypted data contains JSON with version, exportedAt metadata,
  /// and the full item list.
  Future<Uint8List> exportEncryptedBackup(
    List<VaultItemEntity> items,
    String backupPassword,
  ) async {
    // Serialize items to JSON with metadata
    final payload = {
      'version': 1,
      'exportedAt': DateTime.now().toIso8601String(),
      'items': items
          .map((item) => {
                'id': item.id,
                'vaultId': item.vaultId,
                ...item.toFieldsMap(),
                'createdAt': item.createdAt.toIso8601String(),
                'updatedAt': item.updatedAt.toIso8601String(),
              })
          .toList(),
    };

    final jsonBytes = Uint8List.fromList(utf8.encode(jsonEncode(payload)));

    // Generate salt and derive key
    final salt = _crypto.generateSalt();
    final key = await _crypto.deriveKey(backupPassword, salt);

    // Encrypt
    final encrypted = await _crypto.encrypt(jsonBytes, key);

    // Prepend salt to encrypted data
    final result = Uint8List(salt.length + encrypted.length);
    result.setAll(0, salt);
    result.setAll(salt.length, encrypted);

    return result;
  }
}
