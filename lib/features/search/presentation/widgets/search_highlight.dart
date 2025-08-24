// File: lib/features/search/presentation/widgets/search_highlight.dart
// Highlights matching text in search results (D-02)
import 'package:flutter/material.dart';

/// Widget that renders text with matching substring highlighted.
/// Highlighted portions are bold with brand color (#4D4DCD).
class SearchHighlight extends StatelessWidget {
  final String text;
  final String query;
  final TextStyle? baseStyle;

  const SearchHighlight({
    super.key,
    required this.text,
    required this.query,
    this.baseStyle,
  });

  @override
  Widget build(BuildContext context) {
    if (query.isEmpty) {
      return Text(text, style: baseStyle);
    }

    final spans = <TextSpan>[];
    final lowerText = text.toLowerCase();
    final lowerQuery = query.toLowerCase();
    int start = 0;

    while (true) {
      final index = lowerText.indexOf(lowerQuery, start);
      if (index == -1) {
        // Add remaining text
        if (start < text.length) {
          spans.add(TextSpan(text: text.substring(start)));
        }
        break;
      }

      // Add text before match
      if (index > start) {
        spans.add(TextSpan(text: text.substring(start, index)));
      }

      // Add highlighted match
      spans.add(
        TextSpan(
          text: text.substring(index, index + query.length),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF4D4DCD),
          ),
        ),
      );

      start = index + query.length;
    }

    if (spans.isEmpty) {
      return Text(text, style: baseStyle);
    }

    return RichText(
      text: TextSpan(
        style: baseStyle ?? DefaultTextStyle.of(context).style,
        children: spans,
      ),
      overflow: TextOverflow.ellipsis,
    );
  }
}
