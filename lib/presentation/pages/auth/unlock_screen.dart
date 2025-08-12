// File: lib/presentation/pages/auth/unlock_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../features/auth/presentation/providers/auth_provider.dart';
import '../../../routing/app_router.dart';

class UnlockScreen extends ConsumerWidget {
  const UnlockScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final notifier = ref.read(authProvider.notifier);

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.lock_outline, size: 60, color: Colors.blue),
              const SizedBox(height: 20),
              const Text(
                'Vault Locked',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              // Biometrics button
              ElevatedButton.icon(
                icon: const Icon(Icons.fingerprint),
                label: const Text('Unlock with Biometrics'),
                onPressed: authState.isLoadingBiometrics
                    ? null
                    : () async {
                        final success = await notifier.unlockWithBiometrics();
                        if (success && context.mounted) {
                          context.go(AppRoutes.home);
                        }
                      },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
              const SizedBox(height: 20),
              // PIN field
              if (authState.showPinAfterBioFailure) ...[
                TextField(
                  controller: notifier.pinController,
                  decoration: const InputDecoration(labelText: 'Enter PIN'),
                  keyboardType: TextInputType.number,
                  obscureText: true,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: authState.isLoadingPin
                      ? null
                      : () async {
                          final success = await notifier.unlockWithPin();
                          if (success && context.mounted) {
                            context.go(AppRoutes.home);
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Unlock'),
                ),
              ],
              const SizedBox(height: 20),
              TextButton(
                onPressed: () {
                  notifier.logout();
                  if (context.mounted) {
                    context.go(AppRoutes.login);
                  }
                },
                child: const Text(
                  'Logout',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
