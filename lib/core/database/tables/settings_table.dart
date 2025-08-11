import 'package:drift/drift.dart';

/// Settings table - key-value store for app configuration.
/// Replaces SharedPreferences with encrypted database storage.
class Settings extends Table {
  /// Setting key (primary key)
  TextColumn get key => text()();

  /// Setting value
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}
