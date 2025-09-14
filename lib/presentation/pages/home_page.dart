// File: lib/presentation/pages/home_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:icons_plus/icons_plus.dart';

import '../../features/password_generator/presentation/pages/generator_page.dart';
import '../../features/security/presentation/pages/watchtower_page.dart';
import '../../features/security/presentation/providers/expiry_provider.dart';
import '../../features/vault/domain/entities/vault_item.dart';
import '../../gen/assets.gen.dart';
import '../../routing/app_router.dart';
import '../widgets/bottom_nav_item.dart';
import 'dashboard/dashboard_page.dart';
import 'settings/settings_page.dart';

/// Notifier for the selected navigation index.
class _NavIndexNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void select(int index) => state = index;
}

final selectedNavIndexProvider =
    NotifierProvider<_NavIndexNotifier, int>(_NavIndexNotifier.new);

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  static const _pages = <Widget>[
    DashBoardPage(),
    WatchtowerPage(),
    GeneratorPage(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = ref.watch(selectedNavIndexProvider);
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leadingWidth: screenWidth * 0.6,
        toolbarHeight: screenHeight * 0.06,
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(width: screenWidth * 0.02),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Image.asset(
                Assets.images.citadelLogo.path,
                height: screenHeight * 0.038,
              ),
            ),
            const SizedBox(width: 8),
            Builder(builder: (context) {
              final title = switch (selectedIndex) {
                1 => 'Watchtower',
                2 => 'Locksmith',
                3 => 'Settings',
                _ => 'Vault',
              };
              return Text(
                title,
                style: TextStyle(
                  fontSize: screenWidth * 0.042,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              );
            }),
          ],
        ),
        centerTitle: false,
        actions: [
          if (selectedIndex == 0)
            Padding(
              padding: EdgeInsets.only(right: screenWidth * 0.03),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: const Color(0xFF1C91F2),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF1C91F2).withAlpha(60),
                      offset: const Offset(0, 3),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: TextButton.icon(
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (_) => const _NewItemBottomSheet(),
                    );
                  },
                  icon: const Icon(Icons.add, color: Colors.white, size: 20),
                  label: const Text(
                    'New',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity:
                        const VisualDensity(horizontal: -1, vertical: -1),
                  ),
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          height: screenHeight * 0.065,
          margin: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.05, vertical: screenHeight * 0.01),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(18),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: BottomNavItem(
                  icon: Bootstrap.shield_lock,
                  label: 'Vault',
                  isSelected: selectedIndex == 0,
                  onTap: () =>
                      ref.read(selectedNavIndexProvider.notifier).select(0),
                ),
              ),
              Expanded(
                child: _WatchtowerNavItem(
                  isSelected: selectedIndex == 1,
                  onTap: () =>
                      ref.read(selectedNavIndexProvider.notifier).select(1),
                ),
              ),
              Expanded(
                child: BottomNavItem(
                  icon: Bootstrap.file_lock,
                  label: 'Locksmith',
                  isSelected: selectedIndex == 2,
                  onTap: () =>
                      ref.read(selectedNavIndexProvider.notifier).select(2),
                ),
              ),
              Expanded(
                child: BottomNavItem(
                  icon: Bootstrap.gear,
                  label: 'Settings',
                  isSelected: selectedIndex == 3,
                  onTap: () =>
                      ref.read(selectedNavIndexProvider.notifier).select(3),
                ),
              ),
            ],
          ),
        ),
      ),
      body: _pages[selectedIndex],
    );
  }

}

/// Bottom sheet with grid of item types for creating new vault items.
class _NewItemBottomSheet extends StatelessWidget {
  const _NewItemBottomSheet();

  static const _itemTypes = <({IconData icon, String label, VaultItemType type})>[
    (icon: Icons.lock_outline, label: 'Password', type: VaultItemType.password),
    (icon: Icons.sticky_note_2_outlined, label: 'Secure Note', type: VaultItemType.secureNote),
    (icon: Icons.account_balance_outlined, label: 'Bank Account', type: VaultItemType.bankAccount),
    (icon: Icons.credit_card_outlined, label: 'Payment Card', type: VaultItemType.paymentCard),
    (icon: Icons.wifi_outlined, label: 'WiFi', type: VaultItemType.wifiPassword),
    (icon: Icons.contact_page_outlined, label: 'Contact', type: VaultItemType.contactInfo),
    (icon: Icons.code_outlined, label: 'Software License', type: VaultItemType.softwareLicense),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          // Handle bar
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFE0E0E0),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Create New Item',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1A2E),
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Choose the type of item to add to your vault',
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF9E9E9E),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 2.4,
              ),
              itemCount: _itemTypes.length,
              itemBuilder: (context, index) {
                final item = _itemTypes[index];
                return _ItemTypeCard(
                  icon: item.icon,
                  label: item.label,
                  onTap: () {
                    Navigator.pop(context);
                    context.push(AppRoutes.vaultItemCreate, extra: item.type);
                  },
                );
              },
            ),
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom + 24),
        ],
      ),
    );
  }
}

/// A single item type card in the new-item bottom sheet grid.
class _ItemTypeCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ItemTypeCard({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFF8FAFC),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE8EDF5)),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFF4D4DCD).withAlpha(20),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 18, color: const Color(0xFF4D4DCD)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A2E),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Watchtower bottom nav item with expiry badge.
class _WatchtowerNavItem extends ConsumerWidget {
  final bool isSelected;
  final VoidCallback onTap;

  const _WatchtowerNavItem({
    required this.isSelected,
    required this.onTap,
  });

  static const _selectedColor = Color(0xFF4D4DCD);
  static const _unselectedColor = Color(0xFF9E9E9E);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final badgeCount = ref.watch(expiryBadgeCountProvider);
    final color = isSelected ? _selectedColor : _unselectedColor;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Center(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          padding: EdgeInsets.symmetric(
            horizontal: isSelected ? 12 : 8,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            color: isSelected ? _selectedColor.withAlpha(20) : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Badge(
                isLabelVisible: badgeCount > 0,
                label: Text(
                  '$badgeCount',
                  style: const TextStyle(fontSize: 9),
                ),
                child: Icon(
                  isSelected ? Icons.shield : Icons.shield_outlined,
                  color: color,
                  size: 20,
                ),
              ),
              if (isSelected) ...[
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    'Watch',
                    style: TextStyle(
                      color: color,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
