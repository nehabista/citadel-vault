import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/core_providers.dart';
import '../../../../core/providers/session_provider.dart';
import '../../../../core/session/session_state.dart';
import '../../../vault/domain/entities/vault_item.dart';
import '../../../vault/presentation/providers/multi_vault_provider.dart';
import '../../data/services/export_service.dart';

/// Export workflow states.
sealed class ExportState {
  const ExportState();
}

class ExportIdle extends ExportState {
  const ExportIdle();
}

class ExportInProgress extends ExportState {
  const ExportInProgress();
}

class ExportComplete extends ExportState {
  final String filePath;

  const ExportComplete({required this.filePath});
}

class ExportError extends ExportState {
  final String message;

  const ExportError({required this.message});
}

/// Manages vault export: plain CSV or encrypted backup.
class ExportNotifier extends Notifier<ExportState> {
  @override
  ExportState build() => const ExportIdle();

  /// Export vault items as a plain CSV file.
  Future<void> exportCsv() async {
    state = const ExportInProgress();

    try {
      final items = await _getVaultItems();
      if (items == null) return;

      final crypto = ref.read(cryptoEngineProvider);
      final exportService = ExportService(crypto: crypto);
      final bytes = await exportService.exportCsv(items);

      final outputPath = await FilePicker.platform.saveFile(
        dialogTitle: 'Save CSV Export',
        fileName: 'citadel_export_${DateTime.now().millisecondsSinceEpoch}.csv',
        bytes: bytes,
      );

      if (outputPath == null) {
        state = const ExportIdle();
        return;
      }

      state = ExportComplete(filePath: outputPath);
    } catch (e) {
      state = ExportError(message: 'Export failed: $e');
    }
  }

  /// Export vault items as an AES-256-GCM encrypted backup.
  Future<void> exportEncryptedBackup(String backupPassword) async {
    if (backupPassword.isEmpty) {
      state = const ExportError(message: 'Backup password cannot be empty');
      return;
    }

    state = const ExportInProgress();

    try {
      final items = await _getVaultItems();
      if (items == null) return;

      final crypto = ref.read(cryptoEngineProvider);
      final exportService = ExportService(crypto: crypto);
      final bytes =
          await exportService.exportEncryptedBackup(items, backupPassword);

      final outputPath = await FilePicker.platform.saveFile(
        dialogTitle: 'Save Encrypted Backup',
        fileName:
            'citadel_backup_${DateTime.now().millisecondsSinceEpoch}.citadel',
        bytes: bytes,
      );

      if (outputPath == null) {
        state = const ExportIdle();
        return;
      }

      state = ExportComplete(filePath: outputPath);
    } catch (e) {
      state = ExportError(message: 'Export failed: $e');
    }
  }

  /// Reset to idle state.
  void reset() {
    state = const ExportIdle();
  }

  /// Get all items from the currently selected vault.
  Future<List<VaultItemEntity>?> _getVaultItems() async {
    final session = ref.read(sessionProvider);
    if (session is! Unlocked) {
      state = const ExportError(message: 'Vault is locked');
      return null;
    }

    final vaultState = ref.read(multiVaultProvider);
    final selectedVaultId = vaultState.selectedVaultId;
    if (selectedVaultId == null) {
      state = const ExportError(message: 'No vault selected');
      return null;
    }

    final vaultKey = SecretKey(Uint8List.fromList(session.vaultKey));
    final repo = ref.read(vaultRepositoryProvider);
    return repo.getItems(selectedVaultId, vaultKey);
  }
}

final exportProvider =
    NotifierProvider<ExportNotifier, ExportState>(ExportNotifier.new);
