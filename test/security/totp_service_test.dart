import 'package:flutter_test/flutter_test.dart';
import 'package:citadel_password_manager/features/security/data/services/totp_service.dart';
import 'package:citadel_password_manager/features/security/data/models/otp_auth_uri.dart';

void main() {
  late TotpService totpService;

  setUp(() {
    totpService = TotpService();
  });

  group('TotpService.generateCode', () {
    test('generates a 6-digit code with known base32 secret', () {
      // JBSWY3DPEHPK3PXP is a well-known test secret
      final code = totpService.generateCode(
        base32Secret: 'JBSWY3DPEHPK3PXP',
      );

      expect(code, hasLength(6));
      expect(int.tryParse(code), isNotNull);
    });

    test('generates an 8-digit code when digits=8', () {
      final code = totpService.generateCode(
        base32Secret: 'JBSWY3DPEHPK3PXP',
        digits: 8,
      );

      expect(code, hasLength(8));
      expect(int.tryParse(code), isNotNull);
    });

    test('generates code with SHA256 algorithm', () {
      final code = totpService.generateCode(
        base32Secret: 'JBSWY3DPEHPK3PXP',
        algorithm: 'SHA256',
      );

      expect(code, hasLength(6));
      expect(int.tryParse(code), isNotNull);
    });

    test('generates code with SHA512 algorithm', () {
      final code = totpService.generateCode(
        base32Secret: 'JBSWY3DPEHPK3PXP',
        algorithm: 'SHA512',
      );

      expect(code, hasLength(6));
      expect(int.tryParse(code), isNotNull);
    });
  });

  group('TotpService.remainingSeconds', () {
    test('returns value between 1 and period (30)', () {
      final remaining = totpService.remainingSeconds();

      expect(remaining, greaterThan(0));
      expect(remaining, lessThanOrEqualTo(30));
    });

    test('returns value between 1 and custom period (60)', () {
      final remaining = totpService.remainingSeconds(period: 60);

      expect(remaining, greaterThan(0));
      expect(remaining, lessThanOrEqualTo(60));
    });
  });

  group('OtpAuthUri.parse', () {
    test('parses valid otpauth://totp/ URI with all fields', () {
      const uri =
          'otpauth://totp/Example:alice@example.com?secret=JBSWY3DPEHPK3PXP&issuer=Example&algorithm=SHA256&digits=8&period=60';

      final parsed = OtpAuthUri.parse(uri);

      expect(parsed.secret, 'JBSWY3DPEHPK3PXP');
      expect(parsed.issuer, 'Example');
      expect(parsed.label, 'Example:alice@example.com');
      expect(parsed.algorithm, 'SHA256');
      expect(parsed.digits, 8);
      expect(parsed.period, 60);
    });

    test('uses defaults for missing optional fields', () {
      const uri = 'otpauth://totp/MyApp?secret=JBSWY3DPEHPK3PXP';

      final parsed = OtpAuthUri.parse(uri);

      expect(parsed.secret, 'JBSWY3DPEHPK3PXP');
      expect(parsed.digits, 6);
      expect(parsed.period, 30);
      expect(parsed.algorithm, 'SHA1');
      expect(parsed.issuer, isNull);
    });

    test('throws FormatException for invalid scheme', () {
      expect(
        () => OtpAuthUri.parse('https://totp/MyApp?secret=ABC'),
        throwsA(isA<FormatException>()),
      );
    });

    test('throws FormatException for non-totp type', () {
      expect(
        () => OtpAuthUri.parse('otpauth://hotp/MyApp?secret=ABC'),
        throwsA(isA<FormatException>()),
      );
    });

    test('throws FormatException for missing secret', () {
      expect(
        () => OtpAuthUri.parse('otpauth://totp/MyApp'),
        throwsA(isA<FormatException>()),
      );
    });

    test('handles URI with no label', () {
      const uri = 'otpauth://totp/?secret=JBSWY3DPEHPK3PXP';

      final parsed = OtpAuthUri.parse(uri);

      expect(parsed.secret, 'JBSWY3DPEHPK3PXP');
      expect(parsed.label, isNull);
    });
  });
}
