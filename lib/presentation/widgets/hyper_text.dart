import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

/// Animated text widget that scrambles characters before resolving to the
/// final text — creates a "hacker/matrix" decryption effect.
///
/// Supports per-character coloring via [charColorFn] for password display.
class HyperText extends StatefulWidget {
  const HyperText({
    super.key,
    required this.text,
    this.duration = const Duration(milliseconds: 800),
    this.style,
    this.animationTrigger = false,
    this.animateOnLoad = true,
    this.charColorFn,
  });

  final bool animateOnLoad;
  final bool animationTrigger;
  final Duration duration;
  final TextStyle? style;
  final String text;

  /// Optional function to color each resolved character by its type.
  /// Called with the final character — return a color for it.
  final Color Function(String char)? charColorFn;

  @override
  State<HyperText> createState() => _HyperTextState();
}

class _HyperTextState extends State<HyperText> {
  int _animationCount = 0;
  late List<String> _displayText;
  late List<bool> _resolved; // tracks which chars have resolved
  bool _isFirstRender = true;
  double _iterations = 0;

  final Random _random = Random();
  Timer? _timer;

  // Character pools for scramble effect
  static const _scrambleChars =
      'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!@#\$%^&*';

  @override
  void initState() {
    super.initState();
    _displayText = widget.text.split('');
    _resolved = List.filled(widget.text.length, !widget.animateOnLoad);
    if (widget.animateOnLoad) {
      _startAnimation();
    }
  }

  @override
  void didUpdateWidget(HyperText oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Re-animate when text changes or trigger flips
    if (widget.text != oldWidget.text && widget.text.isNotEmpty) {
      _displayText = widget.text.split('');
      _resolved = List.filled(widget.text.length, false);
      _startAnimation();
    } else if (widget.animationTrigger != oldWidget.animationTrigger &&
        widget.animationTrigger) {
      _startAnimation();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startAnimation() {
    _iterations = 0;
    _timer?.cancel();
    _animationCount++;
    final currentCount = _animationCount;

    final textLen = widget.text.length;
    if (textLen == 0) return;

    // Tick interval — enough ticks for smooth scramble
    final tickMs = (widget.duration.inMilliseconds / (textLen * 10)).clamp(2, 20);

    _timer = Timer.periodic(
      Duration(milliseconds: tickMs.toInt()),
      (timer) {
        if (!widget.animateOnLoad && _isFirstRender) {
          timer.cancel();
          _isFirstRender = false;
          return;
        }
        if (_iterations < textLen && currentCount == _animationCount) {
          setState(() {
            _displayText = List.generate(textLen, (i) {
              if (widget.text[i] == ' ') return ' ';
              if (i <= _iterations) {
                _resolved[i] = true;
                return widget.text[i];
              }
              // Scramble: random char from pool
              return _scrambleChars[_random.nextInt(_scrambleChars.length)];
            });
          });
          _iterations += 0.1;
        } else {
          timer.cancel();
          if (currentCount == _animationCount) {
            setState(() {
              _displayText = widget.text.split('');
              _resolved = List.filled(textLen, true);
            });
          }
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final baseStyle = widget.style ?? Theme.of(context).textTheme.titleLarge;
    final colorFn = widget.charColorFn;

    return Wrap(
      alignment: WrapAlignment.center,
      children: List.generate(_displayText.length, (index) {
        final char = _displayText[index];
        final isResolved = index < _resolved.length && _resolved[index];

        // Color: use charColorFn for ALL chars (scrambled ones get colored too
        // for a vibrant scramble effect). Scrambled chars are slightly transparent.
        Color charColor;
        if (colorFn != null) {
          charColor = colorFn(char);
          if (!isResolved) {
            charColor = charColor.withAlpha(150); // slightly faded while scrambling
          }
        } else {
          charColor = baseStyle?.color ?? const Color(0xFF1A1A2E);
          if (!isResolved) {
            charColor = charColor.withAlpha(150);
          }
        }

        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 50),
          child: Text(
            char,
            key: ValueKey<String>('$_animationCount-$index'),
            style: (baseStyle ?? const TextStyle()).copyWith(
              color: charColor,
            ),
          ),
        );
      }),
    );
  }
}
