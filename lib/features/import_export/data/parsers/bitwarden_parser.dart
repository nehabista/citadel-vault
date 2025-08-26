import '../../../vault/domain/entities/vault_item.dart';
import 'csv_parser.dart';

/// Parses Bitwarden CSV exports into [VaultItemEntity] instances.
///
/// Bitwarden CSV headers:
/// folder,favorite,type,name,notes,fields,reprompt,login_uri,login_username,login_password,login_totp
class BitwardenParser extends CsvParser {
  @override
  List<VaultItemEntity> parse(
    List<List<dynamic>> rows,
    List<String> headers,
    String targetVaultId,
  ) {
    final nameIdx = CsvParser.headerIndex(headers, 'name');
    final uriIdx = CsvParser.headerIndex(headers, 'login_uri');
    final usernameIdx = CsvParser.headerIndex(headers, 'login_username');
    final passwordIdx = CsvParser.headerIndex(headers, 'login_password');
    final notesIdx = CsvParser.headerIndex(headers, 'notes');
    final folderIdx = CsvParser.headerIndex(headers, 'folder');
    final typeIdx = CsvParser.headerIndex(headers, 'type');

    final items = <VaultItemEntity>[];
    final now = DateTime.now();

    for (final row in rows) {
      final name = CsvParser.getValue(row, nameIdx);
      final password = CsvParser.getValue(row, passwordIdx);

      if (CsvParser.shouldSkipRow(name, password)) continue;

      final bitwardenType = CsvParser.getValue(row, typeIdx)?.toLowerCase();
      final itemType = switch (bitwardenType) {
        'login' => VaultItemType.password,
        'note' => VaultItemType.secureNote,
        'card' => VaultItemType.paymentCard,
        _ => VaultItemType.password,
      };

      items.add(VaultItemEntity(
        id: CsvParser.generateId(),
        vaultId: targetVaultId,
        name: name ?? '',
        url: CsvParser.getValue(row, uriIdx),
        username: CsvParser.getValue(row, usernameIdx),
        password: password,
        notes: CsvParser.getValue(row, notesIdx),
        folder: CsvParser.getValue(row, folderIdx),
        type: itemType,
        createdAt: now,
        updatedAt: now,
      ));
    }

    return items;
  }
}
