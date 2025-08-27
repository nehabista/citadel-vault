import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/core_providers.dart';
import '../../../../core/providers/session_provider.dart';
import '../../../../core/session/session_state.dart';
import '../../../vault/domain/entities/vault_item.dart';
import '../../data/parsers/format_detector.dart';
import '../../data/services/import_service.dart';

/// Import workflow states.
sealed class ImportState {
  const ImportState();
}

class ImportIdle extends ImportState {
  const ImportIdle();
}

class ImportParsing extends ImportState {
  const ImportParsing();
}

class ImportPreview extends ImportState {
  final ImportFormat format;
  final List<VaultItemEntity> items;
  final String targetVaultId;

  const ImportPreview({
    required this.format,
    required this.items,
    required this.targetVaultId,
  });

  ImportPreview copyWith({
    ImportFormat? format,
    List<VaultItemEntity>? items,
    String? targetVaultId,
  }) {
    return ImportPreview(
      format: format ?? this.format,
      items: items ?? this.items,
      targetVaultId: targetVaultId ?? this.targetVaultId,
    );
  }
}

class ImportInProgress extends ImportState {
  final int total;
  final int completed;

  const ImportInProgress({required this.total, required this.completed});
}

class ImportComplete extends ImportState {
  final int count;

  const ImportComplete({required this.count});
}

class ImportError extends ImportState {
  final String message;

  const ImportError({required this.message});
}

/// Manages the import workflow: file pick, parse, preview, commit.
class ImportNotifier extends Notifier<ImportState> {
  @override
  ImportState build() => const ImportIdle();

  /// Pick a CSV file, parse it, and transition to preview state.
  Future<void> pickAndParse(String targetVaultId) async {
    state = const ImportParsing();

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv', 'txt'],
        withData: true,
      );

      if (result == null || result.files.isEmpty) {
        state = const ImportIdle();
        return;
      }

      final fileBytes = result.files.first.bytes;
      if (fileBytes == null) {
        state = const ImportError(message: 'Could not read file data');
        return;
      }

      final repo = ref.read(vaultRepositoryProvider);
      final importService = ImportService(repository: repo);
      final (format, items) =
          await importService.parseFile(fileBytes, targetVaultId);

      state = ImportPreview(
        format: format,
        items: items,
        targetVaultId: targetVaultId,
      );
    } on ImportFormatException catch (e) {
      state = ImportError(message: e.message);
    } catch (e) {
      state = ImportError(message: 'Import failed: $e');
    }
  }

  /// Pick and parse an encrypted backup file.
  Future<void> pickAndParseEncryptedBackup(
    String targetVaultId,
    String backupPassword,
  ) async {
    state = const ImportParsing();

    try {
      final result = await FilePicker.platform.pickFiles(withData: true);

      if (result == null || result.files.isEmpty) {
        state = const ImportIdle();
        return;
      }

      final fileBytes = result.files.first.bytes;
      if (fileBytes == null) {
        state = const ImportError(message: 'Could not read file data');
        return;
      }

      final repo = ref.read(vaultRepositoryProvider);
      final crypto = ref.read(cryptoEngineProvider);
      final importService = ImportService(repository: repo);
      final items = await importService.parseEncryptedBackup(
        fileBytes,
        backupPassword,
        crypto,
      );

      // Update vault IDs to the target vault
      final updatedItems = items
          .map((item) => item.copyWith(vaultId: targetVaultId))
          .toList();

      state = ImportPreview(
        format: ImportFormat.unknown, // encrypted backup
        items: updatedItems,
        targetVaultId: targetVaultId,
      );
    } catch (e) {
      state = ImportError(
          message: 'Failed to decrypt backup. Check your password.');
    }
  }

  /// Update the target vault for imported items.
  void setTargetVault(String vaultId) {
    final current = state;
    if (current is ImportPreview) {
      state = current.copyWith(targetVaultId: vaultId);
    }
  }

  /// Commit the previewed items to the vault.
  Future<void> confirmImport() async {
    final current = state;
    if (current is! ImportPreview) return;

    state = ImportInProgress(total: current.items.length, completed: 0);

    try {
      final session = ref.read(sessionProvider);
      if (session is! Unlocked) {
        state = const ImportError(message: 'Vault is locked');
        return;
      }

      final vaultKey = SecretKey(Uint8List.fromList(session.vaultKey));
      final repo = ref.read(vaultRepositoryProvider);
      final importService = ImportService(repository: repo);
      final count = await importService.commitImport(current.items, vaultKey);

      state = ImportComplete(count: count);
    } catch (e) {
      state = ImportError(message: 'Import failed: $e');
    }
  }

  /// Reset to idle state.
  void reset() {
    state = const ImportIdle();
  }
}

final importProvider =
    NotifierProvider<ImportNotifier, ImportState>(ImportNotifier.new);
