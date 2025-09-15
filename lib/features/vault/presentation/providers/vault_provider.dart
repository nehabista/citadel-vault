// File: lib/features/vault/presentation/providers/vault_provider.dart
// Legacy vault provider — kept for compatibility but delegates to VaultRepository.
// New code should use multiVaultProvider instead.
import 'package:cryptography/cryptography.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/core_providers.dart';
import '../../../../core/providers/session_provider.dart';
import '../../../../core/session/session_state.dart';
import '../../domain/entities/vault_item.dart';

/// Vault state
class VaultState {
  final bool isLoading;
  final List<VaultItemEntity> allItems;
  final List<VaultItemEntity> filteredItems;
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
    List<VaultItemEntity>? allItems,
    List<VaultItemEntity>? filteredItems,
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

/// Session-gated vault notifier using VaultRepository.
class VaultNotifier extends Notifier<VaultState> {
  @override
  VaultState build() {
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
      Unlocked(vaultKey: final keyBytes) => _doFetchItems(keyBytes),
    };
  }

  Future<void> _doFetchItems(List<int> keyBytes) async {
    state = state.copyWith(isLoading: true);
    try {
      final repo = ref.read(vaultRepositoryProvider);
      final vaultKey = SecretKey(keyBytes);
      final items = await repo.getAllItems(vaultKey);
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
      final repo = ref.read(vaultRepositoryProvider);
      await repo.deleteItem(itemId);
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
