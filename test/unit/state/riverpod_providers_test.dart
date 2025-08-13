// File: test/unit/state/riverpod_providers_test.dart
// Tests that Riverpod providers are properly wired and no GetX remains
import 'dart:io';

import 'package:citadel_password_manager/core/crypto/crypto_engine.dart';
import 'package:citadel_password_manager/core/providers/core_providers.dart';
import 'package:citadel_password_manager/core/providers/session_provider.dart';
import 'package:citadel_password_manager/core/session/session_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Riverpod providers', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('cryptoEngineProvider returns a CryptoEngine instance', () {
      final crypto = container.read(cryptoEngineProvider);
      expect(crypto, isA<CryptoEngine>());
    });

    test('sessionProvider starts as Locked', () {
      final state = container.read(sessionProvider);
      expect(state, isA<Locked>());
    });

    test('encryptionServiceProvider returns an EncryptionService', () {
      final encryption = container.read(encryptionServiceProvider);
      expect(encryption, isNotNull);
    });

    test('sessionServiceProvider returns a SessionService', () {
      final session = container.read(sessionServiceProvider);
      expect(session, isNotNull);
      expect(session.isVaultUnlocked, false);
    });
  });

  group('Meta: no GetX imports', () {
    test('no GetX imports exist in lib/', () {
      final libDir = Directory('lib');
      if (!libDir.existsSync()) return; // Skip if running from different cwd

      final dartFiles = libDir
          .listSync(recursive: true)
          .whereType<File>()
          .where((f) => f.path.endsWith('.dart'));

      for (final file in dartFiles) {
        final contents = file.readAsStringSync();
        expect(
          contents.contains("import 'package:get/"),
          false,
          reason: '${file.path} still imports GetX',
        );
        expect(
          contents.contains('import "package:get/'),
          false,
          reason: '${file.path} still imports GetX',
        );
        expect(
          contents.contains("import 'package:velocity_x/"),
          false,
          reason: '${file.path} still imports velocity_x',
        );
        expect(
          contents.contains("import 'package:sizer/"),
          false,
          reason: '${file.path} still imports sizer',
        );
      }
    });
  });
}
