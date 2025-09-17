import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/password_strength.dart';
import '../providers/strength_provider.dart';

/// Premium entropy gauge ring with gradient arc, centered bits display,
/// and strength metrics. Adapted from Protego's design for Citadel's theme.
class EntropyGauge extends ConsumerWidget {
  const EntropyGauge({super.key, this.overrideEntropy, this.size = 140});

  final double? overrideEntropy;
  final double size;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final double bits = overrideEntropy ?? ref.watch(entropyBitsProvider);
    final strength = ref.watch(strengthProvider);
    final pwd = ref.watch(currentPasswordProvider);

    final color = _strengthColor(strength);
    final track = Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.08);

    const maxBitsVisual = 128.0;
    final progress = (bits / maxBitsVisual).clamp(0.0, 1.0);

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Ring
          SizedBox(
            width: size,
            height: size,
            child: CustomPaint(
              painter: _GradientRingPainter(
                progress: progress,
                color: color,
                trackColor: track,
                strokeWidth: 10,
              ),
            ),
          ),
          // Center content
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (pwd.isEmpty)
                Icon(
                  Icons.shield_outlined,
                  size: 28,
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.3),
                )
              else ...[
                Text(
                  bits.toStringAsFixed(0),
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: color,
                    height: 1,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'bits',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.5),
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  static Color _strengthColor(Strength s) {
    switch (s) {
      case Strength.weak:
        return const Color(0xFFE53935);
      case Strength.moderate:
        return const Color(0xFFFFA726);
      case Strength.strong:
        return const Color(0xFF43A047);
    }
  }
}

/// Strength label + crack time widget for use alongside [EntropyGauge].
class StrengthLabel extends ConsumerWidget {
  const StrengthLabel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strength = ref.watch(strengthProvider);
    final crack = ref.watch(crackTimeShortProvider);
    final pwd = ref.watch(currentPasswordProvider);

    final color = _strengthColor(strength);
    final label = _strengthText(strength);

    if (pwd.isEmpty) {
      return Text(
        'Generate a password to see strength',
        style: TextStyle(
          fontSize: 13,
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
        ),
        textAlign: TextAlign.center,
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: color,
              letterSpacing: 0.3,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Crack time: $crack',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.55),
          ),
        ),
      ],
    );
  }

  static Color _strengthColor(Strength s) {
    switch (s) {
      case Strength.weak:
        return const Color(0xFFE53935);
      case Strength.moderate:
        return const Color(0xFFFFA726);
      case Strength.strong:
        return const Color(0xFF43A047);
    }
  }

  static String _strengthText(Strength s) {
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

/// Gradient ring with full-track underlay and sweep-gradient progress arc.
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
    final start = _tint(color, -0.15);
    final end = _tint(color, 0.12);
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
