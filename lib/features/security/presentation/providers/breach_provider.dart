import 'package:cryptography/cryptography.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/core_providers.dart';
import '../../../../core/providers/session_provider.dart';
import '../../../../core/session/session_state.dart';
import '../../../vault/domain/entities/vault_item.dart';
import '../../domain/entities/breach_result.dart';
import 'watchtower_provider.dart';

/// Background breach check provider triggered on unlock (D-09).
///
/// Gets all vault items with passwords, checks each against HIBP via
/// BreachRepository.checkPasswordCached with 150ms throttle between calls.
/// After completion, updates watchtowerProvider with breached items.
final backgroundBreachCheckProvider = FutureProvider<void>((ref) async {
  final session = ref.watch(sessionProvider);
  if (session is! Unlocked) return;

  final vaultRepo = ref.read(vaultRepositoryProvider);
  final breachRepo = ref.read(breachRepositoryProvider);

  final items = await vaultRepo.getAllItems(SecretKey(session.vaultKey));
  final passwordItems = items
      .where((item) => item.password != null && item.password!.isNotEmpty)
      .toList();

  final breachedItems = <VaultItemEntity>[];
  final results = <String, BreachResult>{};

  for (final item in passwordItems) {
    try {
      final result = await breachRepo.checkPasswordCached(item.password!);
      results[item.id] = result;
      if (result is BreachResultBreached) {
        breachedItems.add(item);
      }
    } catch (_) {
      // Skip items that fail (network errors, etc.)
      results[item.id] = const BreachResult.notChecked();
    }

    // Throttle: 150ms between HIBP API calls per D-09
    await Future<void>.delayed(const Duration(milliseconds: 150));
  }

  // Update watchtower with breached items
  ref.read(watchtowerProvider.notifier).updateWithBreachedItems(breachedItems);
});

/// Provider mapping vault item IDs to their breach check results.
///
/// Populated after the background breach check completes.
final breachedItemsProvider =
    FutureProvider<Map<String, BreachResult>>((ref) async {
  final session = ref.watch(sessionProvider);
  if (session is! Unlocked) return {};

  final vaultRepo = ref.read(vaultRepositoryProvider);
  final breachRepo = ref.read(breachRepositoryProvider);

  final items = await vaultRepo.getAllItems(SecretKey(session.vaultKey));
  final passwordItems = items
      .where((item) => item.password != null && item.password!.isNotEmpty)
      .toList();

  final results = <String, BreachResult>{};
  for (final item in passwordItems) {
    try {
      final result = await breachRepo.checkPasswordCached(item.password!);
      results[item.id] = result;
    } catch (_) {
      results[item.id] = const BreachResult.notChecked();
    }

    await Future<void>.delayed(const Duration(milliseconds: 150));
  }

  return results;
});

/// Per-password breach check provider with caching.
/// Replaces FutureBuilder anti-pattern in ConsumerWidgets.
final breachCheckProvider =
    FutureProvider.family<BreachResult, String>((ref, password) async {
  final breachRepo = ref.watch(breachRepositoryProvider);
  return breachRepo.checkPasswordCached(password);
});
