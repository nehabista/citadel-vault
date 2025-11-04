// File: lib/features/email_alias/presentation/providers/alias_providers.dart
// Riverpod providers for SimpleLogin and DuckDuckGo email alias management.
import 'package:cryptography/cryptography.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../../../../core/providers/core_providers.dart';
import '../../../../core/providers/session_provider.dart';
import '../../../../core/session/session_state.dart';
import '../../data/models/alias_model.dart';
import '../../data/services/duckduckgo_alias_service.dart';
import '../../data/services/simple_login_service.dart';

// ---------------------------------------------------------------------------
// Service provider
// ---------------------------------------------------------------------------

/// Provides a singleton [SimpleLoginService] instance.
final simpleLoginServiceProvider = Provider<SimpleLoginService>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return SimpleLoginService(
    http.Client(),
    db.settingsDao,
    ref.watch(cryptoEngineProvider),
  );
});

// ---------------------------------------------------------------------------
// Vault key helper
// ---------------------------------------------------------------------------

/// Extracts the [SecretKey] from the current session. Throws if locked.
SecretKey _vaultKeyFromRef(Ref ref) {
  final session = ref.read(sessionProvider);
  return switch (session) {
    Unlocked(:final vaultKey) => SecretKey(vaultKey),
    Locked() => throw StateError('Vault is locked'),
  };
}

// ---------------------------------------------------------------------------
// API key provider
// ---------------------------------------------------------------------------

/// Reads the encrypted API key from storage. Returns null if not configured.
final aliasApiKeyProvider = FutureProvider<String?>((ref) async {
  final service = ref.watch(simpleLoginServiceProvider);
  final vaultKey = _vaultKeyFromRef(ref);
  return service.getApiKey(vaultKey);
});

// ---------------------------------------------------------------------------
// Alias list provider
// ---------------------------------------------------------------------------

/// Fetches and caches the alias list from SimpleLogin.
///
/// Returns an empty list when the API key is not configured.
/// When the API key is invalid, sets the error state so the UI can prompt.
final aliasListProvider = FutureProvider<List<AliasModel>>((ref) async {
  final apiKey = await ref.watch(aliasApiKeyProvider.future);
  if (apiKey == null) return [];

  final service = ref.watch(simpleLoginServiceProvider);
  try {
    // Load all pages into a single list for local search/cache.
    final allAliases = <AliasModel>[];
    var pageId = 0;
    while (true) {
      final page = await service.listAliases(apiKey, pageId: pageId);
      allAliases.addAll(page);
      if (page.length < 20) break; // last page
      pageId++;
    }
    return allAliases;
  } on InvalidApiKeyException {
    // Re-throw so the UI can distinguish an auth error from empty list.
    rethrow;
  }
});

// ---------------------------------------------------------------------------
// Alias actions notifier
// ---------------------------------------------------------------------------

/// Provides mutation methods for alias create / toggle / delete.
///
/// After each mutation the [aliasListProvider] is invalidated so the
/// list auto-refreshes.
final aliasActionsProvider =
    Provider<AliasActions>((ref) => AliasActions(ref));

class AliasActions {
  final Ref _ref;
  const AliasActions(this._ref);

  SimpleLoginService get _service =>
      _ref.read(simpleLoginServiceProvider);

  Future<String> _apiKey() async {
    final key = await _ref.read(aliasApiKeyProvider.future);
    if (key == null) throw const InvalidApiKeyException('No API key configured');
    return key;
  }

  /// Save the user's API key (encrypted) and refresh dependent providers.
  Future<void> saveApiKey(String apiKey) async {
    final vaultKey = _vaultKeyFromRef(_ref);
    await _service.saveApiKey(apiKey, vaultKey);
    _ref.invalidate(aliasApiKeyProvider);
    _ref.invalidate(aliasListProvider);
  }

  /// Remove the stored API key.
  Future<void> removeApiKey() async {
    await _service.removeApiKey();
    _ref.invalidate(aliasApiKeyProvider);
    _ref.invalidate(aliasListProvider);
  }

  /// Create a random alias with optional [note].
  Future<AliasModel> createRandom({String? note}) async {
    final key = await _apiKey();
    final alias = await _service.createRandomAlias(key, note: note);
    _ref.invalidate(aliasListProvider);
    return alias;
  }

