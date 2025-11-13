// File: lib/core/providers/session_timeout_provider.dart
// Riverpod providers for session timeout configuration and service.
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/core_providers.dart';
import '../session/session_timeout_service.dart';
import 'session_provider.dart';

/// Settings key for the auto-lock timeout (stored in SettingsDao).
const kSessionTimeoutKey = 'session_timeout_minutes';

/// Default timeout in minutes.
const kDefaultTimeoutMinutes = 5;

/// Available auto-lock options: value (minutes) -> display label.
const Map<int, String> autoLockOptions = {
  0: 'Never',
  1: '1 minute',
  5: '5 minutes',
  15: '15 minutes',
  30: '30 minutes',
};

/// Reads the persisted session timeout from SettingsDao.
final sessionTimeoutSettingProvider = FutureProvider<int>((ref) async {
  final db = ref.watch(appDatabaseProvider);
  final value = await db.settingsDao.getSetting(kSessionTimeoutKey);
  if (value == null) return kDefaultTimeoutMinutes;
  return int.tryParse(value) ?? kDefaultTimeoutMinutes;
});

/// Settings key for "lock on background" toggle.
const kLockOnBackgroundKey = 'lock_on_background';

/// Reads the persisted lock-on-background setting.
final lockOnBackgroundSettingProvider = FutureProvider<bool>((ref) async {
  final db = ref.watch(appDatabaseProvider);
  final value = await db.settingsDao.getSetting(kLockOnBackgroundKey);
  return value == 'true'; // defaults to false
});

/// Provides the singleton SessionTimeoutService wired to lock the session.
final sessionTimeoutServiceProvider = Provider<SessionTimeoutService>((ref) {
  final sessionNotifier = ref.read(sessionProvider.notifier);

  final service = SessionTimeoutService(
    onTimeout: () => sessionNotifier.lock(),
  );

  // Configure from persisted setting (async — fire and forget initial load).
  ref.listen<AsyncValue<int>>(sessionTimeoutSettingProvider, (_, next) {
    final minutes = next.value ?? kDefaultTimeoutMinutes;
    service.configure(minutes);
  });

  ref.onDispose(() => service.dispose());

  return service;
});
