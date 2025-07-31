import 'dart:async';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:pocketbase/pocketbase.dart';

/// Manages the PocketBase client instance and its authentication store.
/// This service is responsible for initializing the client with a secure,
/// persistent authentication store to keep the user logged in across app launches.
class PocketBaseService extends GetxService {
  PocketBase? _client;

  PocketBase get client {
    if (_client == null) {
      throw Exception("PocketBase client was accessed before initialization.");
    }
    return _client!;
  }

  set client(PocketBase value) {
    _client = value;
  }

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  static const _authStoreKey = 'pb_auth';

  /// A reactive stream that emits the current authentication status.
  /// The UI and controllers can listen to this to reactively handle
  /// login/logout events.
  Stream<AuthStoreEvent> get authState => client.authStore.onChange;

  @override
  Future<void> onInit() async {
    super.onInit();
    await _initClient();
  }

  Future<PocketBaseService> init() async {
    final store = AsyncAuthStore(
      save:
          (data) async => _secureStorage.write(key: _authStoreKey, value: data),
      initial: await _secureStorage.read(key: _authStoreKey),
      clear: () async => _secureStorage.delete(key: _authStoreKey),
    );

    client = PocketBase(
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

  /// Initializes the PocketBase client with a custom secure [AsyncAuthStore].
  Future<void> _initClient() async {
    // 1. Initialize the custom, secure AuthStore.
    // This uses flutter_secure_storage to save the session token securely
    // on the device's Keychain (iOS) or Keystore (Android).
    final store = AsyncAuthStore(
      save:
          (String data) async =>
              _secureStorage.write(key: _authStoreKey, value: data),
      initial: await _secureStorage.read(key: _authStoreKey),
      clear: () async => _secureStorage.delete(key: _authStoreKey),
    );

    // 2. Initialize the PocketBase client with your URL and the custom store.
    client = PocketBase(
      'https://citadelpasswordmanager.pockethost.io',
      authStore: store,
    );

    // 3. Automatically refresh the token on startup if it's valid.
    // This extends the session and keeps the user logged in without them
    // needing to re-enter their password every time they open the app.
    if (client.authStore.isValid) {
      try {
        await client.collection('users').authRefresh();
      } catch (_) {
        // If refresh fails (e.g., token expired, network error),
        // clear the store to log the user out.
        client.authStore.clear();
      }
    }
  }
}
