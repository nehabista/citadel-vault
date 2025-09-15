// File: test/unit/auth/session_lifecycle_test.dart
// Tests AppLifecycleObserver and lock/unlock cycle
import 'dart:convert';
import 'dart:typed_data';

import 'package:citadel_password_manager/core/crypto/crypto_engine.dart';
import 'package:citadel_password_manager/core/providers/core_providers.dart';
import 'package:citadel_password_manager/core/providers/session_provider.dart';
import 'package:citadel_password_manager/core/session/session_state.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppLifecycleObserver', () {
    late ProviderContainer container;
    late SessionNotifier notifier;
    late CryptoEngine crypto;
    late String testSalt;

    setUp(() {
      container = ProviderContainer();
      notifier = container.read(sessionProvider.notifier);
      crypto = container.read(cryptoEngineProvider);
      testSalt = base64.encode(crypto.generateSalt());
    });

    tearDown(() {
      container.dispose();
    });

    test('lock() is called on AppLifecycleState.paused', () async {
      // First unlock
      await notifier.unlock('test-password', testSalt);
      expect(container.read(sessionProvider), isA<Unlocked>());

      // Simulate paused
      final observer = AppLifecycleObserver(notifier);
      observer.didChangeAppLifecycleState(AppLifecycleState.paused);

      expect(container.read(sessionProvider), isA<Locked>());
    });

    test('after lock, re-unlock restores Unlocked state', () async {
      const password = 'test-password-lifecycle';

      // Unlock -> Lock -> Unlock cycle
      await notifier.unlock(password, testSalt);
      expect(container.read(sessionProvider), isA<Unlocked>());

      notifier.lock();
      expect(container.read(sessionProvider), isA<Locked>());

      await notifier.unlock(password, testSalt);
      final state = container.read(sessionProvider);
      expect(state, isA<Unlocked>());
      expect((state as Unlocked).vaultKey.length, 32);
    });

    test('does not lock on other lifecycle states', () async {
      await notifier.unlock('test-password', testSalt);
      final observer = AppLifecycleObserver(notifier);

      observer.didChangeAppLifecycleState(AppLifecycleState.resumed);
      expect(container.read(sessionProvider), isA<Unlocked>());

      observer.didChangeAppLifecycleState(AppLifecycleState.inactive);
      expect(container.read(sessionProvider), isA<Unlocked>());
    });
  });
}
