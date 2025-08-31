// File: lib/main.dart
// App entry point with ProviderScope wrapping (Riverpod)
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mcp_toolkit/mcp_toolkit.dart';

import 'dart:math';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import 'app.dart';
import 'core/database/app_database.dart';
import 'core/providers/core_providers.dart';
import 'data/services/api/pocketbase_service.dart';

Future<void> main() async {
  MCPToolkitBinding.instance.initialize();

  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  // Initialize PocketBase (async auth store from secure storage)
  final pbService = PocketBaseService();
  await pbService.init();

  // Initialize encrypted database
  final db = await _openDatabase();

  MCPToolkitBinding.instance.initializeFlutterToolkit();

  runZonedGuarded(
    () {
      runApp(
        ProviderScope(
          overrides: [
            pocketBaseServiceProvider.overrideWithValue(pbService),
            appDatabaseProvider.overrideWithValue(db),
          ],
          child: const CitadelApp(),
        ),
      );
    },
    MCPToolkitBinding.instance.handleZoneError,
  );
}

/// Opens the encrypted Drift database.
/// Generates and stores a DB encryption key in secure storage on first run.
Future<AppDatabase> _openDatabase() async {
  const storage = FlutterSecureStorage();
  const dbKeyName = 'citadel_db_key';

  var dbKey = await storage.read(key: dbKeyName);
  if (dbKey == null) {
    // Generate a random 32-char hex key on first launch
    final random = Random.secure();
    final bytes = List<int>.generate(16, (_) => random.nextInt(256));
    dbKey = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
    await storage.write(key: dbKeyName, value: dbKey);
  }

  final appDir = await getApplicationDocumentsDirectory();
  final dbPath = p.join(appDir.path, 'citadel_vault.db');

  return AppDatabase.encrypted(dbPath, dbKey);
}
