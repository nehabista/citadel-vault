/// Plaintext domain entity for file vault attachments.
///
/// Per D-06: represents metadata about an encrypted file stored locally.
/// The actual file content is encrypted with AES-256-GCM and stored at
/// [encryptedPath]. This entity holds the plaintext metadata.
class FileAttachmentEntity {
  final String id;
  final String vaultId;
  final String fileName;
  final String mimeType;
  final int sizeBytes;
  final String encryptedPath;
  final DateTime createdAt;

  const FileAttachmentEntity({
    required this.id,
    required this.vaultId,
    required this.fileName,
    required this.mimeType,
    required this.sizeBytes,
    required this.encryptedPath,
    required this.createdAt,
  });

  /// Human-readable file size.
  String get formattedSize {
    if (sizeBytes < 1024) return '$sizeBytes B';
    if (sizeBytes < 1024 * 1024) {
      return '${(sizeBytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(sizeBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
