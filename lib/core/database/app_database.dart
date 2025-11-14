import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';

import 'tables/vaults_table.dart';
import 'tables/vault_items_table.dart';
import 'tables/sync_queue_table.dart';
import 'tables/totp_entries_table.dart';
import 'tables/password_history_table.dart';
import 'tables/autofill_index_table.dart';
import 'tables/settings_table.dart';
import 'tables/shared_items_table.dart';
import 'tables/vault_members_table.dart';
import 'tables/emergency_contacts_table.dart';
import 'tables/notifications_table.dart';
import 'tables/file_attachments_table.dart';
import 'daos/vault_dao.dart';
import 'daos/sync_dao.dart';
import 'daos/settings_dao.dart';
import 'daos/password_history_dao.dart';
import 'daos/totp_dao.dart';
import 'daos/sharing_dao.dart';
import 'daos/notification_dao.dart';
import 'daos/file_attachment_dao.dart';
import '../../features/autofill/data/daos/autofill_index_dao.dart';

part 'app_database.g.dart';

/// Main Drift database with SQLCipher encryption support.
///
/// Per D-06: SQLCipher encrypts the entire DB file with a key stored in
/// platform Keystore/Keychain. This is the outer encryption layer.
/// Individual vault items are also encrypted with the vault key
/// (Argon2id-derived from master password) -- two-layer defense in depth.
@DriftDatabase(
  tables: [
    Vaults,
    VaultItems,
    SyncQueue,
    TotpEntries,
    PasswordHistory,
    AutofillIndex,
    Settings,
    SharedItems,
    VaultMembers,
    EmergencyContacts,
    NotificationRecords,
    FileAttachments,
  ],
  daos: [VaultDao, SyncDao, SettingsDao, PasswordHistoryDao, TotpDao, AutofillIndexDao, SharingDao, NotificationDao, FileAttachmentDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  @override
  int get schemaVersion => 5;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onUpgrade: (migrator, from, to) async {
        if (from < 2) {
          // Add colorHex and iconName columns to vaults table.
          await migrator.addColumn(vaults, vaults.colorHex);
          await migrator.addColumn(vaults, vaults.iconName);
        }
        if (from < 3) {
          // Add sharing, emergency contacts, and notifications tables.
          await migrator.createTable(sharedItems);
          await migrator.createTable(vaultMembers);
          await migrator.createTable(emergencyContacts);
          await migrator.createTable(notificationRecords);
        }
        if (from < 4) {
          // Add travel mode column and file attachments table.
          await migrator.addColumn(vaults, vaults.isTravelSafe);
          await migrator.createTable(fileAttachments);
        }
        if (from < 5) {
          // Add soft-hide column for travel mode (replaces hard deletion).
          await migrator.addColumn(vaults, vaults.isHiddenByTravel);
        }
      },
    );
  }

  /// Creates an encrypted database using SQLCipher via sqlite3mc.
  /// Per D-06: PRAGMA key sets the encryption passphrase.
  factory AppDatabase.encrypted(String dbPath, String encryptionKey) {
    return AppDatabase(
      NativeDatabase(
        File(dbPath),
        setup: (rawDb) {
          rawDb.execute("PRAGMA key = '$encryptionKey';");
        },
      ),
    );
  }

  /// Creates an in-memory database for testing (no encryption).
  factory AppDatabase.inMemory() {
    return AppDatabase(NativeDatabase.memory());
  }
}
