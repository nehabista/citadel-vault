import 'dart:math';

import '../../../vault/domain/entities/vault_item.dart';

/// Base class for CSV parsers that map format-specific columns to
/// [VaultItemEntity] instances.
abstract class CsvParser {
  /// Parse CSV data rows (excluding the header row) into vault items.
  ///
  /// [rows] contains the data rows as lists of values.
  /// [headers] contains the header column names (lowercase-trimmed).
  /// [targetVaultId] is the vault to import items into.
  List<VaultItemEntity> parse(
    List<List<dynamic>> rows,
    List<String> headers,
    String targetVaultId,
  );

  /// Generate a random hex ID for a new vault item.
  static String generateId() {
    final random = Random.secure();
    final bytes = List.generate(16, (_) => random.nextInt(256));
    return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }

  /// Get the index of a header column (case-insensitive).
  /// Returns -1 if not found.
  static int headerIndex(List<String> headers, String name) {
    final lower = name.toLowerCase();
    for (var i = 0; i < headers.length; i++) {
      if (headers[i].trim().toLowerCase() == lower) return i;
    }
    return -1;
  }

  /// Safely get a string value from a row at the given index.
  /// Returns null if index is out of bounds or value is empty.
  static String? getValue(List<dynamic> row, int index) {
    if (index < 0 || index >= row.length) return null;
    final val = row[index]?.toString().trim();
    return (val == null || val.isEmpty) ? null : val;
  }

  /// Returns true if the row should be skipped (both name and password empty).
  static bool shouldSkipRow(String? name, String? password) {
    return (name == null || name.isEmpty) &&
        (password == null || password.isEmpty);
  }
}
