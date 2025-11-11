import 'package:flutter/material.dart';

import '../../data/models/health_score.dart';
import 'health_score_ring.dart';

/// Premium health-score card with gradient background, animated ring, and
/// status badge.
class ScoreCard extends StatelessWidget {
  const ScoreCard({
    super.key,
    required this.score,
    required this.color,
  });

  final int score;
  final ScoreColor color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scoreLabel = _scoreLabel(score);
    final scoreLabelColor = _scoreLabelColor(score);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0x0D4D4DCD), // 5% primary
            Colors.white,
          ],
        ),
        border: Border.all(
          color:
              theme.colorScheme.outlineVariant.withValues(alpha: 0.18),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4D4DCD).withValues(alpha: 0.06),
            blurRadius: 24,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          HealthScoreRing(
            score: score,
            color: color,
            size: 170,
            strokeWidth: 13,
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: scoreLabelColor.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              scoreLabel,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: scoreLabelColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Color-coded label text for the score badge.
  static String _scoreLabel(int score) {
    if (score >= 80) return 'Excellent';
    if (score >= 50) return 'Good';
    if (score >= 25) return 'Needs Attention';
    return 'Critical';
  }

  /// Color for the score label badge.
  static Color _scoreLabelColor(int score) {
    if (score >= 80) return const Color(0xFF43A047); // success green
    if (score >= 50) return const Color(0xFFFFA726); // warning amber
    return const Color(0xFFE53935); // danger red
  }
}