  /// Get suffix options for custom alias creation.
  Future<Map<String, dynamic>> getOptions() async {
    final key = await _apiKey();
    return _service.getAliasOptions(key);
  }

  /// Create a custom alias.
  Future<AliasModel> createCustom({
    required String prefix,
    required String signedSuffix,
    String? note,
  }) async {
    final key = await _apiKey();
    final alias = await _service.createCustomAlias(
      key,
      aliasPrefix: prefix,
      signedSuffix: signedSuffix,
      note: note,
    );
    _ref.invalidate(aliasListProvider);
    return alias;
  }

  /// Toggle an alias active/inactive. Returns new enabled state.
  Future<bool> toggle(int aliasId) async {
    final key = await _apiKey();
    final enabled = await _service.toggleAlias(key, aliasId);
    _ref.invalidate(aliasListProvider);
    return enabled;
  }

  /// Delete an alias permanently.
  Future<void> delete(int aliasId) async {
    final key = await _apiKey();
    await _service.deleteAlias(key, aliasId);
    _ref.invalidate(aliasListProvider);
  }
}

// ===========================================================================
// DuckDuckGo Email Protection providers
// ===========================================================================

/// Provides a singleton [DuckDuckGoAliasService] instance.
final ddgAliasServiceProvider = Provider<DuckDuckGoAliasService>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return DuckDuckGoAliasService(
    http.Client(),
    db.settingsDao,
    ref.watch(cryptoEngineProvider),
  );
});

/// Reads the encrypted DDG token from storage. Returns null if not authenticated.
final ddgTokenProvider = FutureProvider<String?>((ref) async {
  final service = ref.watch(ddgAliasServiceProvider);
  final vaultKey = _vaultKeyFromRef(ref);
  return service.getToken(vaultKey);
});

/// Tracks generated DDG aliases for the current session.
///
/// Persists in-memory; the list resets when the app restarts.
final ddgAliasListProvider =
    NotifierProvider<DdgAliasListNotifier, List<String>>(
  DdgAliasListNotifier.new,
);

class DdgAliasListNotifier extends Notifier<List<String>> {
  @override
  List<String> build() => [];

  void addAlias(String alias) {
    state = [alias, ...state];
  }

  void clear() {
    state = [];
  }
}

/// Provides mutation methods for DuckDuckGo alias management.
final ddgActionsProvider = Provider<DdgActions>((ref) => DdgActions(ref));

class DdgActions {
  final Ref _ref;
  const DdgActions(this._ref);

  DuckDuckGoAliasService get _service =>
      _ref.read(ddgAliasServiceProvider);

  /// Request an OTP email for the given duck.com username.
  Future<void> requestOtp(String duckUsername) async {
    await _service.requestOtp(duckUsername);
  }

  /// Verify OTP and save the token encrypted.
  Future<void> verifyOtp(String duckUsername, String otp) async {
    final token = await _service.verifyOtp(duckUsername, otp);
    final vaultKey = _vaultKeyFromRef(_ref);
    await _service.saveToken(token, vaultKey);
    _ref.invalidate(ddgTokenProvider);
  }

  /// Generate a new @duck.com alias and add it to the session list.
  Future<String> generateAlias() async {
    final token = await _ref.read(ddgTokenProvider.future);
    if (token == null) {
      throw const DdgAuthException('Not authenticated with DuckDuckGo');
    }
    final alias = await _service.generateAlias(token);
    _ref.read(ddgAliasListProvider.notifier).addAlias(alias);
    return alias;
  }

  /// Get dashboard info.
  Future<Map<String, dynamic>> getDashboard() async {
    final token = await _ref.read(ddgTokenProvider.future);
    if (token == null) {
      throw const DdgAuthException('Not authenticated with DuckDuckGo');
    }
    return _service.getDashboard(token);
  }

  /// Log out: remove token and clear alias list.
  Future<void> logout() async {
    await _service.removeToken();
    _ref.read(ddgAliasListProvider.notifier).clear();
    _ref.invalidate(ddgTokenProvider);
  }
}
