// File: lib/features/email_alias/data/services/duckduckgo_alias_service.dart
// DuckDuckGo Email Protection API client for @duck.com alias management.
import 'dart:convert';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
import 'package:http/http.dart' as http;

import '../../../../core/crypto/crypto_engine.dart';
import '../../../../core/database/daos/settings_dao.dart';

// ---------------------------------------------------------------------------
// Exceptions
// ---------------------------------------------------------------------------

/// Thrown when DDG authentication fails.
class DdgAuthException implements Exception {
  final String message;
  const DdgAuthException(this.message);

  @override
  String toString() => 'DdgAuthException: $message';
}

/// Generic DuckDuckGo API error.
class DdgApiException implements Exception {
  final String message;
  final int? statusCode;
  const DdgApiException(this.message, {this.statusCode});

  @override
  String toString() => 'DdgApiException($statusCode): $message';
}

// ---------------------------------------------------------------------------
// Service
// ---------------------------------------------------------------------------

/// Wraps DuckDuckGo Email Protection API endpoints.
///
/// API based on the Qwacky open-source project:
/// - OTP-based auth flow (no password)
/// - Generate random @duck.com aliases
/// - Dashboard info
class DuckDuckGoAliasService {
  static const _baseUrl = 'https://quack.duckduckgo.com';
  // Real DuckDuckGo browser headers — DDG API rejects non-DDG user agents
  static const _userAgent =
      'Mozilla/5.0 (iPhone; CPU iPhone OS 18_6 like Mac OS X) '
      'AppleWebKit/605.1.15 (KHTML, like Gecko) '
      'Version/26.3 Mobile/15E148 DuckDuckGo/7 Safari/605.1.15';
  static const _tokenSettingsKey = 'ddg_email_token';

  final http.Client _client;
  final SettingsDao _settingsDao;
  final CryptoEngine _crypto;

  DuckDuckGoAliasService(this._client, this._settingsDao, this._crypto);

  // ---- Header helpers ----

  Map<String, String> _baseHeaders() => {
        'User-Agent': _userAgent,
        'Accept': '*/*',
        'Accept-Language': 'en-AU,en;q=0.9',
        'Accept-Encoding': 'gzip, deflate, br',
        'Origin': 'https://duckduckgo.com',
        'Referer': 'https://duckduckgo.com/',
        'Sec-Fetch-Site': 'same-site',
        'Sec-Fetch-Mode': 'cors',
        'Sec-Fetch-Dest': 'empty',
        'Content-Type': 'application/json',
      };

  Map<String, String> _authHeaders(String token) => {
        ..._baseHeaders(),
        'Authorization': 'Bearer $token',
      };

  // ---- Token storage (encrypted) ----

  /// Store the bearer token encrypted in SettingsDao via CryptoEngine.
  Future<void> saveToken(String token, SecretKey vaultKey) async {
    final encrypted = await _crypto.encrypt(
      Uint8List.fromList(utf8.encode(token)),
      vaultKey,
    );
    await _settingsDao.setSetting(_tokenSettingsKey, base64Encode(encrypted));
  }

  /// Retrieve and decrypt the stored bearer token. Returns null if not stored.
  Future<String?> getToken(SecretKey vaultKey) async {
    final stored = await _settingsDao.getSetting(_tokenSettingsKey);
    if (stored == null) return null;
    try {
      final decrypted =
          await _crypto.decrypt(base64Decode(stored), vaultKey);
      return utf8.decode(decrypted);
    } catch (_) {
      // Corrupted or key mismatch -- treat as not configured.
      return null;
    }
  }

  /// Remove the stored token.
  Future<void> removeToken() async {
    await _settingsDao.deleteSetting(_tokenSettingsKey);
  }

  // ---- Auth flow ----

  /// Request an OTP email for the given duck.com username.
  ///
  /// The [duckUsername] should be the part before @duck.com (e.g. "john").
  /// DuckDuckGo will send an OTP to the user's associated email.
  Future<void> requestOtp(String duckUsername) async {
    final uri = Uri.parse('$_baseUrl/api/auth/loginlink')
        .replace(queryParameters: {'user': duckUsername});
    final response = await _client.get(uri, headers: _baseHeaders());

    if (response.statusCode != 200) {
      throw DdgApiException(
        'Failed to request OTP: ${response.body}',
        statusCode: response.statusCode,
      );
    }
  }

  /// Verify the OTP and retrieve a bearer token.
  ///
  /// Returns the bearer token string on success.
  Future<String> verifyOtp(String duckUsername, String otp) async {
    final uri = Uri.parse('$_baseUrl/api/auth/login').replace(
      queryParameters: {'user': duckUsername, 'otp': otp},
    );
    final response = await _client.get(uri, headers: _baseHeaders());

    if (response.statusCode == 401) {
      throw const DdgAuthException('Invalid OTP or username');
    }
    if (response.statusCode != 200) {
      throw DdgApiException(
        'OTP verification failed: ${response.body}',
        statusCode: response.statusCode,
      );
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final token = data['token'] as String?;
    if (token == null || token.isEmpty) {
      throw const DdgApiException('No token in response');
    }
    return token;
  }

  // ---- Authenticated endpoints ----

  /// Fetch account dashboard info (stats, settings, etc.).
  Future<Map<String, dynamic>> getDashboard(String token) async {
    final response = await _client.get(
      Uri.parse('$_baseUrl/api/email/dashboard'),
      headers: _authHeaders(token),
    );
    _checkAuth(response);

    if (response.statusCode != 200) {
      throw DdgApiException(
        'Dashboard request failed: ${response.body}',
        statusCode: response.statusCode,
      );
    }

    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  /// Generate a new random @duck.com alias.
  ///
  /// Returns the full alias email (e.g. "random-words@duck.com").
  Future<String> generateAlias(String token) async {
    final response = await _client.post(
      Uri.parse('$_baseUrl/api/email/addresses'),
      headers: _authHeaders(token),
    );
    _checkAuth(response);

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw DdgApiException(
        'Alias generation failed: ${response.body}',
        statusCode: response.statusCode,
      );
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final address = data['address'] as String?;
    if (address == null || address.isEmpty) {
      throw const DdgApiException('No address in response');
    }
    return '$address@duck.com';
  }

  // ---- Internals ----

  /// Check for authentication errors.
  void _checkAuth(http.Response response) {
    if (response.statusCode == 401) {
      throw const DdgAuthException('Token expired or invalid');
    }
  }
}
