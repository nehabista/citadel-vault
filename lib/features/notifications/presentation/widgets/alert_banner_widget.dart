// File: lib/features/notifications/presentation/widgets/alert_banner_widget.dart
// Persistent dismissible alert banner for the dashboard.
// Per D-17: persistent banner at top of dashboard for critical alerts.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/alert_banner_provider.dart';

/// A persistent, dismissible alert banner displayed at the top of the dashboard.
///
/// Watches [alertBannerProvider] and renders a styled banner when visible,
/// or [SizedBox.shrink] when hidden. Includes a message, action button
/// for navigation, and a close button to dismiss.
class AlertBannerWidget extends ConsumerWidget {
  const AlertBannerWidget({super.key});

  static const _primaryColor = Color(0xFF4D4DCD);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bannerState = ref.watch(alertBannerProvider);

    return switch (bannerState) {
      AlertBannerHidden() => const SizedBox.shrink(),
      AlertBannerVisible(:final message, :final actionLabel, :final route) =>
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Container(
            decoration: BoxDecoration(
              color: _primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
              border: const Border(
                left: BorderSide(color: _primaryColor, width: 4),
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                const Icon(
                  Icons.warning_amber_rounded,
                  color: _primaryColor,
                  size: 22,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    message,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 13,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => context.go(route),
                  style: TextButton.styleFrom(
                    foregroundColor: _primaryColor,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    textStyle: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  child: Text(actionLabel),
                ),
                IconButton(
                  onPressed: () =>
                      ref.read(alertBannerProvider.notifier).dismiss(),
                  icon: const Icon(Icons.close, size: 18),
                  color: Colors.white70,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 32,
                    minHeight: 32,
                  ),
                ),
              ],
            ),
          ),
        ),
    };
  }
}
