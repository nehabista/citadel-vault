import 'package:cryptography/cryptography.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/session_provider.dart';
import '../../../../core/session/session_state.dart';
import '../../../../presentation/widgets/citadel_snackbar.dart';
import '../../data/services/file_encryption_service.dart';
import '../providers/file_vault_providers.dart';

/// Bottom sheet for picking and encrypting a file into the vault.
///
/// Per D-07/D-08: Opens file_picker with allowed extensions,
/// shows size warning at 5MB, rejects at 10MB, encrypts with
/// CryptoEngine, and saves metadata to Drift.
class FilePickerSheet extends ConsumerStatefulWidget {
  const FilePickerSheet({super.key, required this.vaultId});

  final String vaultId;

  @override
  ConsumerState<FilePickerSheet> createState() => _FilePickerSheetState();
}

class _FilePickerSheetState extends ConsumerState<FilePickerSheet> {
  bool _isEncrypting = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Add Encrypted File',
            style: theme.textTheme.titleLarge?.copyWith(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Choose a file to encrypt and store securely.\nSupported: JPG, PNG, PDF, TXT (max 10MB)',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 24),
          if (_isEncrypting)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Column(
                children: [
                  CircularProgressIndicator(
                    color: Color(0xFF4D4DCD),
                    strokeWidth: 3,
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Encrypting file...',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      color: Color(0xFF4D4DCD),
                    ),
                  ),
                ],
              ),
            )
          else
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _pickAndEncrypt,
                icon: const Icon(Icons.upload_file_rounded),
                label: const Text(
                  'Choose File',
                  style: TextStyle(fontFamily: 'Poppins'),
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF4D4DCD),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Future<void> _pickAndEncrypt() async {
    final session = ref.read(sessionProvider);
    if (session is! Unlocked) {
      showCitadelSnackBar(context, 'Vault is locked', type: SnackBarType.error);
      return;
    }

    // Pick file with allowed extensions per D-08
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: FileEncryptionService.allowedExtensions,
    );

    if (result == null || result.files.isEmpty) return;

    final pickedFile = result.files.first;
    final filePath = pickedFile.path;
    final fileName = pickedFile.name;
    final fileSize = pickedFile.size;

    if (filePath == null) {
      if (!mounted) return;
      showCitadelSnackBar(
        context,
        'Could not access file',
        type: SnackBarType.error,
      );
      return;
    }

    // Reject files >10MB per D-08
    if (fileSize > FileEncryptionService.maxFileSizeBytes) {
      if (!mounted) return;
      showCitadelSnackBar(
        context,
        'File must be under 10MB',
        type: SnackBarType.error,
      );
      return;
    }

    // Show warning for files >5MB per D-08
    if (fileSize > FileEncryptionService.warnFileSizeBytes) {
      if (!mounted) return;
      final sizeMb = (fileSize / (1024 * 1024)).toStringAsFixed(1);
      final proceed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text(
            'Large File',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Text(
            'This file is $sizeMb MB. Encryption may take a moment. Continue?',
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF4D4DCD),
              ),
              child: const Text('Continue'),
            ),
          ],
        ),
      );
      if (proceed != true) return;
    }

    // Encrypt and store
    if (!mounted) return;
    setState(() => _isEncrypting = true);

    try {
      final service = ref.read(fileEncryptionServiceProvider);
      final vaultKey = SecretKey(session.vaultKey);

      await service.encryptAndStore(
        filePath: filePath,
        fileName: fileName,
        vaultId: widget.vaultId,
        vaultKey: vaultKey,
      );

      if (!mounted) return;
      Navigator.pop(context);
      showCitadelSnackBar(
        context,
        'File encrypted and saved',
        type: SnackBarType.success,
      );
    } on FileTooLargeException {
      if (!mounted) return;
      setState(() => _isEncrypting = false);
      showCitadelSnackBar(
        context,
        'File must be under 10MB',
        type: SnackBarType.error,
      );
    } on UnsupportedFileTypeException {
      if (!mounted) return;
      setState(() => _isEncrypting = false);
      showCitadelSnackBar(
        context,
        'Only images (JPG, PNG), PDFs, and text files are supported',
        type: SnackBarType.error,
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isEncrypting = false);
      showCitadelSnackBar(
        context,
        'Failed to save file: $e',
        type: SnackBarType.error,
      );
    }
  }
}
