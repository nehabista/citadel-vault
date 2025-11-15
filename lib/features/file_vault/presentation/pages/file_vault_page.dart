import 'package:cryptography/cryptography.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/session_provider.dart';
import '../../../../core/session/session_state.dart';
import '../../../../core/utils/error_sanitizer.dart';
import '../../../../presentation/widgets/citadel_snackbar.dart';
import '../../domain/entities/file_attachment_entity.dart';
import '../providers/file_vault_providers.dart';
import '../widgets/file_picker_sheet.dart';

/// Section widget that displays a grid of encrypted file attachments
/// for a specific vault item. Embedded in vault detail page per D-19.
///
/// Shows document type icons (not actual previews per security policy),
/// file name (truncated), and file size. Tap to decrypt and open,
/// long-press to delete.
class FileVaultSection extends ConsumerWidget {
  const FileVaultSection({super.key, required this.vaultId});

  final String vaultId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final filesAsync = ref.watch(fileAttachmentsStreamProvider(vaultId));

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.folder_rounded,
                  color: Color(0xFF4D4DCD), size: 20),
              const SizedBox(width: 8),
              Text(
                'Encrypted Files',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          filesAsync.when(
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
            error: (err, _) => Text(
              'Error loading files: ${sanitizeErrorMessage(err)}',
              style: TextStyle(color: theme.colorScheme.error, fontSize: 13),
            ),
            data: (files) => _buildContent(context, ref, theme, files),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    ThemeData theme,
    List<FileAttachmentEntity> files,
  ) {
    if (files.isEmpty) {
      return Column(
        children: [
          Text(
            'No files yet',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 8),
          _buildAddButton(context, ref),
        ],
      );
    }

    return Column(
      children: [
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1.1,
          ),
          itemCount: files.length,
          itemBuilder: (context, index) => _FileCard(
            attachment: files[index],
            vaultId: vaultId,
          ),
        ),
        const SizedBox(height: 12),
        _buildAddButton(context, ref),
      ],
    );
  }

  Widget _buildAddButton(BuildContext context, WidgetRef ref) {
    return TextButton.icon(
      onPressed: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          builder: (_) => FilePickerSheet(vaultId: vaultId),
        );
      },
      icon: const Icon(Icons.add_rounded, size: 18),
      label: const Text('Add File'),
      style: TextButton.styleFrom(
        foregroundColor: const Color(0xFF4D4DCD),
      ),
    );
  }
}

/// Card widget for a single file attachment in the grid.
///
/// Shows a document type icon (not actual preview per security policy),
/// truncated file name, and formatted size.
class _FileCard extends ConsumerWidget {
  const _FileCard({required this.attachment, required this.vaultId});

  final FileAttachmentEntity attachment;
  final String vaultId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () => _decryptAndOpen(context, ref),
      onLongPress: () => _confirmDelete(context, ref),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF4D4DCD).withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: const Color(0xFF4D4DCD).withValues(alpha: 0.15),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _iconForMime(attachment.mimeType),
              size: 36,
              color: const Color(0xFF4D4DCD),
            ),
            const SizedBox(height: 8),
            Text(
              attachment.fileName,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              attachment.formattedSize,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _decryptAndOpen(BuildContext context, WidgetRef ref) async {
    final session = ref.read(sessionProvider);
    if (session is! Unlocked) {
      showCitadelSnackBar(context, 'Vault is locked', type: SnackBarType.error);
      return;
    }

    try {
      final service = ref.read(fileEncryptionServiceProvider);
      final vaultKey = SecretKey(session.vaultKey);
      await service.decryptAndOpen(attachment, vaultKey);
    } catch (e) {
      if (!context.mounted) return;
      showCitadelSnackBar(
        context,
        'Failed to open file: $e',
        type: SnackBarType.error,
      );
    }
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(
          'Delete File',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
          ),
        ),
        content:
            Text('Delete "${attachment.fileName}"? This cannot be undone.'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    try {
      final service = ref.read(fileEncryptionServiceProvider);
      await service.deleteFile(attachment);
      if (!context.mounted) return;
      showCitadelSnackBar(context, 'File deleted', type: SnackBarType.success);
      // Stream provider auto-refreshes
    } catch (e) {
      if (!context.mounted) return;
      showCitadelSnackBar(
        context,
        'Error deleting file: ${sanitizeErrorMessage(e)}',
        type: SnackBarType.error,
      );
    }
  }

  /// Returns an appropriate icon for the file's MIME type.
  /// Shows document type icons, NOT actual previews (security policy).
  IconData _iconForMime(String mimeType) {
    if (mimeType.startsWith('image/')) return Icons.image_rounded;
    if (mimeType == 'application/pdf') return Icons.picture_as_pdf_rounded;
    if (mimeType.startsWith('text/')) return Icons.description_rounded;
    return Icons.insert_drive_file_rounded;
  }
}
