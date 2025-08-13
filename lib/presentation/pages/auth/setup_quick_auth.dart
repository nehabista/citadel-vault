// File: lib/presentation/pages/auth/setup_quick_auth.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SetupQuickUnlockScreen extends ConsumerWidget {
  const SetupQuickUnlockScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(
                Icons.shield_moon_outlined,
                size: 60,
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(height: 20),
              const Text(
                'Set Up Quick Unlock',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 15),
              const Text(
                'For faster, secure access to your vault, please choose a quick unlock method. This is a mandatory one-time setup.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              ElevatedButton.icon(
                icon: const Icon(Icons.fingerprint),
                label: const Text('Enable Biometric Unlock'),
                onPressed: () {
                  // TODO: Implement biometric setup via LocalAuthService provider
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Biometric setup coming soon')),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                icon: const Icon(Icons.pin_outlined),
                label: const Text('Set a 6-Digit PIN'),
                onPressed: () {
                  // TODO: Implement PIN setup
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('PIN setup coming soon')),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey.shade200,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
