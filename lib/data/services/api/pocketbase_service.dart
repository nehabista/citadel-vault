// File: lib/data/services/api/pocketbase_service.dart
import 'dart:async';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:pocketbase/pocketbase.dart';

/// HTTP client wrapper that injects security headers on every request.
///
/// - `X-Content-Type-Options: nosniff` — prevents MIME-type sniffing attacks.
/// - `Cache-Control: no-store` — ensures sensitive responses are never cached.
class _SecureHttpClient extends http.BaseClient {
  final http.Client _inner;

  _SecureHttpClient([http.Client? inner]) : _inner = inner ?? http.Client();

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers['X-Content-Type-Options'] = 'nosniff';
    request.headers['Cache-Control'] = 'no-store';
    return _inner.send(request);
  }

  @override
  void close() => _inner.close();
}

/// Manages the PocketBase client instance and its authentication store.
/// Plain Dart class -- no GetX dependency.
class PocketBaseService {
  PocketBase? _client;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  static const _authStoreKey = 'pb_auth';

  /// PocketBase server URL, configurable at build time via:
  ///   `--dart-define=POCKETBASE_URL=https://your-server.example.com`
  ///
  /// Falls back to the production PocketHost URL if not specified.
  static const _baseUrl = String.fromEnvironment(
    'POCKETBASE_URL',
    defaultValue: 'https://citadelpasswordmanager.pockethost.io',
  );

  PocketBase get client {
    if (_client == null) {
      throw Exception("PocketBase client was accessed before initialization.");
    }
    return _client!;
  }

  Stream<AuthStoreEvent> get authState => client.authStore.onChange;

  Future<PocketBaseService> init() async {
    final store = AsyncAuthStore(
      save: (data) async =>
          _secureStorage.write(key: _authStoreKey, value: data),
      initial: await _secureStorage.read(key: _authStoreKey),
      clear: () async => _secureStorage.delete(key: _authStoreKey),
    );

    _client = PocketBase(
      _baseUrl,
      authStore: store,
      httpClientFactory: () => _SecureHttpClient(),
    );

    if (client.authStore.isValid) {
      try {
        await client.collection('users').authRefresh();
      } catch (_) {
        client.authStore.clear();
      }
    }

    return this;
  }
}
