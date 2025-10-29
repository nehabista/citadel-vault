// File: lib/features/email_alias/presentation/pages/alias_list_page.dart
// Alias list page with search, status badges, and API key setup.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../presentation/widgets/citadel_snackbar.dart';
import '../../data/models/alias_model.dart';
import '../../data/services/simple_login_service.dart';
import '../providers/alias_providers.dart';
import '../widgets/create_alias_sheet.dart';

class AliasListPage extends ConsumerStatefulWidget {
  const AliasListPage({super.key});

  @override
  ConsumerState<AliasListPage> createState() => _AliasListPageState();
}

class _AliasListPageState extends ConsumerState<AliasListPage> {
  bool _showSearch = false;
  String _searchQuery = '';
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final apiKeyAsync = ref.watch(aliasApiKeyProvider);

    return Scaffold(
      appBar: AppBar(
        title: _showSearch
            ? TextField(
                controller: _searchController,
                autofocus: true,
                style: const TextStyle(fontFamily: 'Poppins', fontSize: 16),
                decoration: const InputDecoration(
                  hintText: 'Search aliases...',
                  hintStyle: TextStyle(fontFamily: 'Poppins'),
                  border: InputBorder.none,
                ),
                onChanged: (v) => setState(() => _searchQuery = v),
              )
            : const Text(
                'Email Aliases',
                style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600),
              ),
        actions: [
          IconButton(
            icon: Icon(_showSearch ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _showSearch = !_showSearch;
                if (!_showSearch) {
                  _searchQuery = '';
                  _searchController.clear();
                }
              });
            },
          ),
        ],
      ),
      body: apiKeyAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Text(
            'Error loading API key: $e',
            style: const TextStyle(fontFamily: 'Poppins', color: Colors.red),
          ),
        ),
        data: (apiKey) {
          if (apiKey == null) return _ApiKeySetupView();
          return _AliasListView(searchQuery: _searchQuery);
        },
      ),
      floatingActionButton: apiKeyAsync.value != null
          ? FloatingActionButton(
              backgroundColor: const Color(0xFF4D4DCD),
              onPressed: () => _showCreateSheet(context),
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
    );
  }

  void _showCreateSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const CreateAliasSheet(),
    );
  }
}

// ---------------------------------------------------------------------------
// API Key Setup View (shown when no key is configured)
// ---------------------------------------------------------------------------

class _ApiKeySetupView extends ConsumerStatefulWidget {
  @override
  ConsumerState<_ApiKeySetupView> createState() => _ApiKeySetupViewState();
}

