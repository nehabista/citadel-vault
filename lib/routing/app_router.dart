// File: lib/routing/app_router.dart
// GoRouter configuration with auth-based redirects (D-03)
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/providers/session_provider.dart';
import '../core/session/session_state.dart';
import '../presentation/pages/auth/auth_page.dart';
import '../presentation/pages/auth/verification_pending_screen.dart';
import '../presentation/pages/home_page.dart';
import '../presentation/pages/onboarding/onbarding_page.dart';
import '../presentation/pages/splash/splash_screen.dart';

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

  /// Routes that don't require authentication.
  static const publicRoutes = [splash, onboarding, login, signup, verification];
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
    ],
  );
});
