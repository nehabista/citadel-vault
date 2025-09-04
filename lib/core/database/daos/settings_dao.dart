<<<<<<< HEAD
import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/settings_table.dart';

part 'settings_dao.g.dart';

/// Data access object for key-value settings storage.
/// Replaces SharedPreferences with encrypted database storage.
@DriftAccessor(tables: [Settings])
class SettingsDao extends DatabaseAccessor<AppDatabase> with _$SettingsDaoMixin {
  SettingsDao(super.db);

  /// Set a setting value (upsert: insert or update on conflict).
  Future<void> setSetting(String key, String value) {
    return into(settings).insertOnConflictUpdate(
      SettingsCompanion.insert(key: key, value: value),
    );
  }

  /// Get a setting value by key, returns null if not found.
  Future<String?> getSetting(String key) async {
    final result = await (select(settings)
          ..where((t) => t.key.equals(key)))
        .getSingleOrNull();
    return result?.value;
  }

  /// Delete a setting by key.
  Future<void> deleteSetting(String key) {
    return (delete(settings)..where((t) => t.key.equals(key))).go();
  }
=======
/// Abstract interface for key-value settings storage.
///
/// The concrete implementation uses Drift (see Phase 01-02).
/// This abstract class allows services to depend on the interface
/// without requiring the full Drift database dependency.
abstract class SettingsDao {
  /// Set a setting value (upsert: insert or update on conflict).
  Future<void> setSetting(String key, String value);

  /// Get a setting value by key, returns null if not found.
  Future<String?> getSetting(String key);

  /// Delete a setting by key.
  Future<void> deleteSetting(String key);
>>>>>>> worktree-agent-a3396e4b
}
