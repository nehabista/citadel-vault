// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'file_attachment_dao.dart';

// ignore_for_file: type=lint
mixin _$FileAttachmentDaoMixin on DatabaseAccessor<AppDatabase> {
  $FileAttachmentsTable get fileAttachments => attachedDatabase.fileAttachments;
  FileAttachmentDaoManager get managers => FileAttachmentDaoManager(this);
}

class FileAttachmentDaoManager {
  final _$FileAttachmentDaoMixin _db;
  FileAttachmentDaoManager(this._db);
  $$FileAttachmentsTableTableManager get fileAttachments =>
      $$FileAttachmentsTableTableManager(
        _db.attachedDatabase,
        _db.fileAttachments,
      );
}
