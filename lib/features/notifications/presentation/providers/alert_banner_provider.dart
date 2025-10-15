// File: lib/features/notifications/presentation/providers/alert_banner_provider.dart
// Alert banner state and notifier for persistent dashboard banners.
// Per D-17: persistent banner at top of dashboard for critical alerts.

import 'package:flutter_riverpod/flutter_riverpod.dart';

// ─── Sealed State ──────────────────────────────────────────────────

/// Sealed class representing the alert banner visibility state.
sealed class AlertBannerState {
  const AlertBannerState();
}

/// Banner is hidden (default state).
class AlertBannerHidden extends AlertBannerState {
  const AlertBannerHidden();
}

/// Banner is visible with a message, action label, and navigation route.
class AlertBannerVisible extends AlertBannerState {
  final String message;
  final String actionLabel;
  final String route;

  const AlertBannerVisible({
    required this.message,
    required this.actionLabel,
    required this.route,
  });
}

// ─── Notifier ──────────────────────────────────────────────────────

/// Manages the alert banner display state.
class AlertBannerNotifier extends Notifier<AlertBannerState> {
  @override
  AlertBannerState build() => const AlertBannerHidden();

  /// Show a persistent alert banner with a message and action.
  void showAlert({
    required String message,
    required String actionLabel,
    required String route,
  }) {
    state = AlertBannerVisible(
      message: message,
      actionLabel: actionLabel,
      route: route,
    );
  }

  /// Dismiss the current banner.
  void dismiss() {
    state = const AlertBannerHidden();
  }
}

// ─── Provider ──────────────────────────────────────────────────────

/// Provider for the alert banner state.
final alertBannerProvider =
    NotifierProvider<AlertBannerNotifier, AlertBannerState>(
  () => AlertBannerNotifier(),
);
