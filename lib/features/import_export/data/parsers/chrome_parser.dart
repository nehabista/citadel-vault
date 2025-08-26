import '../../../vault/domain/entities/vault_item.dart';
import 'csv_parser.dart';

/// Parses Chrome CSV exports into [VaultItemEntity] instances.
///
/// Chrome CSV headers:
/// name,url,username,password,note
class ChromeParser extends CsvParser {
  @override
  List<VaultItemEntity> parse(
    List<List<dynamic>> rows,
    List<String> headers,
    String targetVaultId,
  ) {
    final nameIdx = CsvParser.headerIndex(headers, 'name');
    final urlIdx = CsvParser.headerIndex(headers, 'url');
    final usernameIdx = CsvParser.headerIndex(headers, 'username');
    final passwordIdx = CsvParser.headerIndex(headers, 'password');
    final noteIdx = CsvParser.headerIndex(headers, 'note');

    final items = <VaultItemEntity>[];
    final now = DateTime.now();

    for (final row in rows) {
      final name = CsvParser.getValue(row, nameIdx);
      final password = CsvParser.getValue(row, passwordIdx);

      if (CsvParser.shouldSkipRow(name, password)) continue;

      items.add(VaultItemEntity(
        id: CsvParser.generateId(),
        vaultId: targetVaultId,
        name: name ?? '',
        url: CsvParser.getValue(row, urlIdx),
        username: CsvParser.getValue(row, usernameIdx),
        password: password,
        notes: CsvParser.getValue(row, noteIdx),
        type: VaultItemType.password,
        createdAt: now,
        updatedAt: now,
      ));
    }

    return items;
  }
}
