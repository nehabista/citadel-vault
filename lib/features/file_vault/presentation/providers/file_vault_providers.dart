import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/core_providers.dart';
import '../../../../core/providers/session_provider.dart';
import '../../../../core/session/session_state.dart';
import '../../data/services/file_encryption_service.dart';
import '../../domain/entities/file_attachment_entity.dart';

/// Provides the FileEncryptionService with CryptoEngine + FileAttachmentDao.
final fileEncryptionServiceProvider = Provider<FileEncryptionService>((ref) {
  final crypto = ref.watch(cryptoEngineProvider);
  final db = ref.watch(appDatabaseProvider);
  return FileEncryptionService(crypto, db.fileAttachmentDao);
});

/// Loads file attachments for a specific vault ID.
///
/// Returns the list of [FileAttachmentEntity] by mapping from Drift records.
/// Uses FutureProvider.family consistent with other per-vault providers.
final fileAttachmentsProvider =
    FutureProvider.family<List<FileAttachmentEntity>, String>(
        (ref, vaultId) async {
  final db = ref.watch(appDatabaseProvider);
  final records = await db.fileAttachmentDao.getByVault(vaultId);
  return records
      .map(
        (r) => FileAttachmentEntity(
          id: r.id,
          vaultId: r.vaultId,
          fileName: r.fileName,
          mimeType: r.mimeType,
          sizeBytes: r.sizeBytes,
          encryptedPath: r.encryptedPath,
          createdAt: r.createdAt,
        ),
      )
      .toList();
});

/// Watches file attachments reactively via Drift stream.
///
/// Uses StreamProvider.family for real-time updates when files are
/// added or removed, consistent with Riverpod 3.x patterns.
final fileAttachmentsStreamProvider =
    StreamProvider.family<List<FileAttachmentEntity>, String>(
        (ref, vaultId) {
  final db = ref.watch(appDatabaseProvider);
  return db.fileAttachmentDao.watchByVault(vaultId).map(
        (records) => records
            .map(
              (r) => FileAttachmentEntity(
                id: r.id,
                vaultId: r.vaultId,
                fileName: r.fileName,
                mimeType: r.mimeType,
                sizeBytes: r.sizeBytes,
                encryptedPath: r.encryptedPath,
                createdAt: r.createdAt,
              ),
            )
            .toList(),
      );
});

/// Cleans up temp files when session transitions to locked state.
///
/// Watch this provider in app.dart or a top-level widget to ensure
/// temp decrypted files are removed on lock per D-09 pitfall 2.
final fileVaultCleanupProvider = Provider<void>((ref) {
  final session = ref.watch(sessionProvider);
  if (session is Locked) {
    // Session just locked — clean up temp files
    final service = ref.read(fileEncryptionServiceProvider);
    service.cleanupTempFiles();
  }
});
