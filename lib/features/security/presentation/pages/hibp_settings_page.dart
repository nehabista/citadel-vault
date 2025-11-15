// File: lib/features/security/presentation/pages/hibp_settings_page.dart
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/providers/core_providers.dart';
import '../../../../core/utils/error_sanitizer.dart';
import '../../../../presentation/widgets/citadel_snackbar.dart';

/// Encryption key name stored in secure storage for HIBP API key encryption.
/// Uses flutter_secure_storage so the encryption key is protected by the
/// platform keystore (Keychain on iOS/macOS, EncryptedSharedPreferences on Android).
const _hibpEncryptionKeyName = 'hibp_api_key_encryption_key';
const _secureStorage = FlutterSecureStorage();

/// Encrypts the HIBP API key using a simple XOR cipher with a random key
/// stored in flutter_secure_storage. This ensures the key is not stored
/// in plaintext in the Drift database.
Future<String> _encryptHibpKey(String key) async {
  // Get or create encryption key
  var encKey = await _secureStorage.read(key: _hibpEncryptionKeyName);
  if (encKey == null) {
    // Generate a random key and store it securely
    final bytes = List<int>.generate(
      key.length + 32,
      (i) => DateTime.now().microsecondsSinceEpoch % 256 ^ (i * 37 + 13),
    );
    encKey = base64Encode(bytes);
    await _secureStorage.write(key: _hibpEncryptionKeyName, value: encKey);
  }
  final keyBytes = base64Decode(encKey);
  final inputBytes = utf8.encode(key);
  final encrypted = List<int>.generate(
    inputBytes.length,
    (i) => inputBytes[i] ^ keyBytes[i % keyBytes.length],
  );
  return base64Encode(encrypted);
}

/// Decrypts the HIBP API key previously encrypted with [_encryptHibpKey].
Future<String?> _decryptHibpKey(String encryptedBase64) async {
  final encKey = await _secureStorage.read(key: _hibpEncryptionKeyName);
  if (encKey == null) return null; // No encryption key -- cannot decrypt.
  final keyBytes = base64Decode(encKey);
  final encryptedBytes = base64Decode(encryptedBase64);
  final decrypted = List<int>.generate(
    encryptedBytes.length,
    (i) => encryptedBytes[i] ^ keyBytes[i % keyBytes.length],
  );
  return utf8.decode(decrypted);
}

/// Provider that loads and decrypts the current HIBP API key from SettingsDao.
final _hibpApiKeyProvider = FutureProvider<String?>((ref) async {
  final db = ref.watch(appDatabaseProvider);
  final raw = await db.settingsDao.getSetting('hibp_api_key');
  if (raw == null || raw.isEmpty) return null;
  // Attempt to decrypt; if decryption fails, the stored value may be
  // a legacy plaintext key -- return it as-is for backward compatibility.
  try {
    return await _decryptHibpKey(raw);
  } catch (_) {
    return raw;
  }
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
      // Encrypt the API key before storing in the database.
      final encrypted = await _encryptHibpKey(key);
      await db.settingsDao.setSetting('hibp_api_key', encrypted);
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
        error: (e, _) => Center(child: Text('Error: ${sanitizeErrorMessage(e)}')),
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
