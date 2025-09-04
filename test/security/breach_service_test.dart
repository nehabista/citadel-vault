import 'dart:convert';

import 'package:citadel_password_manager/features/security/data/models/breach_record.dart';
import 'package:citadel_password_manager/features/security/data/services/breach_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  group('BreachService - pwnedPasswordCount', () {
    test('returns positive int when HIBP response contains matching suffix',
        () async {
      // SHA1("password") = 5BAA61E4C9B93F3F0682250B6CF8331B7EE68FD8
      // prefix = 5BAA6, suffix = 1E4C9B93F3F0682250B6CF8331B7EE68FD8
      final mockClient = MockClient((request) async {
        expect(request.url.path, contains('/range/5BAA6'));
        return http.Response(
          '1D2DA4053E34E76F6576ED1FB87F4A3FAF:1\r\n'
          '1E4C9B93F3F0682250B6CF8331B7EE68FD8:3861493\r\n'
          '1E4D2B7FBC83FD88B937E23D97BD4C2AF0:0\r\n',
          200,
        );
      });

      final service = BreachService(client: mockClient);
      final count = await service.pwnedPasswordCount('password');
      expect(count, 3861493);
    });

    test('returns 0 when no match found', () async {
      final mockClient = MockClient((request) async {
        return http.Response(
          'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA0:5\r\n'
          'BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB:10\r\n',
          200,
        );
      });

      final service = BreachService(client: mockClient);
      final count = await service.pwnedPasswordCount('password');
      expect(count, 0);
    });

    test('returns 0 on non-200 status', () async {
      final mockClient = MockClient((request) async {
        return http.Response('Service Unavailable', 503);
      });

      final service = BreachService(client: mockClient);
      final count = await service.pwnedPasswordCount('password');
      expect(count, 0);
    });
  });

  group('BreachService - breachedAccount', () {
    test('returns list of BreachRecord when 200', () async {
      final mockClient = MockClient((request) async {
        expect(request.url.path, contains('/api/v3/breachedaccount/'));
        expect(request.headers['hibp-api-key'], isNotEmpty);
        return http.Response(
          jsonEncode([
            {
              'Name': 'Adobe',
              'Title': 'Adobe',
              'Domain': 'adobe.com',
              'BreachDate': '2013-10-04',
              'AddedDate': '2013-12-04T00:00:00Z',
              'ModifiedDate': '2022-05-15T23:52:49Z',
              'DataClasses': ['Email addresses', 'Passwords'],
              'IsVerified': true,
              'IsSensitive': false,
              'PwnCount': 152445165,
              'Description': 'Adobe was breached.',
              'LogoPath': 'https://haveibeenpwned.com/Content/Images/PwnedLogos/Adobe.png',
            }
          ]),
          200,
        );
      });

      final service = BreachService(
        client: mockClient,
        hibpApiKey: 'test-api-key',
      );
      final records = await service.breachedAccount('test@example.com');
      expect(records, hasLength(1));
      expect(records.first.name, 'Adobe');
      expect(records.first.pwnCount, 152445165);
      expect(records.first.dataClasses, contains('Passwords'));
    });

    test('returns empty list on 404', () async {
      final mockClient = MockClient((request) async {
        return http.Response('', 404);
      });

      final service = BreachService(
        client: mockClient,
        hibpApiKey: 'test-api-key',
      );
      final records = await service.breachedAccount('clean@example.com');
      expect(records, isEmpty);
    });

    test('throws BreachServiceError when no API key', () async {
      final mockClient = MockClient((request) async {
        return http.Response('', 200);
      });

      final service = BreachService(client: mockClient);
      expect(
        () => service.breachedAccount('test@example.com'),
        throwsA(isA<BreachServiceError>()),
      );
    });
  });

  group('BreachService - getAllBreaches', () {
    test('returns list of BreachRecord from catalog endpoint', () async {
      final mockClient = MockClient((request) async {
        expect(request.url.path, equals('/api/v3/breaches'));
        return http.Response(
          jsonEncode([
            {
              'Name': 'Adobe',
              'Title': 'Adobe',
              'Domain': 'adobe.com',
              'BreachDate': '2013-10-04',
              'DataClasses': ['Email addresses'],
              'IsVerified': true,
              'IsSensitive': false,
            },
            {
              'Name': 'LinkedIn',
              'Title': 'LinkedIn',
              'Domain': 'linkedin.com',
              'BreachDate': '2012-05-05',
              'DataClasses': ['Passwords'],
              'IsVerified': true,
              'IsSensitive': false,
            },
          ]),
          200,
        );
      });

      final service = BreachService(client: mockClient);
      final breaches = await service.getAllBreaches();
      expect(breaches, hasLength(2));
      expect(breaches.first.name, 'Adobe');
      expect(breaches.last.name, 'LinkedIn');
    });
  });

  group('BreachRecord', () {
    test('fromJson parses all HIBP fields correctly', () {
      final json = {
        'Name': 'TestBreach',
        'Title': 'Test Breach',
        'Domain': 'test.com',
        'BreachDate': '2023-01-15',
        'AddedDate': '2023-02-01T10:00:00Z',
        'ModifiedDate': '2023-03-01T12:00:00Z',
        'DataClasses': ['Email addresses', 'Passwords', 'IP addresses'],
        'IsVerified': true,
        'IsSensitive': false,
        'PwnCount': 1000000,
        'Description': '<p>Test breach <b>description</b>.</p>',
        'LogoPath': 'https://example.com/logo.png',
      };

      final record = BreachRecord.fromJson(json);
      expect(record.name, 'TestBreach');
      expect(record.title, 'Test Breach');
      expect(record.domain, 'test.com');
      expect(record.breachDate, DateTime(2023, 1, 15));
      expect(record.addedDate, isNotNull);
      expect(record.modifiedDate, isNotNull);
      expect(record.dataClasses, hasLength(3));
      expect(record.verified, isTrue);
      expect(record.isSensitive, isFalse);
      expect(record.pwnCount, 1000000);
      expect(record.description, contains('Test breach'));
      expect(record.logoUrl, 'https://example.com/logo.png');
    });

    test('toJson produces valid JSON for cache serialization', () {
      final record = BreachRecord(
        name: 'Test',
        title: 'Test',
        domain: 'test.com',
        breachDate: DateTime(2023, 1, 1),
        dataClasses: ['Passwords'],
        verified: true,
        isSensitive: false,
        pwnCount: 100,
      );

      final json = record.toJson();
      expect(json['Name'], 'Test');
      expect(json['PwnCount'], 100);

      // Round-trip test
      final restored = BreachRecord.fromJson(json);
      expect(restored.name, record.name);
      expect(restored.pwnCount, record.pwnCount);
    });
  });
}
