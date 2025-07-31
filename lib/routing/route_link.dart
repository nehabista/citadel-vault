// ignore_for_file: constant_identifier_names

import 'package:citadel_password_manager/logic/bindings/initial_bindings.dart';
import 'package:citadel_password_manager/presentation/pages/auth/auth_page.dart';
import 'package:citadel_password_manager/presentation/pages/auth/setup_quick_auth.dart';
import 'package:citadel_password_manager/presentation/pages/auth/unlock_screen.dart';
import 'package:citadel_password_manager/presentation/pages/home_page.dart';
import 'package:citadel_password_manager/presentation/pages/onboarding/onbarding_page.dart';
import 'package:citadel_password_manager/presentation/pages/settings/settings_page.dart';
import 'package:citadel_password_manager/presentation/pages/splash/splash_screen.dart';
import 'package:citadel_password_manager/routing/route_names.dart';
import 'package:get/get.dart';

import '../presentation/pages/dashboard/dashboard_page.dart';

class AppPages {
  static const INITIAL = AppRoutes.SPLASH;

  static final routes = [
    GetPage(
      name: AppRoutes.ONBOARDING,
      page: () => const OnbardingScreen(),
      binding: InitialBindings(),
      transition: Transition.rightToLeftWithFade,
      transitionDuration: const Duration(milliseconds: 500),
    ),
    GetPage(
      name: AppRoutes.SPLASH,
      page: () => const SplashScreen(),
      binding: InitialBindings(),
    ),
    GetPage(
      name: AppRoutes.AUTH,
      page: () => AuthScreen(),
      binding: InitialBindings(),
    ),
    GetPage(
      name: AppRoutes.QUICK_UNLOCK_SETUP,
      page: () => SetupQuickUnlockScreen(),
    ),
    GetPage(
      name: AppRoutes.HOME,
      page: () => HomePage(),
      binding: InitialBindings(),
    ),

    GetPage(
      name: AppRoutes.UNLOCK,
      page: () => UnlockScreen(),
      binding: InitialBindings(),
    ),
    GetPage(
      name: AppRoutes.DASHBOARD,
      page: () => const DashBoardPage(),
      binding: InitialBindings(),
    ),
    GetPage(
      name: AppRoutes.SETTINGS,
      page: () => SettingsScreen(),
      binding: InitialBindings(),
    ),
  ];
}
