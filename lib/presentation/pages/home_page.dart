// P2: Fixed app bar sizing for macOS title bar
// File: lib/presentation/pages/home_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:icons_plus/icons_plus.dart';

import '../../core/providers/core_providers.dart';
import '../../features/password_generator/presentation/pages/generator_page.dart';
import '../../features/security/presentation/pages/watchtower_page.dart';
import '../../gen/assets.gen.dart';
import '../widgets/bottom_nav_item.dart';
import '../widgets/citadel_info_dialog.dart';
import '../widgets/citadel_snackbar.dart';
import '../widgets/master_password_prompt.dart';
import '../widgets/new_item_sheet.dart';
import '../widgets/quick_unlock_sheet.dart';
import '../widgets/watchtower_nav_item.dart';
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
      builder: (_) => QuickUnlockSetupSheet(
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
    showMasterPasswordPrompt(
      context: context,
      subtitle: 'Required to set up quick unlock',
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
    showMasterPasswordPrompt(
      context: context,
      subtitle: 'Required to set up quick unlock',
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

  void _showInfoForTab(int index, BuildContext context) {
    switch (index) {
      case 0:
        showCitadelInfoDialog(
          context,
          icon: Icons.lock_rounded,
          iconColor: const Color(0xFF4D4DCD),
          title: 'About Citadel',
          sections: const [
            InfoSection(
              icon: Icons.enhanced_encryption_rounded,
              title: 'Zero-Knowledge Encryption',
              description:
                  'Your vault is encrypted with AES-256-GCM using a key derived from your master password via Argon2id. We never see your data.',
            ),
            InfoSection(
              icon: Icons.sync_lock_rounded,
              title: 'End-to-End Encrypted Sync',
              description:
                  'All data is encrypted on your device before syncing. The server only stores encrypted blobs.',
            ),
            InfoSection(
              icon: Icons.shield_outlined,
              title: 'Breach Protection',
              description:
                  'Passwords are automatically checked against known breaches. Look for the red shield icon on compromised items.',
            ),
            InfoSection(
              icon: Icons.security_rounded,
              title: 'TOTP Authenticator',
              description:
                  'Store TOTP secrets alongside your logins for one-tap 2FA code access.',
            ),
          ],
        );
      case 1:
        showCitadelInfoDialog(
          context,
          icon: Icons.shield_rounded,
          iconColor: const Color(0xFF4D4DCD),
          title: 'About Watchtower',
          sections: const [
            InfoSection(
              icon: Icons.speed_rounded,
              title: 'Health Score',
              description:
                  'Your vault health score (0-100) measures overall password security \u2014 considering weak, reused, old, and breached passwords.',
            ),
            InfoSection(
              icon: Icons.security_rounded,
              title: 'Breach Monitoring',
              description:
                  'Passwords are checked against Have I Been Pwned\u2019s 14+ billion compromised credentials using k-anonymity. Your passwords are never sent.',
            ),
            InfoSection(
              icon: Icons.analytics_rounded,
              title: 'Password Analysis',
              description:
                  'Weak passwords have low entropy. Reused passwords put multiple accounts at risk. Passwords older than 90 days should be rotated.',
            ),
            InfoSection(
              icon: Icons.bolt_rounded,
              title: 'Quick Actions',
              description:
                  'Check individual emails and passwords against breach databases. Explore the full breach catalog.',
            ),
          ],
        );
      case 2:
        showCitadelInfoDialog(
          context,
          icon: Icons.auto_awesome_rounded,
          iconColor: const Color(0xFF4D4DCD),
          title: 'About Locksmith',
          sections: const [
            InfoSection(
              icon: Icons.bar_chart_rounded,
              title: 'Entropy',
              description:
                  'Measures password randomness in bits. 80+ bits is strong. Uses cryptographic randomness (SecureRandom).',
            ),
            InfoSection(
              icon: Icons.timer_rounded,
              title: 'Crack Time',
              description:
                  'Estimated brute-force time from a single PC to a nation-state supercomputer cluster.',
            ),
            InfoSection(
              icon: Icons.text_snippet_rounded,
              title: 'Passphrase Mode',
              description:
                  'Generates memorable multi-word passphrases. Easier to type while maintaining high entropy.',
            ),
            InfoSection(
              icon: Icons.tune_rounded,
              title: 'Character Types',
              description:
                  'Mix uppercase, lowercase, digits, and symbols for maximum entropy per character.',
            ),
          ],
        );
      default:
        break; // No info dialog for Settings tab
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = ref.watch(selectedNavIndexProvider);
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
                2 => 'Keys',
                3 => 'More',
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
          if (selectedIndex != 3) // Info button for Vault, Watchtower, Locksmith tabs
            IconButton(
              icon: const Icon(Icons.info_outline_rounded,
                  color: Color(0xFF4D4DCD), size: 22),
              tooltip: switch (selectedIndex) {
                1 => 'About Watchtower',
                2 => 'About Locksmith',
                _ => 'About Citadel',
              },
              onPressed: () => _showInfoForTab(selectedIndex, context),
            ),
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
                      builder: (_) => const NewItemBottomSheet(),
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
                child: WatchtowerNavItem(
                  isSelected: selectedIndex == 1,
                  onTap: () =>
                      ref.read(selectedNavIndexProvider.notifier).select(1),
                ),
              ),
              Expanded(
                child: BottomNavItem(
                  icon: Bootstrap.file_lock,
                  label: 'Keys',
                  isSelected: selectedIndex == 2,
                  onTap: () =>
                      ref.read(selectedNavIndexProvider.notifier).select(2),
                ),
              ),
              Expanded(
                child: BottomNavItem(
                  icon: Bootstrap.gear,
                  label: 'More',
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
// P2: Dark mode color consistency fix
