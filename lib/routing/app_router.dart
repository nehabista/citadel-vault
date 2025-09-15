// File: lib/routing/app_router.dart
// GoRouter configuration with auth-based redirects (D-03)
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/providers/session_provider.dart';
import '../core/session/session_state.dart';
import '../features/auth/presentation/pages/migration_page.dart';
import '../features/import_export/presentation/pages/export_page.dart';
import '../features/import_export/presentation/pages/import_page.dart';
import '../features/security/data/models/breach_record.dart';
import '../features/security/presentation/pages/breach_catalog_page.dart';
import '../features/security/presentation/pages/breach_detail_page.dart';
import '../features/security/presentation/pages/breach_timeline_page.dart';
import '../features/security/presentation/pages/hibp_settings_page.dart';
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
  static const quickUnlockSetup = '/quick-unlock-setup';
  static const migration = '/migration';
  static const vaultItemDetail = '/vault-item/:id';
  static const vaultItemEdit = '/vault-item/:id/edit';
  static const vaultItemCreate = '/vault-item/create';
  static const importPage = '/import';
  static const exportPage = '/export';
  static const breachCatalog = '/breach-catalog';
  static const breachDetail = '/breach-detail';
  static const breachTimeline = '/breach-timeline';
  static const hibpSettings = '/settings/hibp-api-key';

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
      final isPublicRoute = AppRoutes.publicRoutes.contains(currentPath);

      // If on splash or onboarding, let them through
      if (currentPath == AppRoutes.splash ||
          currentPath == AppRoutes.onboarding) {
        return null;
      }

      // Allow migration route through when unlocked
      if (currentPath == AppRoutes.migration) {
        return session is Unlocked ? null : AppRoutes.login;
      }

      return switch (session) {
        Locked() => isPublicRoute ? null : AppRoutes.login,
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
        path: AppRoutes.migration,
        builder: (context, state) {
          final extra = state.extra as Map<String, String>? ?? {};
          return MigrationPage(
            masterPassword: extra['masterPassword'] ?? '',
            salt: extra['salt'] ?? '',
          );
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
    ],
  );
});
