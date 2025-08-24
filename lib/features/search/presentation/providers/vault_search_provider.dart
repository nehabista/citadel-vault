// File: lib/features/search/presentation/providers/vault_search_provider.dart
// Debounced search provider filtering decrypted vault items (D-01)
import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../vault/domain/entities/vault_item.dart';
import '../../../vault/presentation/providers/multi_vault_provider.dart';

/// Pure function for filtering items by query across name, username, url, notes.
/// Exported for testability without Riverpod container.
List<VaultItemEntity> filterItems(List<VaultItemEntity> items, String query) {
  if (query.isEmpty) return [];
  final lowerQuery = query.toLowerCase();
  return items.where((item) {
    return item.name.toLowerCase().contains(lowerQuery) ||
        (item.username?.toLowerCase().contains(lowerQuery) ?? false) ||
        (item.url?.toLowerCase().contains(lowerQuery) ?? false) ||
        (item.notes?.toLowerCase().contains(lowerQuery) ?? false);
  }).toList();
}

/// Search state variants.
sealed class VaultSearchState {
  const VaultSearchState();
}

/// No active search query.
class VaultSearchEmpty extends VaultSearchState {
  const VaultSearchEmpty();
}

/// Active search with results.
class VaultSearchResults extends VaultSearchState {
  final String query;
  final List<VaultItemEntity> items;

  const VaultSearchResults({required this.query, required this.items});
}

/// Debounced search notifier for vault items.
/// 300ms debounce per D-01 requirement.
class VaultSearchNotifier extends Notifier<VaultSearchState> {
  Timer? _debounce;

  @override
  VaultSearchState build() {
    ref.onDispose(() => _debounce?.cancel());
    return const VaultSearchEmpty();
  }

  /// Update the search query with 300ms debounce.
  void updateQuery(String query) {
    _debounce?.cancel();
    if (query.isEmpty) {
      state = const VaultSearchEmpty();
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 300), () {
      _performSearch(query);
    });
  }

  /// Clear the search.
  void clear() {
    _debounce?.cancel();
    state = const VaultSearchEmpty();
  }

  void _performSearch(String query) {
    final items = ref.read(multiVaultProvider).items;
    final results = filterItems(items, query);
    state = VaultSearchResults(query: query, items: results);
  }
}

final vaultSearchProvider =
    NotifierProvider<VaultSearchNotifier, VaultSearchState>(
  VaultSearchNotifier.new,
);