class _ApiKeySetupViewState extends ConsumerState<_ApiKeySetupView> {
  final _keyController = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _keyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.alternate_email, size: 64, color: Color(0xFF4D4DCD)),
          const SizedBox(height: 16),
          const Text(
            'Connect SimpleLogin',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w700,
              fontSize: 20,
              color: Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Enter your SimpleLogin API key to manage email aliases.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _keyController,
            decoration: InputDecoration(
              labelText: 'API Key',
              labelStyle: const TextStyle(fontFamily: 'Poppins'),
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Color(0xFFE8EDF5)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Color(0xFF4D4DCD), width: 2),
              ),
              prefixIcon: const Icon(Icons.vpn_key, color: Color(0xFF4D4DCD)),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _saving
                  ? null
                  : () async {
                      final key = _keyController.text.trim();
                      if (key.isEmpty) return;
                      setState(() => _saving = true);
                      try {
                        await ref.read(aliasActionsProvider).saveApiKey(key);
                        if (context.mounted) {
                          showCitadelSnackBar(context, 'API key saved',
                              type: SnackBarType.success);
                        }
                      } catch (e) {
                        if (context.mounted) {
                          showCitadelSnackBar(context, 'Failed to save: $e',
                              type: SnackBarType.error);
                        }
                      } finally {
                        if (mounted) setState(() => _saving = false);
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4D4DCD),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
              child: _saving
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Text(
                      'Save',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () {
              launchUrl(Uri.parse('https://simplelogin.io'));
            },
            child: const Text(
              "Don't have an account? Sign up at simplelogin.io",
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 13,
                color: Color(0xFF4D4DCD),
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Alias List View (shown when API key is configured)
// ---------------------------------------------------------------------------

class _AliasListView extends ConsumerWidget {
  final String searchQuery;
  const _AliasListView({required this.searchQuery});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final aliasesAsync = ref.watch(aliasListProvider);

    return aliasesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) {
        if (e is InvalidApiKeyException) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 12),
                  const Text(
                    'Invalid API key. Please check your key in Settings.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontFamily: 'Poppins', fontSize: 14),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () async {
                      await ref.read(aliasActionsProvider).removeApiKey();
                    },
                    child: const Text(
                      'Re-enter API Key',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        color: Color(0xFF4D4DCD),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        return Center(
          child: Text(
            'Error: $e',
            style: const TextStyle(fontFamily: 'Poppins', color: Colors.red),
          ),
        );
      },
      data: (aliases) {
        final filtered = searchQuery.isEmpty
            ? aliases
            : aliases
                .where((a) =>
                    a.email.toLowerCase().contains(searchQuery.toLowerCase()))
                .toList();

        if (filtered.isEmpty) {
          return Center(
            child: Text(
              searchQuery.isEmpty
                  ? 'No aliases yet. Tap + to create one.'
                  : 'No aliases match "$searchQuery".',
              style: TextStyle(
                fontFamily: 'Poppins',
                color: Colors.grey.shade500,
              ),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async => ref.invalidate(aliasListProvider),
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: filtered.length,
            itemBuilder: (context, index) =>
                _AliasCard(alias: filtered[index]),
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Alias Card
// ---------------------------------------------------------------------------

class _AliasCard extends ConsumerWidget {
  final AliasModel alias;
  const _AliasCard({required this.alias});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 1,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () {
          Clipboard.setData(ClipboardData(text: alias.email));
          showCitadelSnackBar(context, 'Alias copied');
        },
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      alias.email,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        _StatusBadge(enabled: alias.enabled),
                        const SizedBox(width: 10),
                        _StatChip(icon: Icons.forward, count: alias.nbForward),
                        const SizedBox(width: 6),
                        _StatChip(icon: Icons.block, count: alias.nbBlock),
                        const SizedBox(width: 6),
                        _StatChip(icon: Icons.reply, count: alias.nbReply),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatDate(alias.createdAt),
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 11,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (value) =>
                    _handleMenuAction(context, ref, value),
                itemBuilder: (_) => [
                  const PopupMenuItem(
                    value: 'toggle',
                    child: Text('Toggle', style: TextStyle(fontFamily: 'Poppins')),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Text('Delete',
                        style: TextStyle(fontFamily: 'Poppins', color: Colors.red)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleMenuAction(
      BuildContext context, WidgetRef ref, String action) async {
    final actions = ref.read(aliasActionsProvider);
    switch (action) {
      case 'toggle':
        try {
          final enabled = await actions.toggle(alias.id);
          if (context.mounted) {
            showCitadelSnackBar(
              context,
              enabled ? 'Alias activated' : 'Alias deactivated',
            );
          }
        } catch (e) {
          if (context.mounted) {
            showCitadelSnackBar(context, 'Toggle failed: $e',
                type: SnackBarType.error);
          }
        }
      case 'delete':
        final confirm = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Delete Alias',
                style: TextStyle(fontFamily: 'Poppins')),
            content: Text(
              'Permanently delete ${alias.email}? This cannot be undone.',
              style: const TextStyle(fontFamily: 'Poppins'),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancel',
                    style: TextStyle(fontFamily: 'Poppins')),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Delete',
                    style: TextStyle(
                        fontFamily: 'Poppins', color: Colors.red)),
              ),
            ],
          ),
        );
        if (confirm == true) {
          try {
            await actions.delete(alias.id);
            if (context.mounted) {
              showCitadelSnackBar(context, 'Alias deleted');
            }
          } catch (e) {
            if (context.mounted) {
              showCitadelSnackBar(context, 'Delete failed: $e',
                  type: SnackBarType.error);
            }
          }
        }
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}

// ---------------------------------------------------------------------------
// Small UI components
// ---------------------------------------------------------------------------

class _StatusBadge extends StatelessWidget {
  final bool enabled;
  const _StatusBadge({required this.enabled});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: enabled
            ? const Color(0xFF43A047).withValues(alpha: 0.12)
            : const Color(0xFFE53935).withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        enabled ? 'Active' : 'Inactive',
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: enabled ? const Color(0xFF43A047) : const Color(0xFFE53935),
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final int count;
  const _StatChip({required this.icon, required this.count});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: Colors.grey.shade500),
        const SizedBox(width: 2),
        Text(
          '$count',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 11,
            color: Colors.grey.shade500,
          ),
        ),
      ],
    );
  }
}
