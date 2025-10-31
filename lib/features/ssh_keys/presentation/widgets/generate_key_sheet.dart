// File: lib/features/ssh_keys/presentation/widgets/generate_key_sheet.dart
// Bottom sheet for SSH key generation with type selector, name, comment, passphrase.
// Per D-15: Ed25519 (recommended) and RSA 4096 options.
// RSA shows progress indicator during generation (2-10s).

import 'package:cryptography/cryptography.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/session_provider.dart';
import '../../../../core/session/session_state.dart';
import '../../../../presentation/widgets/citadel_snackbar.dart';
import '../../../vault/presentation/providers/multi_vault_provider.dart';
import '../../data/models/ssh_key_data.dart';
import '../providers/ssh_key_providers.dart';

class GenerateKeySheet extends ConsumerStatefulWidget {
  final VoidCallback? onGenerated;

  const GenerateKeySheet({super.key, this.onGenerated});

  @override
  ConsumerState<GenerateKeySheet> createState() => _GenerateKeySheetState();
}

class _GenerateKeySheetState extends ConsumerState<GenerateKeySheet> {
  String _keyType = 'ed25519'; // default recommended
  final _nameController = TextEditingController();
  final _commentController = TextEditingController(text: 'user@citadel');
  final _passphraseController = TextEditingController();
  bool _obscurePassphrase = true;
  bool _isGenerating = false;

  @override
  void dispose() {
    _nameController.dispose();
    _commentController.dispose();
    _passphraseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE0E0E0),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Generate SSH Key',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w700,
              fontSize: 18,
              color: Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 16),

          // Key type selector
          const Text('Key Type',
              style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 13,
                  fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(
                value: 'ed25519',
                label: Text('Ed25519',
                    style: TextStyle(fontFamily: 'Poppins', fontSize: 13)),
                icon: Icon(Icons.star, size: 16),
              ),
              ButtonSegment(
                value: 'rsa4096',
                label: Text('RSA 4096',
                    style: TextStyle(fontFamily: 'Poppins', fontSize: 13)),
              ),
            ],
            selected: {_keyType},
            onSelectionChanged: _isGenerating
                ? null
                : (value) => setState(() => _keyType = value.first),
            style: ButtonStyle(
              foregroundColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return Colors.white;
                }
                return const Color(0xFF4D4DCD);
              }),
              backgroundColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return const Color(0xFF4D4DCD);
                }
                return Colors.transparent;
              }),
            ),
          ),
          if (_keyType == 'ed25519')
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                'Recommended - faster, smaller, more secure',
                style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 11,
                    color: Colors.grey.shade600),
              ),
            ),
          if (_keyType == 'rsa4096')
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                'Wider compatibility - generation takes a few seconds',
                style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 11,
                    color: Colors.grey.shade600),
              ),
            ),
          const SizedBox(height: 16),

          // Name field
          TextField(
            controller: _nameController,
            enabled: !_isGenerating,
            decoration: InputDecoration(
              labelText: 'Key Name *',
              labelStyle: const TextStyle(fontFamily: 'Poppins'),
              hintText: 'e.g. GitHub deploy key',
              hintStyle:
                  TextStyle(fontFamily: 'Poppins', color: Colors.grey.shade400),
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Color(0xFFE8EDF5)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide:
                    const BorderSide(color: Color(0xFF4D4DCD), width: 2),
              ),
              prefixIcon:
                  const Icon(Icons.label_outline, color: Color(0xFF4D4DCD)),
            ),
          ),
          const SizedBox(height: 12),

          // Comment field
          TextField(
            controller: _commentController,
            enabled: !_isGenerating,
            decoration: InputDecoration(
              labelText: 'Comment',
              labelStyle: const TextStyle(fontFamily: 'Poppins'),
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Color(0xFFE8EDF5)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide:
                    const BorderSide(color: Color(0xFF4D4DCD), width: 2),
              ),
              prefixIcon:
                  const Icon(Icons.comment_outlined, color: Color(0xFF4D4DCD)),
            ),
          ),
          const SizedBox(height: 12),

          // Passphrase field
          TextField(
            controller: _passphraseController,
            enabled: !_isGenerating,
            obscureText: _obscurePassphrase,
            decoration: InputDecoration(
              labelText: 'Passphrase (optional)',
              labelStyle: const TextStyle(fontFamily: 'Poppins'),
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Color(0xFFE8EDF5)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide:
                    const BorderSide(color: Color(0xFF4D4DCD), width: 2),
              ),
              prefixIcon:
                  const Icon(Icons.lock_outline, color: Color(0xFF4D4DCD)),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassphrase
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: Colors.grey,
                ),
                onPressed: () =>
                    setState(() => _obscurePassphrase = !_obscurePassphrase),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Generate button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _isGenerating ? null : _generate,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4D4DCD),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
              child: _isGenerating
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          _keyType == 'rsa4096'
                              ? 'Generating RSA 4096...'
                              : 'Generating...',
                          style: const TextStyle(
                              fontFamily: 'Poppins', fontSize: 15),
                        ),
                      ],
                    )
                  : const Text(
                      'Generate',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _generate() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      showCitadelSnackBar(context, 'Please enter a key name',
          type: SnackBarType.error);
      return;
    }

    final session = ref.read(sessionProvider);
    if (session is! Unlocked) {
      showCitadelSnackBar(context, 'Vault is locked',
          type: SnackBarType.error);
      return;
    }

    final multiVaultState = ref.read(multiVaultProvider);
    final vaultId = multiVaultState.selectedVaultId;
    if (vaultId == null) {
      showCitadelSnackBar(context, 'No vault selected',
          type: SnackBarType.error);
      return;
    }

    setState(() => _isGenerating = true);

    try {
      final service = ref.read(sshKeyServiceProvider);
      final comment = _commentController.text.trim();
      final passphrase = _passphraseController.text.trim();

      final keyData = _keyType == 'ed25519'
          ? await service.generateEd25519(
              comment: comment.isEmpty ? null : comment)
          : await service.generateRsa4096(
              comment: comment.isEmpty ? null : comment);

      // If passphrase was provided, store it alongside the key data
      final finalKeyData = passphrase.isNotEmpty
          ? SshKeyData(
              privateKey: keyData.privateKey,
              publicKey: keyData.publicKey,
              keyType: keyData.keyType,
              passphrase: passphrase,
              fingerprint: keyData.fingerprint,
              comment: keyData.comment,
            )
          : keyData;

      final vaultKey = SecretKey(session.vaultKey);
      await service.saveKey(finalKeyData, name, vaultId, vaultKey);

      if (mounted) {
        Navigator.pop(context);
        widget.onGenerated?.call();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isGenerating = false);
        showCitadelSnackBar(context, 'Failed to generate key: $e',
            type: SnackBarType.error);
      }
    }
  }
}
