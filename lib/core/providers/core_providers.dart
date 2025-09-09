// File: lib/core/providers/core_providers.dart
// Core infrastructure providers for CryptoEngine, services, and PocketBase
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocketbase/pocketbase.dart';

import '../../data/services/api/pocketbase_service.dart';
import '../../data/services/auth/auth_service.dart';
import '../../data/services/auth/local_auth_service.dart';
import '../../data/services/auth/session_service.dart';
import '../../data/services/crypto/encryption_service.dart';
import '../../data/services/vault/vault_service.dart';
import '../crypto/crypto_engine.dart';
import '../crypto/legacy_crypto.dart';
import '../database/app_database.dart';
import '../../features/security/data/repositories/totp_repository.dart';
import '../../features/security/data/services/totp_service.dart';
import '../../features/vault/data/repositories/vault_repository_impl.dart';
import '../../features/vault/domain/repositories/vault_repository.dart';
import '../../features/security/data/services/breach_service.dart';
import '../../features/security/data/services/watchtower_service.dart';
import '../../features/security/data/repositories/breach_repository.dart';

/// Provides the AppDatabase instance.
/// Must be overridden at app startup with an actual encrypted database.
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  throw UnimplementedError(
    'appDatabaseProvider must be overridden with ProviderScope.overrides',
  );
});

/// Provides a singleton CryptoEngine instance (Argon2id + AES-256-GCM).
final cryptoEngineProvider = Provider<CryptoEngine>((ref) => CryptoEngine());

/// Provides the legacy EncryptionService (PBKDF2 + AES-CBC).
final encryptionServiceProvider =
    Provider<EncryptionService>((ref) => EncryptionService());

/// Provides the SessionService for legacy session management.
final sessionServiceProvider =
    Provider<SessionService>((ref) => SessionService());

/// Provides PocketBaseService (must be initialized before use).
final pocketBaseServiceProvider = Provider<PocketBaseService>((ref) {
  return PocketBaseService();
});

/// Provides the PocketBase client instance.
final pocketBaseClientProvider = Provider<PocketBase>((ref) {
  return ref.watch(pocketBaseServiceProvider).client;
});

/// Provides the LocalAuthService with constructor injection.
final localAuthServiceProvider = Provider<LocalAuthService>((ref) {
  return LocalAuthService(
    encryptionService: ref.watch(encryptionServiceProvider),
  );
});

/// Provides the AuthService with constructor injection.
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(
    pb: ref.watch(pocketBaseClientProvider),
    encryptionService: ref.watch(encryptionServiceProvider),
    sessionService: ref.watch(sessionServiceProvider),
    localAuthService: ref.watch(localAuthServiceProvider),
  );
});

/// Provides the VaultService with constructor injection (legacy).
final vaultServiceProvider = Provider<VaultService>((ref) {
  return VaultService(
    pb: ref.watch(pocketBaseClientProvider),
    encryptionService: ref.watch(encryptionServiceProvider),
    sessionService: ref.watch(sessionServiceProvider),
  );
});

/// Provides LegacyCrypto for v1 decryption during migration.
final legacyCryptoProvider = Provider<LegacyCrypto>((ref) => LegacyCrypto());

/// Provides VaultRepository (new Argon2id+AES-GCM path, offline-first).
final vaultRepositoryProvider = Provider<VaultRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return VaultRepositoryImpl(
    vaultDao: db.vaultDao,
    syncDao: db.syncDao,
    cryptoEngine: ref.watch(cryptoEngineProvider),
    passwordHistoryDao: db.passwordHistoryDao,
  );
});

/// Provides a singleton TotpService instance.
final totpServiceProvider = Provider<TotpService>((ref) => TotpService());

/// Provides TotpRepository using TotpDao + CryptoEngine.
final totpRepositoryProvider = Provider<TotpRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return TotpRepository(
    totpDao: db.totpDao,
    cryptoEngine: ref.watch(cryptoEngineProvider),
  );
});
