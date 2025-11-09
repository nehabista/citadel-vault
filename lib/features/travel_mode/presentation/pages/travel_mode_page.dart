// File: lib/features/travel_mode/presentation/pages/travel_mode_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Travel Mode settings page.
///
/// Allows users to hide selected vaults when crossing borders.
/// When Travel Mode is active, hidden vaults are removed from local storage
/// and can only be restored after disabling Travel Mode and re-syncing.
class TravelModePage extends ConsumerWidget {
  const TravelModePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          'Travel Mode',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            fontSize: 18,
            color: Color(0xFF1A1A2E),
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Icon
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.orange.withAlpha(25),
                borderRadius: BorderRadius.circular(22),
              ),
              child: const Icon(
                Icons.flight_rounded,
                size: 44,
                color: Colors.orange,
              ),
            ),
            const SizedBox(height: 24),

            const Text(
              'Travel Mode',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w700,
                fontSize: 22,
                color: Color(0xFF1A1A2E),
              ),
            ),
            const SizedBox(height: 12),

            Text(
              'When enabled, selected vaults are hidden from your device. '
              'This protects sensitive data when crossing borders or in '
              'situations where your device may be inspected.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                color: Colors.grey.shade600,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),

            // Placeholder — feature implementation pending
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE8EDF5)),
              ),
              child: Row(
                children: [
                  Icon(Icons.construction_rounded,
                      color: Colors.grey.shade400, size: 24),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      'Travel Mode configuration is coming soon.',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
