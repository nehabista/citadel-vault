import '../../../vault/domain/entities/vault_item.dart';
import 'csv_parser.dart';

/// Parses 1Password CSV exports into [VaultItemEntity] instances.
///
/// 1Password CSV headers:
/// Title,Url,Username,Password,Notes,Type
class OnePasswordParser extends CsvParser {
  @override
  List<VaultItemEntity> parse(
    List<List<dynamic>> rows,
    List<String> headers,
    String targetVaultId,
  ) {
    final titleIdx = CsvParser.headerIndex(headers, 'title');
    final urlIdx = CsvParser.headerIndex(headers, 'url');
    final usernameIdx = CsvParser.headerIndex(headers, 'username');
    final passwordIdx = CsvParser.headerIndex(headers, 'password');
    final notesIdx = CsvParser.headerIndex(headers, 'notes');

    final items = <VaultItemEntity>[];
    final now = DateTime.now();

    for (final row in rows) {
      final name = CsvParser.getValue(row, titleIdx);
      final password = CsvParser.getValue(row, passwordIdx);

      if (CsvParser.shouldSkipRow(name, password)) continue;

      items.add(VaultItemEntity(
        id: CsvParser.generateId(),
        vaultId: targetVaultId,
        name: name ?? '',
        url: CsvParser.getValue(row, urlIdx),
        username: CsvParser.getValue(row, usernameIdx),
        password: password,
        notes: CsvParser.getValue(row, notesIdx),
        type: VaultItemType.password,
        createdAt: now,
        updatedAt: now,
      ));
    }

    return items;
  }
}
