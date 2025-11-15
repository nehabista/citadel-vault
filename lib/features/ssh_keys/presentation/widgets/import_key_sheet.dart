// File: lib/features/ssh_keys/presentation/widgets/import_key_sheet.dart
// Bottom sheet for importing SSH keys from text or file.
// Per D-17: paste key text or pick a file.

import 'dart:io';

import 'package:cryptography/cryptography.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/session_provider.dart';
import '../../../../core/session/session_state.dart';
import '../../../../core/utils/error_sanitizer.dart';
import '../../../../presentation/widgets/citadel_snackbar.dart';
import '../../../vault/presentation/providers/multi_vault_provider.dart';
import '../../data/models/ssh_key_data.dart';
import '../providers/ssh_key_providers.dart';

class ImportKeySheet extends ConsumerStatefulWidget {
  final VoidCallback? onImported;

  const ImportKeySheet({super.key, this.onImported});

  @override
  ConsumerState<ImportKeySheet> createState() => _ImportKeySheetState();
}

class _ImportKeySheetState extends ConsumerState<ImportKeySheet> {
  final _nameController = TextEditingController();
  final _keyTextController = TextEditingController();
  bool _isImporting = false;
  SshKeyData? _previewData;
  String? _parseError;

  @override
  void dispose() {
    _nameController.dispose();
    _keyTextController.dispose();
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
            'Import SSH Key',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w700,
              fontSize: 18,
              color: Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 16),

          // Name field
          TextField(
            controller: _nameController,
            enabled: !_isImporting,
            decoration: InputDecoration(
              labelText: 'Key Name *',
              labelStyle: const TextStyle(fontFamily: 'Poppins'),
              hintText: 'e.g. Production server key',
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
          const SizedBox(height: 16),

          // Paste key or pick file
          Row(
            children: [
              const Text('Private Key',
                  style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 13,
                      fontWeight: FontWeight.w500)),
              const Spacer(),
              TextButton.icon(
                onPressed: _isImporting ? null : _pickFile,
                icon: const Icon(Icons.file_open_outlined, size: 16),
                label: const Text('Pick File',
                    style: TextStyle(fontFamily: 'Poppins', fontSize: 12)),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF4D4DCD),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          TextField(
            controller: _keyTextController,
            enabled: !_isImporting,
            maxLines: 5,
            minLines: 3,
            style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
            decoration: InputDecoration(
              hintText: '-----BEGIN OPENSSH PRIVATE KEY-----\n...\n-----END OPENSSH PRIVATE KEY-----',
              hintStyle: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 11,
                  color: Colors.grey.shade400),
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
            ),
            onChanged: (_) => _tryParse(),
          ),

          // Parse error or preview
          if (_parseError != null) ...[
            const SizedBox(height: 8),
            Text(
              _parseError!,
              style: const TextStyle(
                  fontFamily: 'Poppins', fontSize: 12, color: Colors.red),
            ),
          ],
          if (_previewData != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Detected: ${_previewData!.keyType == 'ed25519' ? 'Ed25519' : 'RSA'}',
                    style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12,
                        fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _previewData!.fingerprint,
                    style: const TextStyle(
                        fontFamily: 'monospace', fontSize: 11),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 20),

          // Import button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _isImporting || _previewData == null ? null : _import,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4D4DCD),
                foregroundColor: Colors.white,
                disabledBackgroundColor: const Color(0xFF4D4DCD).withValues(alpha: 0.4),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
              child: _isImporting
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Text(
                      'Import',
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

  void _tryParse() {
    final text = _keyTextController.text.trim();
    if (text.isEmpty) {
      setState(() {
        _previewData = null;
        _parseError = null;
      });
      return;
    }

    try {
      final service = ref.read(sshKeyServiceProvider);
      final data = service.importFromText(text);
      setState(() {
        _previewData = data;
        _parseError = null;
      });
    } catch (e) {
      setState(() {
        _previewData = null;
        _parseError = 'Could not parse SSH key. Ensure it\'s in OpenSSH format.';
      });
    }
  }

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty) return;

      final path = result.files.first.path;
      if (path == null) return;

      final content = await File(path).readAsString();
      _keyTextController.text = content;
      _tryParse();
    } catch (e) {
      if (mounted) {
        showCitadelSnackBar(context,
            'Failed to read file: ${sanitizeErrorMessage(e)}',
            type: SnackBarType.error);
      }
    }
  }

  Future<void> _import() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      showCitadelSnackBar(context, 'Please enter a key name',
          type: SnackBarType.error);
      return;
    }

    if (_previewData == null) return;

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

    setState(() => _isImporting = true);

    try {
      final service = ref.read(sshKeyServiceProvider);
      final vaultKey = SecretKey(session.vaultKey);
      await service.saveKey(_previewData!, name, vaultId, vaultKey);

      if (mounted) {
        Navigator.pop(context);
        widget.onImported?.call();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isImporting = false);
        showCitadelSnackBar(context,
            'Failed to import key: ${sanitizeErrorMessage(e)}',
            type: SnackBarType.error);
      }
    }
  }
}
