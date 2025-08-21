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
import 'daos/vault_dao.dart';
import 'daos/sync_dao.dart';
import 'daos/settings_dao.dart';
import 'daos/password_history_dao.dart';

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
  ],
  daos: [VaultDao, SyncDao, SettingsDao, PasswordHistoryDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onUpgrade: (migrator, from, to) async {
        if (from < 2) {
          // Add colorHex and iconName columns to vaults table.
          await migrator.addColumn(vaults, vaults.colorHex);
          await migrator.addColumn(vaults, vaults.iconName);
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
