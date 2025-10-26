import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/core_providers.dart';
import '../../../../core/providers/sync_providers.dart';
import '../../data/services/travel_mode_service.dart';

/// Provides the TravelModeService with all dependencies injected.
final travelModeServiceProvider = Provider<TravelModeService>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return TravelModeService(
    db.vaultDao,
    db.settingsDao,
    ref.watch(syncEngineProvider),
  );
});

/// FutureProvider that reads whether travel mode is currently active.
///
/// Invalidate this provider after activating/deactivating to refresh the UI.
final travelModeActiveProvider = FutureProvider<bool>((ref) async {
  final service = ref.watch(travelModeServiceProvider);
  return service.isActive();
});
