import 'package:flutter/material.dart';

enum SnackBarType { success, error, info }

void showCitadelSnackBar(
  BuildContext context,
  String message, {
  SnackBarType type = SnackBarType.info,
}) {
  final (Color bg, IconData icon) = switch (type) {
    SnackBarType.success => (const Color(0xFF43A047), Icons.check_circle_outline),
    SnackBarType.error => (const Color(0xFFE53935), Icons.error_outline),
    SnackBarType.info => (const Color(0xFF4D4DCD), Icons.info_outline),
  };

  ScaffoldMessenger.of(context).clearSnackBars();
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          Icon(icon, color: Colors.white, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(message, style: const TextStyle(fontFamily: 'Poppins')),
          ),
        ],
      ),
      backgroundColor: bg,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      duration: const Duration(seconds: 2),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    ),
  );
}
