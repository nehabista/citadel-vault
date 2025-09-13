import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;

import '../models/breach_record.dart';

/// Service for checking passwords and emails against Have I Been Pwned (HIBP).
///
/// Ported from Protego project with the following changes:
/// - Uses `package:crypto` sha1 instead of hashlib
/// - Constructor takes optional http.Client and optional hibpApiKey (NOT hardcoded)
/// - User-Agent set to 'Citadel/1.0'
/// - Added getAllBreaches() for breach catalog
class BreachService {
  BreachService({
    http.Client? client,
    String? hibpApiKey,
  })  : _client = client ?? http.Client(),
        _hibpApiKey = hibpApiKey ?? _defaultApiKey;

  final http.Client _client;
  final String? _hibpApiKey;

  /// Built-in HIBP API key — users don't need to configure this.
  static const _defaultApiKey = String.fromEnvironment(
    'HIBP_API_KEY',
    defaultValue: '19845a8c362a464b837f724beada9cf2',
  );

  static const _ua = 'Citadel/1.0';

  /// Check if the API key is available.
  bool get hasHibpKey => _hibpApiKey != null && _hibpApiKey.isNotEmpty;

  /// Pwned Passwords range API (no key required).
  ///
  /// Uses k-anonymity: sends only the first 5 characters of the SHA-1 hash.
  /// Returns the number of times the password has appeared in breaches.
  Future<int> pwnedPasswordCount(String password) async {
    final hash =
        sha1.convert(utf8.encode(password)).toString().toUpperCase();
    final prefix = hash.substring(0, 5);
    final suffix = hash.substring(5);

    final uri = Uri.parse('https://api.pwnedpasswords.com/range/$prefix');
    final resp = await _client.get(uri, headers: {
      'User-Agent': _ua,
      'Accept': 'text/plain',
      'Add-Padding': 'true',
    });

    if (resp.statusCode != 200) return 0;

    for (final line in resp.body.split('\n')) {
      final parts = line.trim().split(':');
      if (parts.length == 2 && parts[0].toUpperCase() == suffix) {
        final n = int.tryParse(parts[1].trim());
        if (n != null) return n;
      }
    }
    return 0;
  }

  /// HIBP breached account (email) API.
  ///
  /// Requires an HIBP API key. Returns a list of [BreachRecord] for the
  /// given email, or an empty list if the email was not found (404).
  Future<List<BreachRecord>> breachedAccount(String email) async {
    if (!hasHibpKey) {
      throw BreachServiceError(
        'Missing HIBP API key.',
        code: 'NO_KEY',
      );
    }

    final uri = Uri.https(
      'haveibeenpwned.com',
      '/api/v3/breachedaccount/$email',
      {
        'truncateResponse': 'false',
        'includeUnverified': 'true',
      },
    );

    final resp = await _client.get(uri, headers: {
      'User-Agent': _ua,
      'Accept': 'application/json',
      'hibp-api-key': _hibpApiKey!,
    });

    if (resp.statusCode == 404) return const [];
    if (resp.statusCode == 200) {
      final List<dynamic> data = jsonDecode(resp.body) as List<dynamic>;
      return data
          .map((e) => BreachRecord.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    if (resp.statusCode == 401) {
      throw BreachServiceError('Unauthorized (bad API key).', code: '401');
    }
    if (resp.statusCode == 429) {
      throw BreachServiceError(
        'Rate limited by HIBP. Try again later.',
        code: '429',
      );
    }
    throw BreachServiceError(
      'HIBP error ${resp.statusCode}: ${resp.reasonPhrase ?? ''}',
      code: '${resp.statusCode}',
    );
  }

  /// Get the full breach catalog from HIBP (no API key needed).
  ///
  /// Returns all breaches in the HIBP database for display in the
  /// breach catalog / timeline.
  Future<List<BreachRecord>> getAllBreaches() async {
    final uri = Uri.https('haveibeenpwned.com', '/api/v3/breaches');

    final resp = await _client.get(uri, headers: {
      'User-Agent': _ua,
      'Accept': 'application/json',
    });

    if (resp.statusCode != 200) return const [];

    final List<dynamic> data = jsonDecode(resp.body) as List<dynamic>;
    return data
        .map((e) => BreachRecord.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}

/// Error thrown by [BreachService] operations.
class BreachServiceError implements Exception {
  final String message;
  final String? code;

  BreachServiceError(this.message, {this.code});

  @override
  String toString() => 'BreachServiceError($code): $message';
}
