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
}
