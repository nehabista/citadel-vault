// File: test/unit/state/session_state_test.dart
import 'dart:typed_data';

import 'package:citadel_password_manager/core/providers/session_provider.dart';
import 'package:citadel_password_manager/core/session/session_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SessionState sealed class', () {
    test('Locked is a valid SessionState', () {
      const state = Locked();
      expect(state, isA<SessionState>());
      expect(state, isA<Locked>());
    });

    test('Unlocked requires vaultKey and unlockedAt', () {
      final key = Uint8List.fromList(List.filled(32, 0xAB));
      final now = DateTime.now();
      final state = Unlocked(vaultKey: key, unlockedAt: now);
      expect(state, isA<SessionState>());
      expect(state, isA<Unlocked>());
      expect(state.vaultKey, key);
      expect(state.unlockedAt, now);
    });

    test('Exhaustive switch covers both Locked and Unlocked', () {
      SessionState state = const Locked();
      String result = switch (state) {
        Locked() => 'locked',
        Unlocked() => 'unlocked',
      };
      expect(result, 'locked');

      state = Unlocked(
        vaultKey: Uint8List(32),
        unlockedAt: DateTime.now(),
      );
      result = switch (state) {
        Locked() => 'locked',
        Unlocked() => 'unlocked',
      };
      expect(result, 'unlocked');
    });
  });

  group('SessionNotifier', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('starts in Locked state', () {
      final state = container.read(sessionProvider);
      expect(state, isA<Locked>());
    });

    test('a provider using exhaustive switch throws when Locked', () {
      final state = container.read(sessionProvider);
      expect(
        () => switch (state) {
          Locked() => throw const VaultLockedException(),
          Unlocked(:final vaultKey) => vaultKey,
        },
        throwsA(isA<VaultLockedException>()),
      );
    });
  });
}
