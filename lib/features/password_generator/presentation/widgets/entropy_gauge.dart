import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/password_strength.dart';
import '../providers/strength_provider.dart';

/// Gradient ring gauge widget that visualises password strength.
///
/// Uses [entropyBitsProvider], [crackTimeShortProvider], and
/// [strengthProvider] from Riverpod to derive its display.
///
/// Pass [overrideEntropy] for standalone/preview usage outside the
/// provider graph.
class EntropyGauge extends ConsumerWidget {
  const EntropyGauge({super.key, this.overrideEntropy});

  /// If set, bypasses the provider and uses this value directly.
  final double? overrideEntropy;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final double bits = overrideEntropy ?? ref.watch(entropyBitsProvider);
    final strength = ref.watch(strengthProvider);
    final crack = ref.watch(crackTimeShortProvider);
    final pwd = ref.watch(currentPasswordProvider);

    final color = _strengthColor(strength);
    final track = Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.12);

    // Visual normalisation: 0..1 capped at 128 bits.
    const maxBitsVisual = 128.0;
    final progress = (bits / maxBitsVisual).clamp(0.0, 1.0);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Gauge ring
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: SizedBox(
              width: 96,
              height: 96,
              child: CustomPaint(
                painter: _GradientRingPainter(
                  progress: progress,
                  color: color,
                  trackColor: track,
                  strokeWidth: 11,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),

          // Text block
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Strength',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 4),
                Text(
                  _strengthLabel(strength),
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.2,
                        color: color,
                      ),
                ),
                const SizedBox(height: 8),
                if (pwd.isEmpty)
                  Text(
                    'Type a password or tap Generate to see strength analysis.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          height: 1.25,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.75),
                        ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  )
                else ...[
                  _metricLine(
                    context,
                    'Entropy',
                    '${bits.toStringAsFixed(1)} bits',
                  ),
                  const SizedBox(height: 4),
                  _metricLine(context, 'Estimated crack time', crack),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget _metricLine(
    BuildContext context,
    String label,
    String value,
  ) {
    return RichText(
      text: TextSpan(
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.25),
        children: [
          TextSpan(
            text: '$label: ',
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          TextSpan(text: value),
        ],
      ),
    );
  }

  static Color _strengthColor(Strength s) {
    switch (s) {
      case Strength.weak:
        return Colors.redAccent;
      case Strength.moderate:
        return Colors.amber.shade700;
      case Strength.strong:
        return Colors.green.shade600;
    }
  }

  static String _strengthLabel(Strength s) {
    switch (s) {
      case Strength.weak:
        return 'Weak';
      case Strength.moderate:
        return 'Moderate';
      case Strength.strong:
        return 'Strong';
    }
  }
}

/// Gradient ring with a full-track underlay and a sweep-gradient progress arc.
class _GradientRingPainter extends CustomPainter {
  _GradientRingPainter({
    required this.progress,
    required this.color,
    required this.trackColor,
    required this.strokeWidth,
  });

  final double progress;
  final Color color;
  final Color trackColor;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final side = min(size.width, size.height);
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (side - strokeWidth) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    // Background track
    final track = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = strokeWidth
      ..color = trackColor;
    canvas.drawArc(rect, 0, 2 * pi, false, track);

    if (progress <= 0) return;

    // Gradient progress ring
    final start = _tint(color, -0.25);
    final end = _tint(color, 0.08);
    final shader = SweepGradient(
      startAngle: -pi / 2,
      endAngle: 3 * pi / 2,
      colors: [start, end],
      stops: const [0.0, 1.0],
      tileMode: TileMode.clamp,
      transform: const GradientRotation(0),
    ).createShader(rect);

    final active = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = strokeWidth
      ..shader = shader;

    canvas.drawArc(rect, -pi / 2, progress * 2 * pi, false, active);
  }

  static Color _tint(Color c, double amount) {
    final hsl = HSLColor.fromColor(c);
    final light = (hsl.lightness + amount).clamp(0.0, 1.0).toDouble();
    return hsl.withLightness(light).toColor();
  }

  @override
  bool shouldRepaint(covariant _GradientRingPainter old) {
    return old.progress != progress ||
        old.color != color ||
        old.trackColor != trackColor ||
        old.strokeWidth != strokeWidth;
  }
}
