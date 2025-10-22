// File: lib/presentation/pages/home_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:icons_plus/icons_plus.dart';

import '../../core/providers/core_providers.dart';
import '../../features/password_generator/presentation/pages/generator_page.dart';
import '../../features/security/presentation/pages/watchtower_page.dart';
import '../../features/security/presentation/providers/expiry_provider.dart';
import '../../features/vault/domain/entities/vault_item.dart';
import '../../gen/assets.gen.dart';
import '../../routing/app_router.dart';
import '../widgets/bottom_nav_item.dart';
import '../widgets/citadel_snackbar.dart';
import 'dashboard/dashboard_page.dart';
import 'settings/settings_page.dart';
import 'settings/pin_setup_page.dart';

/// Notifier for the selected navigation index.
class _NavIndexNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void select(int index) => state = index;
}

final selectedNavIndexProvider =
    NotifierProvider<_NavIndexNotifier, int>(_NavIndexNotifier.new);

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  static final _pages = <Widget>[
    const DashBoardPage(),
    const WatchtowerPage(),
    const GeneratorPage(),
    const SettingsScreen(),
  ];

  bool _hasShownQuickUnlockDialog = false;

  @override
  void initState() {
    super.initState();
    // Check for quick unlock setup after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkQuickUnlockSetup();
    });
  }

  Future<void> _checkQuickUnlockSetup() async {
    if (_hasShownQuickUnlockDialog) return;
    final localAuth = ref.read(localAuthServiceProvider);
    final hasSetup = await localAuth.hasQuickUnlockSetup();
    if (!hasSetup && mounted) {
      _hasShownQuickUnlockDialog = true;
      _showQuickUnlockSetupSheet();
    }
  }

  void _showQuickUnlockSetupSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _QuickUnlockSetupSheet(
        onSetupPin: () {
          Navigator.of(context).pop();
          _promptMasterPasswordForPin();
        },
        onSetupBiometrics: () {
          Navigator.of(context).pop();
          _promptMasterPasswordForBiometrics();
        },
        onSkip: () => Navigator.of(context).pop(),
      ),
    );
  }

  void _promptMasterPasswordForPin() {
    _promptMasterPassword(
      context: context,
      onSubmit: (masterPassword) async {
        final result = await Navigator.of(context).push<bool>(
          MaterialPageRoute(
            builder: (_) => PinSetupPage(masterPassword: masterPassword),
          ),
        );
        if (result == true && mounted) {
          showCitadelSnackBar(context, 'PIN unlock enabled',
              type: SnackBarType.success);
        }
      },
    );
  }

  void _promptMasterPasswordForBiometrics() {
    _promptMasterPassword(
      context: context,
      onSubmit: (masterPassword) async {
        final localAuth = ref.read(localAuthServiceProvider);
        final success = await localAuth.enableBiometricUnlock(masterPassword);
        if (mounted) {
          showCitadelSnackBar(
            context,
            success ? 'Biometric unlock enabled' : 'Biometric setup failed',
            type: success ? SnackBarType.success : SnackBarType.error,
          );
        }
      },
    );
  }

  void _promptMasterPassword({
    required BuildContext context,
    required Future<void> Function(String masterPassword) onSubmit,
  }) {
    final controller = TextEditingController();
    bool obscure = true;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 24,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE0E0E0),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Enter Master Password',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                      color: Color(0xFF1A1A2E),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Required to set up quick unlock',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 13,
                      color: Colors.grey.shade500,
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: controller,
                    obscureText: obscure,
                    autofocus: true,
                    decoration: InputDecoration(
                      labelText: 'Master Password',
                      labelStyle: const TextStyle(fontFamily: 'Poppins'),
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide:
                            const BorderSide(color: Color(0xFFE8EDF5)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(
                            color: Color(0xFF4D4DCD), width: 2),
                      ),
                      prefixIcon: const Icon(Icons.lock_outline,
                          color: Color(0xFF4D4DCD)),
                      suffixIcon: IconButton(
                        icon: Icon(
                          obscure
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: Colors.grey,
                        ),
                        onPressed: () {
                          setSheetState(() => obscure = !obscure);
                        },
                      ),
                    ),
                    onSubmitted: (_) async {
                      if (controller.text.trim().isEmpty) return;
                      Navigator.of(ctx).pop();
                      await onSubmit(controller.text.trim());
                    },
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (controller.text.trim().isEmpty) return;
                        Navigator.of(ctx).pop();
                        await onSubmit(controller.text.trim());
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4D4DCD),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Continue',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
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

/// Quick unlock setup bottom sheet shown after first login.
class _QuickUnlockSetupSheet extends StatelessWidget {
  final VoidCallback onSetupPin;
  final VoidCallback onSetupBiometrics;
  final VoidCallback onSkip;

  const _QuickUnlockSetupSheet({
    required this.onSetupPin,
    required this.onSetupBiometrics,
    required this.onSkip,
  });

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
          const SizedBox(height: 24),

          // Shield icon
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: const Color(0xFF4D4DCD).withAlpha(20),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.speed_rounded,
              size: 40,
              color: Color(0xFF4D4DCD),
            ),
          ),
          const SizedBox(height: 20),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'Secure Quick Unlock',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w700,
                fontSize: 20,
                color: Color(0xFF1A1A2E),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'Set up PIN or biometrics so you don\'t need to type your master password every time',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                color: Colors.grey.shade500,
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(height: 28),

          // Option: Set up PIN
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: _QuickUnlockOption(
              icon: Icons.pin_outlined,
              title: 'Set up PIN',
              subtitle: 'Use a 6-digit PIN for quick access',
              onTap: onSetupPin,
            ),
          ),
          const SizedBox(height: 12),

          // Option: Use Biometrics
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: _QuickUnlockOption(
              icon: Icons.fingerprint_rounded,
              title: 'Use Biometrics',
              subtitle: 'Unlock with fingerprint or face',
              onTap: onSetupBiometrics,
            ),
          ),
          const SizedBox(height: 20),

          // Skip
          TextButton(
            onPressed: onSkip,
            child: Text(
              'Skip for now',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade500,
              ),
            ),
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
        ],
      ),
    );
  }
}

/// A single option row in the quick unlock setup sheet.
class _QuickUnlockOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _QuickUnlockOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFF8FAFC),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE8EDF5)),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFF4D4DCD).withAlpha(20),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 24, color: const Color(0xFF4D4DCD)),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: Color(0xFF1A1A2E),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: Colors.grey.shade400,
              ),
            ],
          ),
        ),
      ),
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
    final badgeCount = ref.watch(combinedBadgeCountProvider);
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
