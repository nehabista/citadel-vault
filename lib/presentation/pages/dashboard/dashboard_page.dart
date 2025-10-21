// File: lib/presentation/pages/dashboard/dashboard_page.dart
// Rewritten dashboard with multi-vault tabs, search bar, and item cards
// Implements D-01 (search), D-02 (highlighting), D-03 (always-visible search),
// D-08 (vault tabs), D-09 (vault creation), D-19 (Material 3 styling), D-20 (item cards)
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../features/notifications/presentation/widgets/alert_banner_widget.dart';
import '../../../features/search/presentation/providers/vault_search_provider.dart';
import '../../../features/sharing/presentation/widgets/shared_vault_selector.dart';
import '../../../features/vault/domain/entities/vault_item.dart';
import '../../../features/vault/presentation/providers/multi_vault_provider.dart';
import 'widgets/vault_item_card.dart';
import 'widgets/vault_tabs.dart';

/// Provider for the selected item type filter tab index.
class _TypeFilterNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void select(int index) => state = index;
}

final _typeFilterProvider =
    NotifierProvider<_TypeFilterNotifier, int>(_TypeFilterNotifier.new);

class DashBoardPage extends ConsumerStatefulWidget {
  const DashBoardPage({super.key});

  @override
  ConsumerState<DashBoardPage> createState() => _DashBoardPageState();
}

class _DashBoardPageState extends ConsumerState<DashBoardPage> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(vaultSearchProvider);
    final vaultState = ref.watch(multiVaultProvider);
    final typeFilter = ref.watch(_typeFilterProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Alert banner for breach/emergency alerts (D-17)
          const AlertBannerWidget(),

          // Always-visible search bar (D-03)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
            child: Container(
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFE8EDF5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.search, color: Colors.grey),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onChanged: (query) {
                        ref.read(vaultSearchProvider.notifier).updateQuery(query);
                      },
                      decoration: InputDecoration(
                        hintText: 'Search vault items...',
                        hintStyle: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                          fontFamily: 'Poppins',
                        ),
                        border: InputBorder.none,
                        isCollapsed: true,
                      ),
                      style: const TextStyle(
                        fontSize: 14,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ),
                  if (_searchController.text.isNotEmpty)
                    GestureDetector(
                      onTap: () {
                        _searchController.clear();
                        ref.read(vaultSearchProvider.notifier).clear();
                      },
                      child: const Icon(Icons.close, color: Colors.grey, size: 20),
                    ),
                ],
              ),
            ),
          ),

          // Vault tabs with color-coded pills and create dialog
          const VaultTabs(),

          // Shared vault selector (D-21)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: SharedVaultSelector(),
          ),
          const SizedBox(height: 8),

          // Type filter tabs
          _TypeFilterBar(
            selectedIndex: typeFilter,
            onSelected: (index) {
              ref.read(_typeFilterProvider.notifier).select(index);
            },
          ),
          const SizedBox(height: 4),

          // Item list
          Expanded(
            child: _buildItemList(searchState, vaultState, typeFilter),
          ),
        ],
      ),
    );
  }

  Widget _buildItemList(
    VaultSearchState searchState,
    MultiVaultState vaultState,
    int typeFilter,
  ) {
    // If search is active, show search results
    if (searchState is VaultSearchResults) {
      return _buildSearchResults(searchState);
    }

    // Otherwise show vault items filtered by type
    if (vaultState.isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF4D4DCD),
        ),
      );
    }

    if (vaultState.error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            Text(
              'Error loading items',
              style: TextStyle(
                fontFamily: 'Poppins',
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            FilledButton(
              onPressed: () {
                ref.read(multiVaultProvider.notifier).refreshItems();
              },
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF4D4DCD),
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (vaultState.vaults.isEmpty) {
      return _buildEmptyVaults();
    }

    final items = _filterByType(vaultState.items, typeFilter);

    if (items.isEmpty) {
      return _buildEmptyItems();
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(multiVaultProvider.notifier).refreshItems(),
      color: const Color(0xFF4D4DCD),
      child: ListView.builder(
        padding: const EdgeInsets.only(top: 4, bottom: 80),
        itemCount: items.length,
        itemBuilder: (context, index) {
          return VaultItemCard(item: items[index]);
        },
      ),
    );
  }

  Widget _buildSearchResults(VaultSearchResults searchState) {
    if (searchState.items.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off, size: 48, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            Text(
              'No matching items',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Try checking other vaults',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 13,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(top: 4, bottom: 80),
      itemCount: searchState.items.length,
      itemBuilder: (context, index) {
        return VaultItemCard(
          item: searchState.items[index],
          searchQuery: searchState.query,
        );
      },
    );
  }

  Widget _buildEmptyVaults() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.shield_outlined, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            'No vaults yet',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w600,
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create your first vault to get started',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyItems() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.inbox_outlined, size: 48, color: Colors.grey.shade400),
          const SizedBox(height: 12),
          Text(
            'No items yet',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Tap + to add your first item',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  List<VaultItemEntity> _filterByType(List<VaultItemEntity> items, int typeIndex) {
    if (typeIndex == 0) return items; // "All"
    final type = VaultItemType.values[typeIndex - 1];
    return items.where((item) => item.type == type).toList();
  }
}

/// Secondary horizontal type filter tabs.
class _TypeFilterBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  const _TypeFilterBar({
    required this.selectedIndex,
    required this.onSelected,
  });

  static const _tabs = [
    (icon: Icons.grid_view_rounded, text: 'All'),
    (icon: Icons.lock_outline, text: 'Passwords'),
    (icon: Icons.sticky_note_2_outlined, text: 'Notes'),
    (icon: Icons.contact_page_outlined, text: 'Contacts'),
    (icon: Icons.account_balance_outlined, text: 'Banks'),
    (icon: Icons.credit_card_outlined, text: 'Cards'),
    (icon: Icons.wifi_outlined, text: 'WiFi'),
    (icon: Icons.code_outlined, text: 'Licenses'),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        itemCount: _tabs.length,
        itemBuilder: (context, index) {
          final tab = _tabs[index];
          final isSelected = index == selectedIndex;

          return Padding(
            padding: const EdgeInsets.only(right: 6),
            child: GestureDetector(
              onTap: () => onSelected(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF4D4DCD) : Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF4D4DCD)
                        : Colors.grey.shade300,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      tab.icon,
                      size: 14,
                      color: isSelected ? Colors.white : Colors.grey.shade600,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      tab.text,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: isSelected ? Colors.white : Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
