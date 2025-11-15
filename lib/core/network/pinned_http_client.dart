// File: lib/core/network/pinned_http_client.dart
// Production certificate pinning infrastructure for Citadel.
//
// Uses smart_dev_pinning_plugin for native TLS pinning (Android: Rust/OpenSSL,
// iOS/macOS: Swift/URLSession) and http_certificate_guard for MITM detection.
//
// Supports: Android, iOS, macOS. Web uses standard browser TLS (no pinning).

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http_certificate_guard/http_certificate_guard.dart';
import 'package:smart_dev_pinning_plugin/smart_dev_pinning_plugin.dart';

/// Certificate pin configuration for all Citadel API hosts.
///
/// Uses intermediate CA public key pinning (most stable — survives leaf cert
/// renewals). Intermediate CAs typically rotate every 5-10 years.
///
/// Generated with:
/// ```bash
/// openssl s_client -showcerts -connect HOST:443 | awk '/BEGIN/{n++}{if(n==2)print}' \
///   | openssl x509 -pubkey -noout | openssl pkey -pubin -outform DER \
///   | openssl dgst -sha256 -binary | openssl base64
/// ```
///
/// Last updated: 2026-04-04
class CertificatePins {
  CertificatePins._();

  // --- Intermediate CA Public Key Hashes (base64 SHA-256) ---

  /// PocketBase server (Let's Encrypt intermediate)
  static const pocketBase = 'kIdp6NNEd8wsugYyyIYFsi1ylMCED3hZbSR8ZFsa/A4=';

  /// HIBP Pwned Passwords API (Let's Encrypt intermediate)
  static const hibpPasswords = 'kIdp6NNEd8wsugYyyIYFsi1ylMCED3hZbSR8ZFsa/A4=';

  /// HIBP Breached Accounts API (Let's Encrypt intermediate)
  static const hibpBreaches = 'kIdp6NNEd8wsugYyyIYFsi1ylMCED3hZbSR8ZFsa/A4=';

  /// SimpleLogin API
  static const simpleLogin = 'kZwN96eHtZftBWrOZUsd6cA4es80n3NzSk/XtYz2EqQ=';

  /// DuckDuckGo Email API
  static const duckDuckGo = 'y7xVm0TVJNahMr2sZydE2jQH8SquXV9yLF9seROHHHU=';

  // --- Leaf Public Key Hashes (backup pins) ---

  static const pocketBaseLeaf =
      'quPO8prc2z1uE0Y59UWPP/kxVClZc7V6oZX9uowhBoM=';
  static const hibpPasswordsLeaf =
      '6WsuVtJmHGRHn8SSL7aCkihwAnNRIH1dM3RQwAEGRPQ=';
  static const hibpBreachesLeaf =
      'hEY7d9e51KKlRcYp7Ujh1Fd1XwnDhwuVjcc7izACoRg=';
  static const simpleLoginLeaf =
      'aGuv5gvSw+1dIVYbUDe3GA8Yl+ng/RdizgTArlOBj5k=';
  static const duckDuckGoLeaf =
      'nyLq8KBcSIoJmw/3QII7v7okmcY32tEzQ4yypOCOyU8=';

  /// All pins grouped by host for lookup.
  static const hostPins = <String, List<String>>{
    'citadelpasswordmanager.pockethost.io': [pocketBase, pocketBaseLeaf],
    'api.pwnedpasswords.com': [hibpPasswords, hibpPasswordsLeaf],
    'haveibeenpwned.com': [hibpBreaches, hibpBreachesLeaf],
    'app.simplelogin.io': [simpleLogin, simpleLoginLeaf],
    'quack.duckduckgo.com': [duckDuckGo, duckDuckGoLeaf],
  };
}

/// Secure HTTP client with certificate pinning and MITM detection.
///
/// On native platforms (Android/iOS/macOS):
/// 1. Checks for MITM proxies via http_certificate_guard
/// 2. Validates certificate pins via smart_dev_pinning_plugin
/// 3. Falls back to standard http.Client if pinning is unavailable
///
/// On web: uses standard browser TLS (pinning not applicable).
class CertificatePinningService {
  CertificatePinningService._();

  static final _secureClient = SecureClient();

  /// Perform a pinned HTTP request.
  ///
  /// Throws [CertificatePinningException] if:
  /// - MITM proxy detected (pre-request check)
  /// - Certificate pin mismatch (TLS handshake)
  static Future<PinnedResponse> request({
    required String url,
    required String method,
    Map<String, String>? headers,
    Object? body,
  }) async {
    if (kIsWeb) return _fallbackRequest(url, method, headers, body);

    final uri = Uri.parse(url);
    final host = uri.host;
    final pins = CertificatePins.hostPins[host];

    if (pins == null || pins.isEmpty) {
      return _fallbackRequest(url, method, headers, body);
    }

    // Step 1: MITM detection
    try {
      await HttpCertificateGuard.check(uri);
    } catch (e) {
      throw CertificatePinningException(
        'Connection blocked: MITM proxy detected on $host',
        type: PinningFailureType.mitmDetected,
      );
    }

    // Step 2: Pinned request via native TLS
    try {
      final response = await _secureClient.httpRequest(
        certificateHashes: pins,
        method: method.toUpperCase(),
        url: url,
        headers: headers ?? {},
        body: body != null ? (body is String ? body : jsonEncode(body)) : null,
        pinningMethod: PinningMethod.publicKey,
      );

      if (response.success) {
        return PinnedResponse(
          statusCode: response.statusCode ?? 200,
          body: response.data ?? '',
          pinned: true,
        );
      }

      if (response.errorType == 'SSLPinningError' ||
          response.errorType == 'ConnectionError') {
        throw CertificatePinningException(
          'Certificate pin mismatch for $host',
          type: PinningFailureType.pinMismatch,
        );
      }

      return PinnedResponse(
        statusCode: response.statusCode ?? 500,
        body: response.data ?? response.error ?? '',
        pinned: true,
      );
    } catch (e) {
      if (e is CertificatePinningException) rethrow;
      return _fallbackRequest(url, method, headers, body);
    }
  }

  static Future<PinnedResponse> _fallbackRequest(
    String url,
    String method,
    Map<String, String>? headers,
    Object? body,
  ) async {
    final uri = Uri.parse(url);
    final client = http.Client();
    try {
      final http.Response response;
      switch (method.toUpperCase()) {
        case 'GET':
          response = await client.get(uri, headers: headers);
        case 'POST':
          response = await client.post(uri, headers: headers, body: body);
        case 'PATCH':
          response = await client.patch(uri, headers: headers, body: body);
        case 'PUT':
          response = await client.put(uri, headers: headers, body: body);
        case 'DELETE':
          response = await client.delete(uri, headers: headers);
        default:
          response = await client.get(uri, headers: headers);
      }
      return PinnedResponse(
        statusCode: response.statusCode,
        body: response.body,
        pinned: false,
      );
    } finally {
      client.close();
    }
  }
}

/// Response from a pinned HTTP request.
class PinnedResponse {
  final int statusCode;
  final String body;
  final bool pinned;

  const PinnedResponse({
    required this.statusCode,
    required this.body,
    required this.pinned,
  });

  bool get isSuccess => statusCode >= 200 && statusCode < 300;
}

/// Exception thrown when certificate pinning validation fails.
class CertificatePinningException implements Exception {
  final String message;
  final PinningFailureType type;

  const CertificatePinningException(this.message, {required this.type});

  @override
  String toString() => 'CertificatePinningException($type): $message';
}

/// Types of certificate pinning failures.
enum PinningFailureType {
  mitmDetected,
  pinMismatch,
  connectionRefused,
}
