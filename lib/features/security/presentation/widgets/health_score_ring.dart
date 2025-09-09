import 'dart:math';

import 'package:flutter/material.dart';

import '../../data/models/health_score.dart';

/// Animated health score ring widget (D-04).
///
/// Reuses the `_GradientRingPainter` pattern from EntropyGauge.
/// Displays a 0-100 score in the center with a proportional ring fill.
/// Color-coded per D-02: green (80-100), yellow (50-79), red (0-49).
class HealthScoreRing extends StatefulWidget {
  const HealthScoreRing({
    super.key,
    required this.score,
    required this.color,
    this.size = 180,
    this.strokeWidth = 14,
  });

  /// Score value 0-100.
  final int score;

  /// Color classification from HealthScore.
  final ScoreColor color;

  /// Widget size (width and height). Default 180.
  final double size;

  /// Ring stroke width.
  final double strokeWidth;

  @override
  State<HealthScoreRing> createState() => _HealthScoreRingState();
}

class _HealthScoreRingState extends State<HealthScoreRing>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0,
      end: widget.score.toDouble(),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));
    _controller.forward();
  }

  @override
  void didUpdateWidget(HealthScoreRing oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.score != widget.score) {
      _animation = Tween<double>(
        begin: _animation.value,
        end: widget.score.toDouble(),
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ));
      _controller
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _scoreColor(ScoreColor c) {
    switch (c) {
      case ScoreColor.green:
        return const Color(0xFF4CAF50);
      case ScoreColor.yellow:
        return Colors.amber.shade700;
      case ScoreColor.red:
        return Colors.redAccent;
    }
  }

  @override
  Widget build(BuildContext context) {
    final ringColor = _scoreColor(widget.color);
    final trackColor =
        Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.10);

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final animatedScore = _animation.value;
        final progress = (animatedScore / 100).clamp(0.0, 1.0);

        return SizedBox(
          width: widget.size,
          height: widget.size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(
                size: Size(widget.size, widget.size),
                painter: _HealthRingPainter(
                  progress: progress,
                  color: ringColor,
                  trackColor: trackColor,
                  strokeWidth: widget.strokeWidth,
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    animatedScore.round().toString(),
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                          fontSize: 42,
                          color: ringColor,
                          height: 1,
                        ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Health Score',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.6),
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Gradient ring painter reusing the pattern from EntropyGauge.
class _HealthRingPainter extends CustomPainter {
  _HealthRingPainter({
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
    final start = _tint(color, -0.20);
    final end = _tint(color, 0.10);
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
  bool shouldRepaint(covariant _HealthRingPainter old) {
    return old.progress != progress ||
        old.color != color ||
        old.trackColor != trackColor ||
        old.strokeWidth != strokeWidth;
  }
}
