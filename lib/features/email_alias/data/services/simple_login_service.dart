// File: lib/features/email_alias/data/services/simple_login_service.dart
// SimpleLogin REST API client for email alias management.
import 'dart:convert';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
import 'package:http/http.dart' as http;

import '../../../../core/crypto/crypto_engine.dart';
import '../../../../core/database/daos/settings_dao.dart';
import '../models/alias_model.dart';

// ---------------------------------------------------------------------------
// Exceptions
// ---------------------------------------------------------------------------

/// Thrown when the API key is invalid (HTTP 401).
class InvalidApiKeyException implements Exception {
  final String message;
  const InvalidApiKeyException(this.message);

  @override
  String toString() => 'InvalidApiKeyException: $message';
}

/// Thrown when the API rate-limits the request (HTTP 429).
class RateLimitException implements Exception {
  final String message;
  const RateLimitException(this.message);

  @override
  String toString() => 'RateLimitException: $message';
}

/// Generic SimpleLogin API error.
class SimpleLoginException implements Exception {
  final String message;
  const SimpleLoginException(this.message);

  @override
  String toString() => 'SimpleLoginException: $message';
}

// ---------------------------------------------------------------------------
// Service
// ---------------------------------------------------------------------------

/// Wraps SimpleLogin REST API endpoints.
///
/// Uses the non-standard `Authentication` header (NOT `Authorization`)
/// as required by the SimpleLogin API specification.
class SimpleLoginService {
  static const _baseUrl = 'https://app.simplelogin.io';
  static const _apiKeySettingsKey = 'simplelogin_api_key';

  final http.Client _client;
  final SettingsDao _settingsDao;
  final CryptoEngine _crypto;

  /// Tracks the last request timestamp for simple rate-limiting.
  DateTime? _lastRequestAt;

  SimpleLoginService(this._client, this._settingsDao, this._crypto);

  // ---- Header helper ----

  Map<String, String> _headers(String apiKey) => {
        'Authentication': apiKey, // SimpleLogin uses "Authentication", NOT "Authorization"
        'Content-Type': 'application/json',
      };

  // ---- API key storage (encrypted) ----

  /// Store the API key encrypted in SettingsDao via CryptoEngine.
  Future<void> saveApiKey(String apiKey, SecretKey vaultKey) async {
    final encrypted = await _crypto.encrypt(
      Uint8List.fromList(utf8.encode(apiKey)),
      vaultKey,
    );
    await _settingsDao.setSetting(_apiKeySettingsKey, base64Encode(encrypted));
  }

  /// Retrieve and decrypt the stored API key. Returns null if not configured.
  Future<String?> getApiKey(SecretKey vaultKey) async {
    final stored = await _settingsDao.getSetting(_apiKeySettingsKey);
    if (stored == null) return null;
    try {
      final decrypted = await _crypto.decrypt(base64Decode(stored), vaultKey);
      return utf8.decode(decrypted);
    } catch (_) {
      // Corrupted or key mismatch -- treat as not configured.
      return null;
    }
  }

  /// Remove the stored API key.
  Future<void> removeApiKey() async {
    await _settingsDao.deleteSetting(_apiKeySettingsKey);
  }

  // ---- Alias endpoints ----

  /// List aliases with pagination (20 per page).
  Future<List<AliasModel>> listAliases(String apiKey, {int pageId = 0}) async {
    await _throttle();
    final response = await _client.get(
      Uri.parse('$_baseUrl/api/v2/aliases?page_id=$pageId'),
      headers: _headers(apiKey),
    );
    _checkResponse(response);
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final aliases = (data['aliases'] as List)
        .map((a) => AliasModel.fromJson(a as Map<String, dynamic>))
        .toList();
    return aliases;
  }

  /// Create a random alias. Optional [note] to annotate the alias.
  Future<AliasModel> createRandomAlias(String apiKey, {String? note}) async {
    await _throttle();
    final response = await _client.post(
      Uri.parse('$_baseUrl/api/alias/random/new'),
      headers: _headers(apiKey),
      body: note != null ? jsonEncode({'note': note}) : null,
    );
    _checkResponse(response, expected: 201);
    return AliasModel.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  /// Get available suffix options for custom alias creation.
  Future<Map<String, dynamic>> getAliasOptions(String apiKey) async {
    await _throttle();
    final response = await _client.get(
      Uri.parse('$_baseUrl/api/v5/alias/options'),
      headers: _headers(apiKey),
    );
    _checkResponse(response);
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  /// Create a custom alias using a prefix and a signed suffix from [getAliasOptions].
  Future<AliasModel> createCustomAlias(
    String apiKey, {
    required String aliasPrefix,
    required String signedSuffix,
    String? note,
  }) async {
    await _throttle();
    final response = await _client.post(
      Uri.parse('$_baseUrl/api/v3/alias/custom/new'),
      headers: _headers(apiKey),
      body: jsonEncode({
        'alias_prefix': aliasPrefix,
        'signed_suffix': signedSuffix,
        if (note != null) 'note': note,
      }),
    );
    _checkResponse(response, expected: 201);
    return AliasModel.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  /// Toggle an alias active/inactive. Returns the new enabled state.
  Future<bool> toggleAlias(String apiKey, int aliasId) async {
    await _throttle();
    final response = await _client.post(
      Uri.parse('$_baseUrl/api/aliases/$aliasId/toggle'),
      headers: _headers(apiKey),
    );
    _checkResponse(response);
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return data['enabled'] as bool;
  }

  /// Delete an alias permanently.
  Future<void> deleteAlias(String apiKey, int aliasId) async {
    await _throttle();
    final response = await _client.delete(
      Uri.parse('$_baseUrl/api/aliases/$aliasId'),
      headers: _headers(apiKey),
    );
    _checkResponse(response);
  }

  // ---- Internals ----

  /// Simple defensive rate-limiter: wait if less than 1 second since last call.
  Future<void> _throttle() async {
    if (_lastRequestAt != null) {
      final elapsed = DateTime.now().difference(_lastRequestAt!);
      if (elapsed < const Duration(seconds: 1)) {
        await Future<void>.delayed(const Duration(seconds: 1) - elapsed);
      }
    }
    _lastRequestAt = DateTime.now();
  }

  /// Validate the HTTP response. Throws typed exceptions on error.
  void _checkResponse(http.Response response, {int expected = 200}) {
    if (response.statusCode == 401) {
      throw const InvalidApiKeyException('Invalid SimpleLogin API key');
    }
    if (response.statusCode == 429) {
      throw const RateLimitException('Rate limited. Try again later.');
    }
    if (response.statusCode != expected) {
      throw SimpleLoginException(
        'API error: ${response.statusCode} ${response.body}',
      );
    }
  }
}
