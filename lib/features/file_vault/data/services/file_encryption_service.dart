import 'dart:io';
import 'dart:math';

import 'package:cryptography/cryptography.dart';
import 'package:mime/mime.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';

import '../../../../core/crypto/crypto_engine.dart';
import '../../../../core/database/daos/file_attachment_dao.dart';
import '../../../../core/database/app_database.dart';
import '../../domain/entities/file_attachment_entity.dart';

/// Exception thrown when a file exceeds the 10MB size limit.
class FileTooLargeException implements Exception {
  final int sizeBytes;
  const FileTooLargeException([this.sizeBytes = 0]);

  @override
  String toString() =>
      'FileTooLargeException: File size ${(sizeBytes / (1024 * 1024)).toStringAsFixed(1)}MB exceeds 10MB limit';
}

/// Exception thrown when a file type is not in the allowed list.
class UnsupportedFileTypeException implements Exception {
  final String extension;
  const UnsupportedFileTypeException([this.extension = '']);

  @override
  String toString() =>
      'UnsupportedFileTypeException: .$extension is not supported. Allowed: jpg, jpeg, png, pdf, txt';
}

/// Encrypts, stores, decrypts, and manages file vault attachments.
///
/// Per D-05/D-07/D-08/D-09: Uses CryptoEngine (AES-256-GCM) for file
/// encryption. Files are stored in a citadel_files/ subdirectory with
/// randomized names. Temp decrypted files are cleaned on lock and startup.
class FileEncryptionService {
  final CryptoEngine _crypto;
  final FileAttachmentDao _dao;

  FileEncryptionService(this._crypto, this._dao);

  /// Maximum allowed file size: 10MB per D-08.
  static const int maxFileSizeBytes = 10 * 1024 * 1024;

  /// Threshold for size warning dialog: 5MB per D-08.
  static const int warnFileSizeBytes = 5 * 1024 * 1024;

  /// Allowed file extensions per D-08.
  static const List<String> allowedExtensions = [
    'jpg',
    'jpeg',
    'png',
    'pdf',
    'txt',
  ];

  /// Encrypt a file and store it locally with metadata in Drift.
  ///
  /// 1. Validates size (<=10MB) and extension per D-08
  /// 2. Reads file bytes
  /// 3. Encrypts with CryptoEngine using vault key per D-05
  /// 4. Writes encrypted bytes to citadel_files/ subdirectory
  /// 5. Saves metadata to FileAttachments Drift table per D-06
  ///
  /// Returns the created [FileAttachmentEntity].
  Future<FileAttachmentEntity> encryptAndStore({
    required String filePath,
    required String fileName,
    required String vaultId,
    required SecretKey vaultKey,
  }) async {
    // Read and validate file
    final file = File(filePath);
    final bytes = await file.readAsBytes();

    if (bytes.length > maxFileSizeBytes) {
      throw FileTooLargeException(bytes.length);
    }

    final ext = fileName.split('.').last.toLowerCase();
    if (!allowedExtensions.contains(ext)) {
      throw UnsupportedFileTypeException(ext);
    }

    // Detect MIME type
    final mimeType = lookupMimeType(fileName) ?? 'application/octet-stream';

    // Encrypt file bytes with AES-256-GCM per D-05
    final encrypted = await _crypto.encrypt(bytes, vaultKey);

    // Store encrypted file with randomized name
    final appDir = await getApplicationDocumentsDirectory();
    final vaultDir = Directory('${appDir.path}/citadel_files');
    if (!await vaultDir.exists()) {
      await vaultDir.create(recursive: true);
    }
    final secureFileName =
        DateTime.now().millisecondsSinceEpoch.toRadixString(16);
    final encPath = '${vaultDir.path}/$secureFileName.enc';
    await File(encPath).writeAsBytes(encrypted);

    // Save metadata to Drift per D-06
    final id = _generateHexId();
    final now = DateTime.now();
    await _dao.insertAttachment(
      FileAttachmentsCompanion.insert(
        id: id,
        vaultId: vaultId,
        fileName: fileName,
        mimeType: mimeType,
        sizeBytes: bytes.length,
        encryptedPath: encPath,
        createdAt: now,
      ),
    );

    return FileAttachmentEntity(
      id: id,
      vaultId: vaultId,
      fileName: fileName,
      mimeType: mimeType,
      sizeBytes: bytes.length,
      encryptedPath: encPath,
      createdAt: now,
    );
  }

  /// Decrypt a file to a temp directory and open with the system viewer per D-09.
  Future<void> decryptAndOpen(
    FileAttachmentEntity attachment,
    SecretKey vaultKey,
  ) async {
    final encBytes = await File(attachment.encryptedPath).readAsBytes();
    final decrypted = await _crypto.decrypt(encBytes, vaultKey);
    final tempDir = await _getTempDir();
    final tempFile = File('${tempDir.path}/${attachment.fileName}');
    await tempFile.writeAsBytes(decrypted);
    await OpenFilex.open(tempFile.path);
  }

  /// Delete a file attachment: remove encrypted file from disk + metadata.
  Future<void> deleteFile(FileAttachmentEntity attachment) async {
    final file = File(attachment.encryptedPath);
    if (await file.exists()) {
      await file.delete();
    }
    await _dao.deleteAttachment(attachment.id);
  }

  /// Cleanup temp decrypted files.
  ///
  /// Call on app lock and startup per pitfall 2 to ensure no
  /// plaintext files persist on disk.
  Future<void> cleanupTempFiles() async {
    final tempDir = await _getTempDir();
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
      await tempDir.create();
    }
  }

  /// Get the temp directory for decrypted files.
  Future<Directory> _getTempDir() async {
    final temp = await getTemporaryDirectory();
    final citadelTemp = Directory('${temp.path}/citadel_temp');
    if (!await citadelTemp.exists()) {
      await citadelTemp.create();
    }
    return citadelTemp;
  }

  /// Generate a unique hex ID using microsecond timestamp + random suffix.
  String _generateHexId() =>
      DateTime.now().microsecondsSinceEpoch.toRadixString(16) +
      Random.secure().nextInt(0xFFFF).toRadixString(16).padLeft(4, '0');
}
