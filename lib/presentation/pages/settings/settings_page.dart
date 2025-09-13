// File: lib/presentation/pages/settings/settings_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../features/auth/presentation/providers/auth_provider.dart';
import '../../../routing/app_router.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Security',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 10),
          SwitchListTile(
            title: const Text('Unlock with Biometrics'),
            value: false, // TODO: Wire to localAuthService provider
            onChanged: (bool value) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content:
                        Text('Biometric settings will be available soon')),
              );
            },
          ),
          SwitchListTile(
            title: const Text('Unlock with PIN'),
            value: false, // TODO: Wire to localAuthService provider
            onChanged: (bool value) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('PIN settings will be available soon')),
              );
            },
          ),
          const SizedBox(height: 20),
          const Text(
            'Data',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 10),
          ListTile(
            title: const Text('Import'),
            subtitle: const Text('Import credentials from CSV'),
            leading: const Icon(Icons.upload_file),
            onTap: () => context.push(AppRoutes.importPage),
          ),
          ListTile(
            title: const Text('Export'),
            subtitle: const Text('Export vault as CSV or encrypted backup'),
            leading: const Icon(Icons.download),
            onTap: () => context.push(AppRoutes.exportPage),
          ),
          const SizedBox(height: 20),
          const Text(
            'Account',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 10),
          ListTile(
            title: const Text('Logout',
                style: TextStyle(color: Colors.red)),
            leading: const Icon(Icons.logout, color: Colors.red),
            onTap: () {
              ref.read(authProvider.notifier).logout();
              if (context.mounted) {
                context.go(AppRoutes.login);
              }
            },
          ),
        ],
      ),
    );
  }
}
