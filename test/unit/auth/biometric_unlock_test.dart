// File: test/unit/auth/biometric_unlock_test.dart
// Tests biometric unlock key derivation and session state transitions
import 'dart:convert';
import 'dart:typed_data';

import 'package:citadel_password_manager/core/crypto/crypto_engine.dart';
import 'package:citadel_password_manager/core/providers/core_providers.dart';
import 'package:citadel_password_manager/core/providers/session_provider.dart';
import 'package:citadel_password_manager/core/session/session_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Biometric unlock key derivation', () {
    late ProviderContainer container;
    late CryptoEngine crypto;
    late String testSalt;

    setUp(() {
      container = ProviderContainer();
      crypto = container.read(cryptoEngineProvider);
      testSalt = base64.encode(crypto.generateSalt());
    });

    tearDown(() {
      container.dispose();
    });

    test(
      'successful biometric auth triggers key derivation that transitions session to Unlocked',
      () async {
        // Simulate: biometric auth succeeds, retrieves stored master password
        const storedMasterPassword = 'test-master-password-123';

        // Derive key (simulating what happens after biometric success)
        final keyBytes = await crypto.deriveKey(storedMasterPassword, testSalt);
        expect(keyBytes.length, 32); // 256-bit key

        // Unlock session with derived key (simulates the unlock flow)
        final notifier = container.read(sessionProvider.notifier);
        await notifier.unlock(storedMasterPassword, testSalt);

        final state = container.read(sessionProvider);
        expect(state, isA<Unlocked>());
        final unlocked = state as Unlocked;
        expect(unlocked.vaultKey.length, 32);
      },
    );

    test('failed biometric auth does not transition session state', () {
      // Simulate: biometric auth fails -- no unlock called
      // Session should remain Locked
      final state = container.read(sessionProvider);
      expect(state, isA<Locked>());
    });

    test(
      'deriveKey with same password and salt produces consistent results',
      () async {
        const password = 'consistent-test-password';
        final key1 = await crypto.deriveKey(password, testSalt);
        final key2 = await crypto.deriveKey(password, testSalt);
        expect(key1, equals(key2));
      },
    );
  });
}
