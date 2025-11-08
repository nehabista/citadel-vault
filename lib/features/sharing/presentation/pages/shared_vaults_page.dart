// File: lib/features/sharing/presentation/pages/shared_vaults_page.dart
// Shared vault management UI with role-based access display.
// Per D-07, D-08, D-21, D-23.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/core_providers.dart';
import '../../../../presentation/widgets/citadel_snackbar.dart';
import '../../data/models/vault_member.dart';
import '../providers/sharing_providers.dart';

/// Page displaying shared vaults the current user belongs to.
///
/// Shows vault cards with color-coded teal accent (distinct from personal
/// purple vaults per D-21). Supports creating new shared vaults and
/// managing members for owners.
class SharedVaultsPage extends ConsumerWidget {
  const SharedVaultsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vaultsAsync = ref.watch(userSharedVaultsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Shared Vaults',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: vaultsAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation(Color(0xFF26A69A)),
          ),
        ),
        error: (err, _) => _buildEmptyState(context),
        data: (vaults) {
          if (vaults.isEmpty) {
            return _buildEmptyState(context);
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: vaults.length,
            itemBuilder: (context, index) =>
                _buildVaultCard(context, ref, vaults[index]),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateVaultDialog(context, ref),
        backgroundColor: const Color(0xFF26A69A),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Create Shared Vault',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.group_outlined,
              size: 64,
              color: const Color(0xFF26A69A).withValues(alpha: 0.4),
            ),
            const SizedBox(height: 16),
            const Text(
              'No Shared Vaults',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Create a shared vault to securely share credentials with family or team members.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 13,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVaultCard(
    BuildContext context,
    WidgetRef ref,
    VaultMember member,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () {
          // Navigate to vault detail (reuses existing vault items page).
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Vault icon with teal accent.
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFF26A69A).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.folder_shared,
                  color: Color(0xFF26A69A),
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),

              // Vault info.
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      member.vaultId,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        _buildRoleBadge(member.role),
                        if (member.acceptedAt == null) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.orange.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'Pending',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: Colors.orange,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),

              // Manage button for owners.
              if (member.role == 'owner')
                IconButton(
                  icon: const Icon(
                    Icons.settings,
                    color: Color(0xFF26A69A),
                    size: 20,
                  ),
                  onPressed: () =>
                      _showManageMembersSheet(context, ref, member.vaultId),
                  tooltip: 'Manage Members',
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleBadge(String role) {
    final (IconData icon, Color color, String label) = switch (role) {
      'owner' => (Icons.workspace_premium, const Color(0xFFFFA000), 'Owner'),
      'editor' => (Icons.edit, const Color(0xFF4D4DCD), 'Editor'),
      'viewer' => (Icons.visibility, const Color(0xFF78909C), 'Viewer'),
      _ => (Icons.person, Colors.grey, role),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  void _showCreateVaultDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        title: const Text(
          'Create Shared Vault',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: TextField(
          controller: nameController,
          autofocus: true,
          style: const TextStyle(fontFamily: 'Poppins', fontSize: 14),
          decoration: InputDecoration(
            hintText: 'Vault name',
            hintStyle: TextStyle(
              fontFamily: 'Poppins',
              color: Colors.grey.shade500,
            ),
            filled: true,
            fillColor: Theme.of(ctx).colorScheme.surfaceContainerHighest,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(
                color: Color(0xFF26A69A),
                width: 1.5,
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel',
              style: TextStyle(
                fontFamily: 'Poppins',
                color: Colors.grey.shade600,
              ),
            ),
          ),
          FilledButton(
            onPressed: () async {
              final name = nameController.text.trim();
              if (name.isEmpty) return;
              Navigator.pop(ctx);

              try {
                final service = ref.read(sharedVaultServiceProvider);
                final pb = ref.read(pocketBaseClientProvider);
                final userId = pb.authStore.record?.id ?? '';
                // Publish public key if needed.
                final repo = ref.read(sharingRepositoryProvider);
                await repo.ensureKeypairExists(userId: userId);
                final publicKey =
                    await repo.getLocalPublicKeyBase64();

                await service.createSharedVault(
                  name: name,
                  ownerId: userId,
                  ownerPublicKey: publicKey,
                );

                ref.invalidate(userSharedVaultsProvider);
                if (context.mounted) {
                  showCitadelSnackBar(
                    context,
                    'Shared vault "$name" created',
                    type: SnackBarType.success,
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  showCitadelSnackBar(
                    context,
                    'Failed to create vault',
                    type: SnackBarType.error,
                  );
                }
              }
            },
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF26A69A),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'Create',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showManageMembersSheet(
    BuildContext context,
    WidgetRef ref,
    String vaultId,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ManageMembersSheet(vaultId: vaultId),
    );
  }
}

/// Bottom sheet for managing members of a shared vault.
class _ManageMembersSheet extends ConsumerStatefulWidget {
  final String vaultId;

  const _ManageMembersSheet({required this.vaultId});

  @override
  ConsumerState<_ManageMembersSheet> createState() =>
      _ManageMembersSheetState();
}

class _ManageMembersSheetState extends ConsumerState<_ManageMembersSheet> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _members = [];

  @override
  void initState() {
    super.initState();
    _loadMembers();
  }

  Future<void> _loadMembers() async {
    try {
      final service = ref.read(sharedVaultServiceProvider);
      final records = await service.getVaultMembers(widget.vaultId);
      setState(() {
        _members = records
            .map((r) => {
                  'id': r.id,
                  'userId': r.getStringValue('userId'),
                  'role': r.getStringValue('role'),
                })
            .toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateRole(String memberId, String newRole) async {
    try {
      final service = ref.read(sharedVaultServiceProvider);
      await service.updateMemberRole(memberId, newRole);
      await _loadMembers();
    } catch (e) {
      if (mounted) {
        showCitadelSnackBar(
          context,
          'Failed to update role',
          type: SnackBarType.error,
        );
      }
    }
  }

  Future<void> _removeMember(String memberId) async {
    try {
      final service = ref.read(sharedVaultServiceProvider);
      await service.removeMember(memberId);
      await _loadMembers();
      ref.invalidate(userSharedVaultsProvider);
    } catch (e) {
      if (mounted) {
        showCitadelSnackBar(
          context,
          'Failed to remove member',
          type: SnackBarType.error,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle.
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade400,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
            child: Row(
              children: [
                const Text(
                  'Manage Members',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(32),
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(Color(0xFF26A69A)),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _members.length,
              itemBuilder: (context, index) {
                final member = _members[index];
                return ListTile(
                  leading: CircleAvatar(
                    radius: 18,
                    backgroundColor:
                        const Color(0xFF26A69A).withValues(alpha: 0.12),
                    child: const Icon(
                      Icons.person,
                      color: Color(0xFF26A69A),
                      size: 20,
                    ),
                  ),
                  title: Text(
                    member['userId'] as String,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 13,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: DropdownButton<String>(
                    value: member['role'] as String,
                    isDense: true,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    underline: const SizedBox.shrink(),
                    items: const [
                      DropdownMenuItem(
                        value: 'owner',
                        child: Text('Owner'),
                      ),
                      DropdownMenuItem(
                        value: 'editor',
                        child: Text('Editor'),
                      ),
                      DropdownMenuItem(
                        value: 'viewer',
                        child: Text('Viewer'),
                      ),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        _updateRole(member['id'] as String, val);
                      }
                    },
                  ),
                  trailing: IconButton(
                    icon: Icon(
                      Icons.remove_circle_outline,
                      color: Colors.red.shade400,
                      size: 20,
                    ),
                    onPressed: () =>
                        _removeMember(member['id'] as String),
                  ),
                );
              },
            ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
