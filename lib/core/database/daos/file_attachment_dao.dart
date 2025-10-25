import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/file_attachments_table.dart';

part 'file_attachment_dao.g.dart';

/// Data access object for encrypted file vault attachments.
@DriftAccessor(tables: [FileAttachments])
class FileAttachmentDao extends DatabaseAccessor<AppDatabase>
    with _$FileAttachmentDaoMixin {
  FileAttachmentDao(super.db);

  /// Get all attachments belonging to a specific vault.
  Future<List<FileAttachment>> getByVault(String vaultId) {
    return (select(fileAttachments)
          ..where((t) => t.vaultId.equals(vaultId)))
        .get();
  }

  /// Insert a new file attachment record.
  Future<void> insertAttachment(FileAttachmentsCompanion entry) {
    return into(fileAttachments).insert(entry);
  }

  /// Delete a single attachment by its ID.
  Future<void> deleteAttachment(String id) {
    return (delete(fileAttachments)..where((t) => t.id.equals(id))).go();
  }

  /// Delete all attachments belonging to a vault.
  Future<void> deleteByVault(String vaultId) {
    return (delete(fileAttachments)..where((t) => t.vaultId.equals(vaultId)))
        .go();
  }

  /// Watch attachments for a vault (reactive stream).
  Stream<List<FileAttachment>> watchByVault(String vaultId) {
    return (select(fileAttachments)
          ..where((t) => t.vaultId.equals(vaultId)))
        .watch();
  }
}
