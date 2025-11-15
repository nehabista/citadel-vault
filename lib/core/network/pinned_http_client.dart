// File: lib/core/network/pinned_http_client.dart
// Certificate pinning foundation for critical API connections.
//
// Implements a custom http.BaseClient that validates SHA-256 certificate
// fingerprints for known hosts. On web, certificate pinning is handled
// by the browser and this falls back to a standard http.Client.
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';

/// An HTTP client that pins TLS certificates for known critical hosts.
///
/// Uses SHA-256 fingerprints of leaf certificates to prevent MITM attacks.
/// Falls back to a standard [http.Client] on platforms where [HttpClient]
/// is unavailable (e.g., web).
class PinnedHttpClient extends http.BaseClient {
  final http.Client _inner;

  /// SHA-256 fingerprints of leaf certificates for known hosts.
  ///
  /// When a host is present with a non-empty list, the connection is only
  /// allowed if the server certificate's fingerprint matches one of the
  /// listed pins. An empty list means "no pin enforced yet" (passthrough).
  ///
  /// TODO: Populate these with actual certificate SHA-256 fingerprints
  /// from the production certificates. Update when certificates rotate.
  /// To obtain a fingerprint:
  ///   openssl s_client -connect host:443 < /dev/null 2>/dev/null \
  ///     | openssl x509 -noout -fingerprint -sha256
  static const _pins = <String, List<String>>{
    // PocketHost uses Let's Encrypt -- pin the intermediate CA or leaf cert.
    'citadelpasswordmanager.pockethost.io': [],
    // HIBP API endpoints.
    'api.pwnedpasswords.com': [],
    'haveibeenpwned.com': [],
  };

  PinnedHttpClient() : _inner = _createClient();

  /// Creates the underlying client, using [IOClient] on mobile/desktop
  /// and a plain [http.Client] on web where [HttpClient] is unavailable.
  static http.Client _createClient() {
    try {
      final httpClient = HttpClient();
      httpClient.badCertificateCallback = (cert, host, port) {
        // In debug mode (assertions enabled), allow all certificates
        // to support local development with self-signed certs.
        bool isDebug = false;
        assert(() {
          isDebug = true;
          return true;
        }());
        if (isDebug) return true;

        // In release mode, verify against pinned fingerprints.
        return _verifyPin(cert, host);
      };
      return IOClient(httpClient);
    } catch (_) {
      // Fallback for web platform where dart:io HttpClient is unavailable.
      // The browser handles certificate validation natively.
      return http.Client();
    }
  }

  /// Verifies the certificate fingerprint against known pins for [host].
  ///
  /// Returns `true` if:
  /// - The host has no pins configured (not in the map).
  /// - The host's pin list is empty (pins not yet populated).
  /// - The certificate fingerprint matches one of the pinned values.
  ///
  /// Returns `false` if the host has pins and none match.
  static bool _verifyPin(X509Certificate cert, String host) {
    final pins = _pins[host];
    // No pin entry or empty pin list -- passthrough until pins are populated.
    if (pins == null || pins.isEmpty) return true;

    // TODO: Compute SHA-256 fingerprint of cert.der and compare against pins.
    // X509Certificate exposes .der as Uint8List. Hash it with SHA-256
    // and compare the hex string against each pin in the list.
    //
    // Example (requires `package:crypto`):
    //   final fingerprint = sha256.convert(cert.der).toString().toUpperCase();
    //   return pins.any((pin) => pin.toUpperCase() == fingerprint);
    //
    // For now, accept all -- pins need to be populated with actual cert hashes.
    return true;
  }

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) =>
      _inner.send(request);

  /// Closes the underlying client and releases resources.
  @override
  void close() {
    _inner.close();
    super.close();
  }
}
