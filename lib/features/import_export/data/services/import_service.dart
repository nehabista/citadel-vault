import 'dart:convert';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
import 'package:csv/csv.dart';

import '../../../../core/crypto/crypto_engine.dart';
import '../../../vault/domain/entities/vault_item.dart';
import '../../../vault/domain/repositories/vault_repository.dart';
import '../parsers/bitwarden_parser.dart';
import '../parsers/chrome_parser.dart';
import '../parsers/csv_parser.dart';
import '../parsers/format_detector.dart';
import '../parsers/lastpass_parser.dart';
import '../parsers/onepassword_parser.dart';

/// Exception thrown when the CSV format cannot be identified.
class ImportFormatException implements Exception {
  final String message;
  const ImportFormatException(
      [this.message = 'Unable to detect CSV format from headers']);

  @override
  String toString() => 'ImportFormatException: $message';
}

/// Orchestrates the import workflow: parse file, preview items, commit to vault.
class ImportService {
  final VaultRepository _repository;

  ImportService({required VaultRepository repository})
      : _repository = repository;

  /// Parse a CSV file from raw bytes.
  ///
  /// Handles BOM stripping and encoding detection.
  /// Returns the detected format and parsed items for preview.
  /// Throws [ImportFormatException] if format cannot be detected.
  Future<(ImportFormat, List<VaultItemEntity>)> parseFile(
    Uint8List fileBytes,
    String targetVaultId,
  ) async {
    final csvString = _decodeBytes(fileBytes);
    final converter = const CsvToListConverter(eol: '\n');
    final rows = converter.convert(csvString);

    if (rows.isEmpty) {
      throw ImportFormatException('CSV file is empty');
    }

    // Extract headers from first row
    final headers = rows.first.map((e) => e.toString()).toList();
    final format = detectFormat(headers);

    if (format == ImportFormat.unknown) {
      throw ImportFormatException(
        'Unrecognized CSV format. Supported: Bitwarden, 1Password, LastPass, Chrome',
      );
    }

    final dataRows = rows.skip(1).toList();
    final parser = _getParser(format);
    final items = parser.parse(dataRows, headers, targetVaultId);

    return (format, items);
  }

  /// Commit parsed items to the vault.
  ///
  /// Returns the count of successfully imported items.
  Future<int> commitImport(
    List<VaultItemEntity> items,
    SecretKey vaultKey,
  ) async {
    var count = 0;
    for (final item in items) {
      await _repository.createItem(item, vaultKey);
      count++;
    }
    return count;
  }

  /// Parse an encrypted backup file.
  ///
  /// Extracts salt (first 16 bytes), derives key from password, decrypts,
  /// and parses JSON to vault item entities.
  Future<List<VaultItemEntity>> parseEncryptedBackup(
    Uint8List bytes,
    String backupPassword,
    CryptoEngine crypto,
  ) async {
    if (bytes.length < 17) {
      throw ImportFormatException('Invalid encrypted backup file');
    }

    // Salt is first 16 bytes
    final salt = bytes.sublist(0, 16);
    final encryptedData = bytes.sublist(16);

    // Derive key from backup password + salt
    final key = await crypto.deriveKey(backupPassword, salt);

    // Decrypt
    final decrypted = await crypto.decrypt(Uint8List.fromList(encryptedData), key);
    final jsonStr = utf8.decode(decrypted);
    final data = jsonDecode(jsonStr) as Map<String, dynamic>;

    // Parse items from JSON
    final itemsList = data['items'] as List<dynamic>? ?? [];
    return itemsList.map((itemJson) {
      final map = itemJson as Map<String, dynamic>;
      return VaultItemEntity.fromFieldsMap(
        id: map['id'] as String? ?? CsvParser.generateId(),
        vaultId: map['vaultId'] as String? ?? '',
        fields: map,
        createdAt: map['createdAt'] != null
            ? DateTime.parse(map['createdAt'] as String)
            : DateTime.now(),
        updatedAt: map['updatedAt'] != null
            ? DateTime.parse(map['updatedAt'] as String)
            : DateTime.now(),
      );
    }).toList();
  }

  /// Decode raw bytes to a string, handling BOM and encoding.
  String _decodeBytes(Uint8List bytes) {
    var data = bytes;

    // Strip UTF-8 BOM if present (0xEF, 0xBB, 0xBF)
    if (data.length >= 3 &&
        data[0] == 0xEF &&
        data[1] == 0xBB &&
        data[2] == 0xBF) {
      data = data.sublist(3);
    }

    // Try UTF-8 first, fall back to Latin-1
    try {
      return utf8.decode(data);
    } catch (_) {
      return latin1.decode(data);
    }
  }

  /// Get the appropriate parser for the detected format.
  CsvParser _getParser(ImportFormat format) {
    return switch (format) {
      ImportFormat.bitwarden => BitwardenParser(),
      ImportFormat.onePassword => OnePasswordParser(),
      ImportFormat.lastPass => LastPassParser(),
      ImportFormat.chrome => ChromeParser(),
      ImportFormat.unknown => throw ImportFormatException(),
    };
  }
}
