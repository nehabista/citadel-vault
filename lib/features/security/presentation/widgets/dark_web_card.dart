import 'package:flutter/material.dart';

import '../../data/models/health_score.dart';

/// Dark Web Monitoring feature card with stats and action buttons.
class DarkWebMonitoringCard extends StatelessWidget {
  const DarkWebMonitoringCard({
    super.key,
    required this.healthScore,
    required this.onCheckEmail,
    required this.onFullReport,
  });

  final HealthScore healthScore;
  final VoidCallback onCheckEmail;
  final VoidCallback onFullReport;

  @override
  Widget build(BuildContext context) {
    final passwordsChecked = healthScore.totalItemCount;
    final breachedCount = healthScore.breachedItems.length;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1A1A2E),
            Color(0xFF2D2D5E),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4D4DCD).withValues(alpha: 0.25),
            blurRadius: 24,
            offset: const Offset(0, 8),
            spreadRadius: -4,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon + Title row
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.policy_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Dark Web Monitoring',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Monitor your credentials on the dark web',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: Colors.white.withValues(alpha: 0.65),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Description
            Text(
              'We scan breach databases and dark web marketplaces for your '
              'compromised credentials using the Have I Been Pwned service.',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12.5,
                fontWeight: FontWeight.w400,
                color: Colors.white.withValues(alpha: 0.75),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 18),

            // Stats row
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.07),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  // Passwords checked
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          '$passwordsChecked',
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'checked',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: Colors.white.withValues(alpha: 0.55),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Divider
                  Container(
                    width: 1,
                    height: 32,
                    color: Colors.white.withValues(alpha: 0.15),
                  ),
                  // Breached
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          '$breachedCount',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: breachedCount > 0
                                ? const Color(0xFFFF6B6B)
                                : Colors.white,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'breached',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: Colors.white.withValues(alpha: 0.55),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Divider
                  Container(
                    width: 1,
                    height: 32,
                    color: Colors.white.withValues(alpha: 0.15),
                  ),
                  // Last scan
                  Expanded(
                    child: Column(
                      children: const [
                        Text(
                          'Just now',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'last scan',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: Color(0x8CFFFFFF),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // Action buttons
            Row(
              children: [
                // Check Email — filled white button
                Expanded(
                  child: SizedBox(
                    height: 42,
                    child: FilledButton(
                      onPressed: onCheckEmail,
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF1A1A2E),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: EdgeInsets.zero,
                        textStyle: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      child: const Text('Check Email'),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                // Full Report — outlined white button
                Expanded(
                  child: SizedBox(
                    height: 42,
                    child: OutlinedButton(
                      onPressed: onFullReport,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: BorderSide(
                          color: Colors.white.withValues(alpha: 0.4),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: EdgeInsets.zero,
                        textStyle: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      child: const Text('Full Report'),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Monitoring Summary Card
// ---------------------------------------------------------------------------

/// Summary card showing email monitoring, password monitoring, and breach
/// alert status rows.
class MonitoringSummaryCard extends StatelessWidget {
  const MonitoringSummaryCard({
    super.key,
    required this.healthScore,
  });

  final HealthScore healthScore;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final passwordsChecked = healthScore.totalItemCount;
    final breachedCount = healthScore.breachedItems.length;
    final hasRunBreachCheck =
        healthScore.breachedItems.isNotEmpty || healthScore.totalItemCount > 0;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.18),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 0),
            child: Text(
              'Monitoring Summary',
              style: theme.textTheme.titleSmall?.copyWith(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Email Monitoring
          _MonitoringRow(
            icon: Icons.email_outlined,
            iconColor: const Color(0xFF4D4DCD),
            label: 'Email Monitoring',
            trailing: _StatusBadge(
              label: hasRunBreachCheck ? 'Active' : 'Inactive',
              isActive: hasRunBreachCheck,
            ),
          ),
          Divider(
            height: 1,
            indent: 54,
            endIndent: 18,
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.15),
          ),

          // Password Monitoring
          _MonitoringRow(
            icon: Icons.password_rounded,
            iconColor: const Color(0xFF43A047),
            label: 'Password Monitoring',
            trailing: Text(
              '$passwordsChecked checked',
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF43A047),
              ),
            ),
          ),
          Divider(
            height: 1,
            indent: 54,
            endIndent: 18,
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.15),
          ),

          // Breach Alerts
          _MonitoringRow(
            icon: Icons.notifications_outlined,
            iconColor: breachedCount > 0
                ? const Color(0xFFE53935)
                : const Color(0xFFFFA726),
            label: 'Breach Alerts',
            trailing: breachedCount > 0
                ? Text(
                    '$breachedCount found',
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFE53935),
                    ),
                  )
                : const Text(
                    'All clear',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF43A047),
                    ),
                  ),
          ),
          const SizedBox(height: 6),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Monitoring Row (used inside MonitoringSummaryCard)
// ---------------------------------------------------------------------------

class _MonitoringRow extends StatelessWidget {
  const _MonitoringRow({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.trailing,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final Widget trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 18, color: iconColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 13.5,
                fontWeight: FontWeight.w500,
                color: Color(0xFF2D2D2D),
              ),
            ),
          ),
          trailing,
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Status Badge (Active / Inactive)
// ---------------------------------------------------------------------------

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({
    required this.label,
    required this.isActive,
  });

  final String label;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final color =
        isActive ? const Color(0xFF43A047) : const Color(0xFF9E9E9E);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
