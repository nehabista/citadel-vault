import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/core_providers.dart';
import '../../data/services/clipboard_service.dart';

/// Provider for the clipboard auto-clear timeout duration.
///
/// Reads the `clipboard_timeout` setting from SettingsDao.
/// Default: 30 seconds. Allowed values per D-13: 0 (never), 15, 30, 60, 300.
final clipboardTimeoutProvider = FutureProvider<Duration>((ref) async {
  final db = ref.watch(appDatabaseProvider);
  final value = await db.settingsDao.getSetting('clipboard_timeout');

  // Default to 30 seconds if not set
  final seconds = int.tryParse(value ?? '') ?? 30;
  return Duration(seconds: seconds);
});

/// Provider for ClipboardService instance.
///
/// Manages clipboard operations with auto-clear timer and sensitive flag.
final clipboardServiceProvider = Provider<ClipboardService>((ref) {
  return ClipboardService(ref);
});

/// Tracks when the clipboard will be cleared (for optional UI countdown).
///
/// null means no pending clear. The DateTime value is when the clear is
/// scheduled to happen.
final clipboardTimerStateProvider =
    NotifierProvider<ClipboardTimerNotifier, DateTime?>(
        ClipboardTimerNotifier.new);

/// Notifier for clipboard timer state.
class ClipboardTimerNotifier extends Notifier<DateTime?> {
  @override
  DateTime? build() => null;

  /// Set when the clipboard will be cleared.
  void setClearTime(DateTime? time) {
    state = time;
  }
}
