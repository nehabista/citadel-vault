import 'package:drift/drift.dart';

/// File attachments for the encrypted file vault per D-06.
/// Stores metadata about encrypted files stored locally.
class FileAttachments extends Table {
  /// UUID primary key
  TextColumn get id => text()();

  /// The vault this attachment belongs to
  TextColumn get vaultId => text()();

  /// Original file name (encrypted at rest in the vault blob)
  TextColumn get fileName => text()();

  /// MIME type of the original file (e.g., 'application/pdf')
  TextColumn get mimeType => text()();

  /// Size of the original file in bytes
  IntColumn get sizeBytes => integer()();

  /// Path to the encrypted file on local storage
  TextColumn get encryptedPath => text()();

  /// When the attachment was added
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
