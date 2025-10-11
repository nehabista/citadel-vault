// File: lib/features/security/presentation/pages/hibp_settings_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/providers/core_providers.dart';
import '../../../../presentation/widgets/citadel_snackbar.dart';

/// Provider that loads the current HIBP API key from SettingsDao.
final _hibpApiKeyProvider = FutureProvider<String?>((ref) async {
  final db = ref.watch(appDatabaseProvider);
  return db.settingsDao.getSetting('hibp_api_key');
});

/// Page for managing the HIBP API key (D-06).
///
/// Users can enter, view, and delete their Have I Been Pwned API key.
/// Password breach checks (k-anonymity) work without a key,
/// but email breach checks require one.
class HibpSettingsPage extends ConsumerStatefulWidget {
  const HibpSettingsPage({super.key});

  @override
  ConsumerState<HibpSettingsPage> createState() => _HibpSettingsPageState();
}

class _HibpSettingsPageState extends ConsumerState<HibpSettingsPage> {
  final _controller = TextEditingController();
  bool _obscureText = true;
  bool _hasExistingKey = false;
  bool _isSaving = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _saveKey() async {
    final key = _controller.text.trim();
    if (key.isEmpty) return;

    setState(() => _isSaving = true);
    try {
      final db = ref.read(appDatabaseProvider);
      await db.settingsDao.setSetting('hibp_api_key', key);
      ref.invalidate(_hibpApiKeyProvider);
      if (mounted) {
        showCitadelSnackBar(context, 'API key saved',
            type: SnackBarType.success);
        setState(() => _hasExistingKey = true);
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _deleteKey() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete API Key?'),
        content: const Text(
          'Email breach checking will stop working without an API key.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final db = ref.read(appDatabaseProvider);
    await db.settingsDao.deleteSetting('hibp_api_key');
    ref.invalidate(_hibpApiKeyProvider);
    _controller.clear();
    if (mounted) {
      setState(() => _hasExistingKey = false);
      showCitadelSnackBar(context, 'API key deleted',
          type: SnackBarType.error);
    }
  }

  Future<void> _openHibpWebsite() async {
    final uri = Uri.parse('https://haveibeenpwned.com/API/Key');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final asyncKey = ref.watch(_hibpApiKeyProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('HIBP API Key')),
      body: asyncKey.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (existingKey) {
          // Initialize controller once when key loads.
          if (existingKey != null &&
              _controller.text.isEmpty &&
              !_hasExistingKey) {
            _controller.text = existingKey;
            _hasExistingKey = true;
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Icon(Icons.security, size: 48, color: Colors.orange),
              const SizedBox(height: 16),
              const Text(
                'Have I Been Pwned API Key',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              const Text(
                'An API key is required for email breach checking. '
                'Password breach checks work without a key.\n\n'
                'Get a free key at haveibeenpwned.com/API/Key',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: _openHibpWebsite,
                icon: const Icon(Icons.open_in_new),
                label: const Text('Get API Key'),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _controller,
                obscureText: _obscureText,
                decoration: InputDecoration(
                  labelText: 'API Key',
                  hintText: 'Enter your HIBP API key',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureText ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () =>
                        setState(() => _obscureText = !_obscureText),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: _isSaving ? null : _saveKey,
                icon: _isSaving
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save),
                label: Text(_isSaving ? 'Saving...' : 'Save API Key'),
              ),
              if (_hasExistingKey) ...[
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: _deleteKey,
                  icon: const Icon(Icons.delete, color: Colors.red),
                  label: const Text(
                    'Delete API Key',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}
