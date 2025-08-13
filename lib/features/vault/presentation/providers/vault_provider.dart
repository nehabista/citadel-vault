// File: lib/features/vault/presentation/providers/vault_provider.dart
// Session-gated vault provider using exhaustive switch on SessionState
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/core_providers.dart';
import '../../../../core/providers/session_provider.dart';
import '../../../../core/session/session_state.dart';
import '../../../../data/models/vault_item_model.dart';

/// Vault state
class VaultState {
  final bool isLoading;
  final List<VaultItem> allItems;
  final List<VaultItem> filteredItems;
  final VaultItemType? selectedFilter;
  final String? errorMessage;

  const VaultState({
    this.isLoading = true,
    this.allItems = const [],
    this.filteredItems = const [],
    this.selectedFilter,
    this.errorMessage,
  });

  VaultState copyWith({
    bool? isLoading,
    List<VaultItem>? allItems,
    List<VaultItem>? filteredItems,
    VaultItemType? Function()? selectedFilter,
    String? errorMessage,
  }) {
    return VaultState(
      isLoading: isLoading ?? this.isLoading,
      allItems: allItems ?? this.allItems,
      filteredItems: filteredItems ?? this.filteredItems,
      selectedFilter:
          selectedFilter != null ? selectedFilter() : this.selectedFilter,
      errorMessage: errorMessage,
    );
  }
}

/// Session-gated vault notifier.
/// Uses exhaustive switch on SessionState for compile-time safety.
class VaultNotifier extends Notifier<VaultState> {
  @override
  VaultState build() {
    // Watch session state -- rebuild when it changes
    final session = ref.watch(sessionProvider);
    return switch (session) {
      Locked() => const VaultState(isLoading: false, errorMessage: 'Vault is locked'),
      Unlocked() => const VaultState(isLoading: true),
    };
  }

  Future<void> fetchItems() async {
    final session = ref.read(sessionProvider);
    return switch (session) {
      Locked() => throw const VaultLockedException(),
      Unlocked() => _doFetchItems(),
    };
  }

  Future<void> _doFetchItems() async {
    state = state.copyWith(isLoading: true);
    try {
      final vaultService = ref.read(vaultServiceProvider);
      final items = await vaultService.fetchAndDecryptVaultItems();
      state = state.copyWith(
        isLoading: false,
        allItems: items,
        filteredItems: items,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  void changeFilter(int tabIndex) {
    VaultItemType? filter;
    if (tabIndex != 0) {
      filter = VaultItemType.values[tabIndex - 1];
    }
    final filtered = filter == null
        ? state.allItems
        : state.allItems.where((item) => item.type == filter).toList();
    state = state.copyWith(
      selectedFilter: () => filter,
      filteredItems: filtered,
    );
  }

  Future<void> deleteItem(String itemId) async {
    final session = ref.read(sessionProvider);
    return switch (session) {
      Locked() => throw const VaultLockedException(),
      Unlocked() => _doDeleteItem(itemId),
    };
  }

  Future<void> _doDeleteItem(String itemId) async {
    try {
      final vaultService = ref.read(vaultServiceProvider);
      await vaultService.deleteVaultItem(itemId);
      final updated = state.allItems.where((i) => i.id != itemId).toList();
      state = state.copyWith(allItems: updated);
      changeFilter(
        state.selectedFilter == null
            ? 0
            : VaultItemType.values.indexOf(state.selectedFilter!) + 1,
      );
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
    }
  }
}

final vaultProvider =
    NotifierProvider<VaultNotifier, VaultState>(VaultNotifier.new);
