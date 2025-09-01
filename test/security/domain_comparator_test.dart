import 'package:flutter_test/flutter_test.dart';
import 'package:citadel_password_manager/features/security/data/services/domain_comparator.dart';

void main() {
  group('DomainComparator.extractDomain', () {
    test('extracts domain from URL with subdomain', () {
      expect(
        DomainComparator.extractDomain('https://login.example.com/path'),
        'example.com',
      );
    });

    test('extracts domain from URL with www', () {
      expect(
        DomainComparator.extractDomain('https://www.example.com'),
        'example.com',
      );
    });

    test('extracts domain from bare domain (no scheme)', () {
      expect(
        DomainComparator.extractDomain('example.com'),
        'example.com',
      );
    });

    test('returns null for null input', () {
      expect(DomainComparator.extractDomain(null), isNull);
    });

    test('returns null for empty string', () {
      expect(DomainComparator.extractDomain(''), isNull);
    });

    test('extracts domain from deep subdomain', () {
      expect(
        DomainComparator.extractDomain('https://sub.domain.example.com'),
        'example.com',
      );
    });

    test('handles URL with port', () {
      expect(
        DomainComparator.extractDomain('https://example.com:8443/login'),
        'example.com',
      );
    });
  });

  group('DomainComparator.domainsMatch', () {
    test('returns true for same domain with different subdomains', () {
      expect(
        DomainComparator.domainsMatch(
          'https://login.example.com',
          'https://www.example.com',
        ),
        isTrue,
      );
    });

    test('returns false for different domains', () {
      expect(
        DomainComparator.domainsMatch(
          'https://example.com',
          'https://evil-example.com',
        ),
        isFalse,
      );
    });

    test('returns true when saved URL is null (cannot compare)', () {
      expect(
        DomainComparator.domainsMatch(null, 'https://example.com'),
        isTrue,
      );
    });

    test('returns true when target URL is null (cannot compare)', () {
      expect(
        DomainComparator.domainsMatch('https://example.com', null),
        isTrue,
      );
    });

    test('returns true when both URLs are null', () {
      expect(
        DomainComparator.domainsMatch(null, null),
        isTrue,
      );
    });

    test('returns false for similar-looking phishing domain', () {
      expect(
        DomainComparator.domainsMatch(
          'https://accounts.google.com',
          'https://accounts.g00gle.com',
        ),
        isFalse,
      );
    });
  });
}
