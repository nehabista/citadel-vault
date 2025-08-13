// File: lib/presentation/pages/home_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:icons_plus/icons_plus.dart';

import '../../gen/assets.gen.dart';
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
    Center(child: Text('Citadel Locksmith')),
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
              final title = selectedIndex == 1
                  ? 'Citadel LocksmithX'
                  : selectedIndex == 2
                      ? 'Citadel Settings'
                      : 'Citadel Vault';
              return Text(
                title,
                style: TextStyle(
                  fontSize: screenWidth * 0.042,
                  fontWeight: FontWeight.w500,
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
                  borderRadius: BorderRadius.circular(6),
                  boxShadow: [
                    BoxShadow(
                      color: const Color.fromARGB(93, 28, 146, 242),
                      offset: const Offset(0, 4),
                      blurRadius: 8,
                    ),
                    const BoxShadow(
                      color: Colors.white,
                      offset: Offset(-1, -1),
                      blurRadius: 1,
                      spreadRadius: -1,
                    ),
                  ],
                ),
                child: TextButton.icon(
                  onPressed: () {
                    debugPrint('+ New button tapped');
                  },
                  icon: const Icon(Icons.add, color: Colors.white, size: 22),
                  label: const Text(
                    'New',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
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
          height: screenHeight * 0.075,
          margin: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.08, vertical: screenHeight * 0.01),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 8.0,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: BottomNavItem(
                  icon: Bootstrap.shield_lock,
                  label: 'Citadel',
                  isSelected: selectedIndex == 0,
                  onTap: () =>
                      ref.read(selectedNavIndexProvider.notifier).select(0),
                ),
              ),
              Expanded(
                child: BottomNavItem(
                  icon: Bootstrap.file_lock,
                  label: 'Locksmith',
                  isSelected: selectedIndex == 1,
                  onTap: () =>
                      ref.read(selectedNavIndexProvider.notifier).select(1),
                ),
              ),
              Expanded(
                child: BottomNavItem(
                  icon: Bootstrap.gear,
                  label: 'Settings',
                  isSelected: selectedIndex == 2,
                  onTap: () =>
                      ref.read(selectedNavIndexProvider.notifier).select(2),
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
