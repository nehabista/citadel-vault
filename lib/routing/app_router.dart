// File: lib/routing/app_router.dart
// GoRouter configuration with auth-based redirects
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/providers/session_provider.dart';
import '../core/session/session_state.dart';
import '../features/import_export/presentation/pages/export_page.dart';
import '../features/import_export/presentation/pages/import_page.dart';
import '../features/email_alias/presentation/pages/alias_list_page.dart';
import '../features/notifications/presentation/pages/notification_settings_page.dart';
import '../features/security/data/models/breach_record.dart';
import '../features/sharing/presentation/pages/emergency_access_page.dart';
import '../features/sharing/presentation/pages/shared_vaults_page.dart';
import '../features/ssh_keys/presentation/pages/ssh_key_detail_page.dart';
import '../features/ssh_keys/presentation/pages/ssh_key_list_page.dart';
import '../features/travel_mode/presentation/pages/travel_mode_page.dart';
import '../features/security/presentation/pages/breach_catalog_page.dart';
import '../features/security/presentation/pages/breach_detail_page.dart';
import '../features/security/presentation/pages/breach_timeline_page.dart';
import '../features/security/presentation/pages/email_check_page.dart';
import '../features/security/presentation/pages/hibp_settings_page.dart';
import '../features/security/presentation/pages/password_check_page.dart';
import '../features/vault/domain/entities/vault_item.dart';
import '../presentation/pages/auth/auth_page.dart';
import '../presentation/pages/auth/unlock_screen.dart';
import '../presentation/pages/auth/verification_pending_screen.dart';
import '../presentation/pages/home_page.dart';
import '../presentation/pages/onboarding/onbarding_page.dart';
import '../presentation/pages/splash/splash_screen.dart';
import '../presentation/pages/vault_item/vault_item_detail_page.dart';
import '../presentation/pages/vault_item/vault_item_edit_page.dart';

/// Route path constants.
abstract class AppRoutes {
  static const splash = '/splash';
  static const onboarding = '/onboarding';
  static const login = '/login';
  static const signup = '/signup';
  static const unlock = '/unlock';
  static const home = '/home';
  static const dashboard = '/dashboard';
  static const settings = '/settings';
  static const verification = '/verification';
  static const vaultItemDetail = '/vault-item/:id';
  static const vaultItemEdit = '/vault-item/:id/edit';
  static const vaultItemCreate = '/vault-item/create';
  static const importPage = '/import';
  static const exportPage = '/export';
  static const breachCatalog = '/breach-catalog';
  static const breachDetail = '/breach-detail';
  static const breachTimeline = '/breach-timeline';
  static const hibpSettings = '/settings/hibp-api-key';
  static const emergencyAccess = '/emergency-access';
  static const notificationSettings = '/notification-settings';
  static const sharedVaults = '/shared-vaults';
  static const emailAliases = '/email-aliases';
  static const emailCheck = '/email-check';
  static const passwordCheck = '/password-check';
  static const travelMode = '/travel-mode';
  static const sshKeys = '/ssh-keys';

  /// Routes that don't require authentication.
  static const publicRoutes = [splash, onboarding, login, signup, verification, unlock];
}

/// A [ChangeNotifier] that rebuilds the router when session state changes.
class SessionChangeNotifier extends ChangeNotifier {
  SessionChangeNotifier(Ref ref) {
    ref.listen<SessionState>(sessionProvider, (_, __) {
      notifyListeners();
    });
  }
}

/// Provides the GoRouter instance with auth redirect guards.
final appRouterProvider = Provider<GoRouter>((ref) {
  final refreshNotifier = SessionChangeNotifier(ref);

  return GoRouter(
    initialLocation: AppRoutes.splash,
    refreshListenable: refreshNotifier,
    redirect: (context, state) {
      final session = ref.read(sessionProvider);
      final currentPath = state.matchedLocation;

      // If on splash or onboarding, let them through
      if (currentPath == AppRoutes.splash ||
          currentPath == AppRoutes.onboarding) {
        return null;
      }

      return switch (session) {
        // When locked: allow public routes (login, unlock, etc.), redirect others to login
        Locked() => AppRoutes.publicRoutes.contains(currentPath)
            ? null
            : AppRoutes.login,
        // When unlocked: redirect login/unlock to home, allow everything else
        Unlocked() => (currentPath == AppRoutes.login ||
                currentPath == AppRoutes.unlock)
            ? AppRoutes.home
            : null,
      };
    },
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (context, state) => const OnbardingScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const AuthScreen(),
      ),
      GoRoute(
        path: AppRoutes.unlock,
        builder: (context, state) => const UnlockScreen(),
      ),
      GoRoute(
        path: AppRoutes.signup,
        builder: (context, state) => const AuthScreen(),
      ),
      GoRoute(
        path: AppRoutes.verification,
        builder: (context, state) {
          final email = state.extra as String? ?? '';
          return VerificationPendingScreen(email: email);
        },
      ),
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: AppRoutes.importPage,
        builder: (context, state) => const ImportPage(),
      ),
      GoRoute(
        path: AppRoutes.exportPage,
        builder: (context, state) => const ExportPage(),
      ),
      GoRoute(
        path: AppRoutes.vaultItemCreate,
        builder: (context, state) {
          final initialType = state.extra as VaultItemType?;
          return VaultItemEditPage(initialType: initialType);
        },
      ),
      GoRoute(
        path: '/vault-item/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return VaultItemDetailPage(itemId: id);
        },
        routes: [
          GoRoute(
            path: 'edit',
            builder: (context, state) {
              final extra = state.extra as VaultItemEntity?;
              return VaultItemEditPage(existingItem: extra);
            },
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.breachCatalog,
        builder: (context, state) => const BreachCatalogPage(),
      ),
      GoRoute(
        path: AppRoutes.breachDetail,
        builder: (context, state) {
          final breach = state.extra as BreachRecord;
          return BreachDetailPage(breach: breach);
        },
      ),
      GoRoute(
        path: AppRoutes.breachTimeline,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          return BreachTimelinePage(
            item: extra['item'] as VaultItemEntity,
            breaches: extra['breaches'] as List<BreachRecord>,
            passwordChangeDates:
                extra['passwordChangeDates'] as List<DateTime>,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.hibpSettings,
        builder: (context, state) => const HibpSettingsPage(),
      ),
      GoRoute(
        path: AppRoutes.emergencyAccess,
        builder: (context, state) => const EmergencyAccessPage(),
      ),
      GoRoute(
        path: AppRoutes.notificationSettings,
        builder: (context, state) => const NotificationSettingsPage(),
      ),
      GoRoute(
        path: AppRoutes.sharedVaults,
        builder: (context, state) => const SharedVaultsPage(),
      ),
      GoRoute(
        path: AppRoutes.emailAliases,
        builder: (context, state) => const AliasListPage(),
      ),
      GoRoute(
        path: AppRoutes.emailCheck,
        builder: (context, state) => const EmailCheckPage(),
      ),
      GoRoute(
        path: AppRoutes.passwordCheck,
        builder: (context, state) => const PasswordCheckPage(),
      ),
      GoRoute(
        path: AppRoutes.travelMode,
        builder: (context, state) => const TravelModePage(),
      ),
      GoRoute(
        path: AppRoutes.sshKeys,
        builder: (context, state) => const SshKeyListPage(),
        routes: [
          GoRoute(
            path: ':id',
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              final item = state.extra as VaultItemEntity?;
              return SshKeyDetailPage(itemId: id, item: item);
            },
          ),
        ],
      ),
    ],
  );
});
