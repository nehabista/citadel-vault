import 'package:flutter/material.dart';

/// Horizontal scrollable row of quick-action pill buttons.
class QuickActionsRow extends StatelessWidget {
  const QuickActionsRow({
    super.key,
    required this.onCheckEmail,
    required this.onCheckPassword,
    required this.onExploreBreaches,
  });

  final VoidCallback onCheckEmail;
  final VoidCallback onCheckPassword;
  final VoidCallback onExploreBreaches;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _ActionPill(
            icon: Icons.email_outlined,
            label: 'Check Email',
            onTap: onCheckEmail,
          ),
          const SizedBox(width: 10),
          _ActionPill(
            icon: Icons.password_rounded,
            label: 'Check Password',
            onTap: onCheckPassword,
          ),
          const SizedBox(width: 10),
          _ActionPill(
            icon: Icons.shield_outlined,
            label: 'Explore Breaches',
            onTap: onExploreBreaches,
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Action Pill (iOS-style horizontal chip)
// ---------------------------------------------------------------------------

class _ActionPill extends StatelessWidget {
  const _ActionPill({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  static const _primary = Color(0xFF4D4DCD);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: _primary.withValues(alpha: 0.08),
            border: Border.all(
              color: _primary.withValues(alpha: 0.18),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 17, color: _primary),
              const SizedBox(width: 7),
              Text(
                label,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: _primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
