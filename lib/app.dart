// File: lib/app.dart
// Root app widget using ConsumerWidget + MaterialApp.router
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'core/providers/sync_providers.dart';
import 'features/notifications/presentation/providers/startup_notification_provider.dart';
import 'routing/app_router.dart';

class CitadelApp extends ConsumerWidget {
  const CitadelApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Eagerly initialize the sync engine so periodic sync starts immediately.
    ref.watch(syncEngineProvider);

    // Trigger breach/expiry/emergency checks on session unlock (D-14, NOTIF-01, NOTIF-03).
    ref.watch(startupNotificationProvider);

    final router = ref.watch(appRouterProvider);
    return MaterialApp.router(
      routerConfig: router,
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light().copyWith(
        primaryTextTheme: GoogleFonts.poppinsTextTheme(),
        textTheme: GoogleFonts.poppinsTextTheme(),
        primaryColor: const Color(0xff4D4DCD),
      ),
    );
  }
}
