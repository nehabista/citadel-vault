// P2: CSV import/export with field mapping
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../vault/domain/entities/vault_item.dart';
import '../../../vault/presentation/providers/multi_vault_provider.dart';
import '../../data/parsers/format_detector.dart';
import '../providers/import_provider.dart';

/// Multi-step import wizard for CSV and encrypted backup files.
///
/// Steps:
/// 1. Select file (ImportIdle)
/// 2. Preview items (ImportPreview)
/// 3. Importing progress (ImportInProgress)
/// 4. Complete (ImportComplete)
class ImportPage extends ConsumerWidget {
  const ImportPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final importState = ref.watch(importProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Import'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            ref.read(importProvider.notifier).reset();
            context.pop();
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: switch (importState) {
          ImportIdle() => _buildSelectFile(context, ref),
          ImportParsing() => _buildParsing(context),
          ImportPreview(:final format, :final items, :final targetVaultId) =>
            _buildPreview(context, ref, format, items, targetVaultId),
          ImportInProgress(:final total, :final completed) =>
            _buildProgress(context, total, completed),
          ImportComplete(:final count) => _buildComplete(context, ref, count),
          ImportError(:final message) => _buildError(context, ref, message),
        },
      ),
    );
  }

  Widget _buildSelectFile(BuildContext context, WidgetRef ref) {
    final vaultState = ref.watch(multiVaultProvider);
    final targetVaultId =
        vaultState.selectedVaultId ?? vaultState.vaults.firstOrNull?.id ?? '';

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.upload_file, size: 64, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 16),
          Text(
            'Import Credentials',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Select a CSV file from another password manager',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Supported Formats',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 8),
                  const _FormatChip(label: 'Bitwarden'),
                  const _FormatChip(label: '1Password'),
                  const _FormatChip(label: 'LastPass'),
                  const _FormatChip(label: 'Chrome'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () => ref
                .read(importProvider.notifier)
                .pickAndParse(targetVaultId),
            icon: const Icon(Icons.file_open),
            label: const Text('Select CSV File'),
          ),
        ],
      ),
    );
  }

  Widget _buildParsing(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Parsing file...'),
        ],
      ),
    );
  }

  Widget _buildPreview(
    BuildContext context,
    WidgetRef ref,
    ImportFormat format,
    List<VaultItemEntity> items,
    String targetVaultId,
  ) {
    final vaultState = ref.watch(multiVaultProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Format badge and item count
        Row(
          children: [
            Chip(
              label: Text(_formatLabel(format)),
              avatar: const Icon(Icons.check_circle, size: 18),
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            ),
            const Spacer(),
            Text(
              '${items.length} items found',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Vault selector
        if (vaultState.vaults.length > 1) ...[
          DropdownButtonFormField<String>(
            initialValue: targetVaultId,
            decoration: const InputDecoration(
              labelText: 'Import to vault',
              border: OutlineInputBorder(),
            ),
            items: vaultState.vaults
                .map((v) => DropdownMenuItem(
                      value: v.id,
                      child: Text(v.name),
                    ))
                .toList(),
            onChanged: (value) {
              if (value != null) {
                ref.read(importProvider.notifier).setTargetVault(value);
              }
            },
          ),
          const SizedBox(height: 8),
        ],

        // Preview table
        Expanded(
          child: Card(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SingleChildScrollView(
                child: DataTable(
                  columnSpacing: 16,
                  columns: const [
                    DataColumn(label: Text('Name')),
                    DataColumn(label: Text('Username')),
                    DataColumn(label: Text('URL')),
                    DataColumn(label: Text('Password')),
                  ],
                  rows: items
                      .take(100) // Show max 100 items in preview
                      .map((item) => DataRow(cells: [
                            DataCell(Text(
                              item.name,
                              overflow: TextOverflow.ellipsis,
                            )),
                            DataCell(Text(
                              item.username ?? '',
                              overflow: TextOverflow.ellipsis,
                            )),
                            DataCell(Text(
                              item.url ?? '',
                              overflow: TextOverflow.ellipsis,
                            )),
                            DataCell(Text(
                              item.password != null ? '***' : '-',
                            )),
                          ]))
                      .toList(),
                ),
              ),
            ),
          ),
        ),
        if (items.length > 100)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              'Showing first 100 of ${items.length} items',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),

        const SizedBox(height: 16),

        // Action buttons
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            OutlinedButton(
              onPressed: () => ref.read(importProvider.notifier).reset(),
              child: const Text('Cancel'),
            ),
            const SizedBox(width: 12),
            FilledButton.icon(
              onPressed: () =>
                  ref.read(importProvider.notifier).confirmImport(),
              icon: const Icon(Icons.download),
              label: Text('Import ${items.length} Items'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildProgress(BuildContext context, int total, int completed) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            'Importing $completed of $total...',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildComplete(BuildContext context, WidgetRef ref, int count) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle, size: 64, color: Colors.green[600]),
          const SizedBox(height: 16),
          Text(
            'Import Complete',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            '$count items imported successfully',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: () {
              ref.read(importProvider.notifier).reset();
              context.pop();
            },
            child: const Text('Go to Vault'),
          ),
        ],
      ),
    );
  }

  Widget _buildError(BuildContext context, WidgetRef ref, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red[600]),
          const SizedBox(height: 16),
          Text(
            'Import Error',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: () => ref.read(importProvider.notifier).reset(),
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  String _formatLabel(ImportFormat format) {
    return switch (format) {
      ImportFormat.bitwarden => 'Bitwarden',
      ImportFormat.onePassword => '1Password',
      ImportFormat.lastPass => 'LastPass',
      ImportFormat.chrome => 'Chrome',
      ImportFormat.unknown => 'Encrypted Backup',
    };
  }
}

class _FormatChip extends StatelessWidget {
  final String label;
  const _FormatChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check, size: 16, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 8),
          Text(label),
        ],
      ),
    );
  }
}
