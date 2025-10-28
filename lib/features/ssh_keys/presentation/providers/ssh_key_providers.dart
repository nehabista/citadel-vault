// File: lib/features/ssh_keys/presentation/providers/ssh_key_providers.dart
// Riverpod providers for SSH key management.

import 'package:cryptography/cryptography.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/core_providers.dart';
import '../../../../core/providers/session_provider.dart';
import '../../../../core/session/session_state.dart';
import '../../../vault/domain/entities/vault_item.dart';
import '../../data/services/ssh_key_service.dart';

/// Provides a singleton SshKeyService instance.
final sshKeyServiceProvider = Provider<SshKeyService>((ref) {
  final vaultRepo = ref.watch(vaultRepositoryProvider);
  return SshKeyService(vaultRepo);
});

/// Loads all SSH keys from the vault (filtered by type sshKey).
/// Requires the vault to be unlocked.
final sshKeyListProvider = FutureProvider<List<VaultItemEntity>>((ref) async {
  final session = ref.watch(sessionProvider);
  if (session is! Unlocked) {
    throw const VaultLockedException('Vault must be unlocked to view SSH keys');
  }

  final vaultKey = SecretKey(session.vaultKey);
  final service = ref.watch(sshKeyServiceProvider);
  return service.getAllSshKeys(vaultKey);
});
