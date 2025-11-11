// File: lib/presentation/widgets/quick_unlock_sheet.dart
import 'package:flutter/material.dart';

/// Quick unlock setup bottom sheet shown after first login.
class QuickUnlockSetupSheet extends StatelessWidget {
  final VoidCallback onSetupPin;
  final VoidCallback onSetupBiometrics;
  final VoidCallback onSkip;

  const QuickUnlockSetupSheet({
    super.key,
    required this.onSetupPin,
    required this.onSetupBiometrics,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          // Handle bar
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFE0E0E0),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),

          // Shield icon
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: const Color(0xFF4D4DCD).withAlpha(20),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.speed_rounded,
              size: 40,
              color: Color(0xFF4D4DCD),
            ),
          ),
          const SizedBox(height: 20),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'Secure Quick Unlock',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w700,
                fontSize: 20,
                color: Color(0xFF1A1A2E),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'Set up PIN or biometrics so you don\'t need to type your master password every time',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                color: Colors.grey.shade500,
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(height: 28),

          // Option: Set up PIN
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: QuickUnlockOption(
              icon: Icons.pin_outlined,
              title: 'Set up PIN',
              subtitle: 'Use a 6-digit PIN for quick access',
              onTap: onSetupPin,
            ),
          ),
          const SizedBox(height: 12),

          // Option: Use Biometrics
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: QuickUnlockOption(
              icon: Icons.fingerprint_rounded,
              title: 'Use Biometrics',
              subtitle: 'Unlock with fingerprint or face',
              onTap: onSetupBiometrics,
            ),
          ),
          const SizedBox(height: 20),

          // Skip
          TextButton(
            onPressed: onSkip,
            child: Text(
              'Skip for now',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade500,
              ),
            ),
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
        ],
      ),
    );
  }
}

/// A single option row in the quick unlock setup sheet.
class QuickUnlockOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const QuickUnlockOption({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFF8FAFC),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE8EDF5)),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFF4D4DCD).withAlpha(20),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 24, color: const Color(0xFF4D4DCD)),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: Color(0xFF1A1A2E),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: Colors.grey.shade400,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
