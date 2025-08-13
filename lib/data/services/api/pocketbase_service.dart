// File: lib/data/services/api/pocketbase_service.dart
import 'dart:async';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pocketbase/pocketbase.dart';

/// Manages the PocketBase client instance and its authentication store.
/// Plain Dart class -- no GetX dependency.
class PocketBaseService {
  PocketBase? _client;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  static const _authStoreKey = 'pb_auth';

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
      'https://citadelpasswordmanager.pockethost.io',
      authStore: store,
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
