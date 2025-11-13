// File: lib/app.dart
// Root app widget using ConsumerStatefulWidget + MaterialApp.router
// Wires session timeout (auto-lock on inactivity) and lifecycle observer.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'core/providers/session_provider.dart';
import 'core/providers/session_timeout_provider.dart';
import 'core/providers/sync_providers.dart';
import 'core/session/session_state.dart';
import 'features/notifications/presentation/providers/startup_notification_provider.dart';
import 'routing/app_router.dart';

class CitadelApp extends ConsumerStatefulWidget {
  const CitadelApp({super.key});

  @override
  ConsumerState<CitadelApp> createState() => _CitadelAppState();
}

class _CitadelAppState extends ConsumerState<CitadelApp> {
  late final AppLifecycleObserver _lifecycleObserver;

  @override
  void initState() {
    super.initState();
    _lifecycleObserver = AppLifecycleObserver(
      ref.read(sessionProvider.notifier),
      lockOnBackground: true,
    );
    WidgetsBinding.instance.addObserver(_lifecycleObserver);

    // Load lock-on-background preference.
    _loadLockOnBackgroundSetting();
  }

  Future<void> _loadLockOnBackgroundSetting() async {
    final lockOnBg = await ref.read(lockOnBackgroundSettingProvider.future);
    _lifecycleObserver.lockOnBackground = lockOnBg;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(_lifecycleObserver);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Eagerly initialize the sync engine so periodic sync starts immediately.
    ref.watch(syncEngineProvider);

    // Trigger breach/expiry/emergency checks on session unlock (D-14, NOTIF-01, NOTIF-03).
    ref.watch(startupNotificationProvider);

    // Initialize session timeout service.
    final timeoutService = ref.watch(sessionTimeoutServiceProvider);

    // Listen to lock-on-background setting changes.
    ref.listen<AsyncValue<bool>>(lockOnBackgroundSettingProvider, (_, next) {
      _lifecycleObserver.lockOnBackground = next.value ?? true;
    });

    // Start/reset the timeout timer when the session is unlocked.
    final session = ref.watch(sessionProvider);
    if (session is Unlocked) {
      timeoutService.resetTimer();
    } else {
      timeoutService.cancel();
    }

    final router = ref.watch(appRouterProvider);

    // Wrap in Listener to detect all pointer events (taps, scrolls, drags)
    // and reset the inactivity timer.
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (_) => timeoutService.resetTimer(),
      onPointerMove: (_) => timeoutService.resetTimer(),
      onPointerSignal: (_) => timeoutService.resetTimer(),
      child: MaterialApp.router(
        routerConfig: router,
        debugShowCheckedModeBanner: false,
        theme: ThemeData.light().copyWith(
          primaryTextTheme: GoogleFonts.poppinsTextTheme(),
          textTheme: GoogleFonts.poppinsTextTheme(),
          primaryColor: const Color(0xff4D4DCD),
        ),
      ),
    );
  }
}
