// File: lib/features/vault/presentation/providers/multi_vault_provider.dart
// Multi-vault state management with selected vault, vault list, CRUD
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../../core/providers/session_provider.dart';
import '../../../../core/session/session_state.dart';
import '../../domain/entities/vault_item.dart';

/// State for multi-vault management.
class MultiVaultState {
  final List<Vault> vaults;
  final String? selectedVaultId;
  final List<VaultItemEntity> items;
  final bool isLoading;
  final String? error;

  const MultiVaultState({
    this.vaults = const [],
    this.selectedVaultId,
    this.items = const [],
    this.isLoading = false,
    this.error,
  });

  MultiVaultState copyWith({
    List<Vault>? vaults,
    String? Function()? selectedVaultId,
    List<VaultItemEntity>? items,
    bool? isLoading,
    String? Function()? error,
  }) {
    return MultiVaultState(
      vaults: vaults ?? this.vaults,
      selectedVaultId: selectedVaultId != null
          ? selectedVaultId()
          : this.selectedVaultId,
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      error: error != null ? error() : this.error,
    );
  }

  /// Get the currently selected vault object.
  Vault? get selectedVault {
    if (selectedVaultId == null) return null;
    try {
      return vaults.firstWhere((v) => v.id == selectedVaultId);
    } catch (_) {
      return null;
    }
  }
}

/// Multi-vault notifier managing vault list, selection, and item loading.
class MultiVaultNotifier extends Notifier<MultiVaultState> {
  @override
  MultiVaultState build() {
    final session = ref.watch(sessionProvider);
    return switch (session) {
      Locked() => const MultiVaultState(),
      Unlocked() => _initialize(),
    };
  }

  MultiVaultState _initialize() {
    // Trigger async loading
    Future.microtask(() => _loadVaults());
    return const MultiVaultState(isLoading: true);
  }

  Future<void> _loadVaults() async {
    try {
      final repo = ref.read(vaultRepositoryProvider);
      var vaults = await repo.getVaults();

      // Auto-create a default "Personal" vault on first login.
      if (vaults.isEmpty) {
        final defaultId = DateTime.now().millisecondsSinceEpoch.toString();
        await repo.createVault(
          id: defaultId,
          name: 'Personal',
          colorHex: '#4D4DCD',
          iconName: 'shield',
        );
        vaults = await repo.getVaults();
      }

      final selectedId = state.selectedVaultId ?? vaults.first.id;
      state = state.copyWith(
        vaults: vaults,
        selectedVaultId: () => selectedId,
        isLoading: true,
      );

      await _loadItemsForVault(selectedId);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: () => e.toString(),
      );
    }
  }

  Future<void> _loadItemsForVault(String vaultId) async {
    try {
      final session = ref.read(sessionProvider);
      if (session is! Unlocked) return;

      final repo = ref.read(vaultRepositoryProvider);
      final vaultKey = SecretKey(Uint8List.fromList(session.vaultKey));
      final items = await repo.getItems(vaultId, vaultKey);

      state = state.copyWith(
        items: items,
        isLoading: false,
        error: () => null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: () => e.toString(),
      );
    }
  }

  /// Select a vault and load its items.
  Future<void> selectVault(String vaultId) async {
    state = state.copyWith(
      selectedVaultId: () => vaultId,
      isLoading: true,
    );
    await _loadItemsForVault(vaultId);
  }

  /// Create a new vault and select it.
  Future<void> createVault(
    String name, {
    String colorHex = '#4D4DCD',
    String iconName = 'shield',
  }) async {
    try {
      final repo = ref.read(vaultRepositoryProvider);
      final id = DateTime.now().millisecondsSinceEpoch.toString();
      await repo.createVault(
        id: id,
        name: name,
        colorHex: colorHex,
        iconName: iconName,
      );
      await _loadVaults();
      await selectVault(id);
    } catch (e) {
      state = state.copyWith(error: () => e.toString());
    }
  }

  /// Delete a vault and switch to first remaining vault.
  Future<void> deleteVault(String vaultId) async {
    try {
      final repo = ref.read(vaultRepositoryProvider);
      await repo.deleteVault(vaultId);
      await _loadVaults();
    } catch (e) {
      state = state.copyWith(error: () => e.toString());
    }
  }

  /// Refresh items for the currently selected vault.
  Future<void> refreshItems() async {
    final selectedId = state.selectedVaultId;
    if (selectedId == null) return;
    state = state.copyWith(isLoading: true);
    await _loadItemsForVault(selectedId);
  }
}

final multiVaultProvider =
    NotifierProvider<MultiVaultNotifier, MultiVaultState>(
  MultiVaultNotifier.new,
);
