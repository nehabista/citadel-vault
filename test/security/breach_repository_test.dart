import 'dart:convert';

import 'package:citadel_password_manager/core/database/daos/settings_dao.dart';
import 'package:citadel_password_manager/features/security/data/models/breach_record.dart';
import 'package:citadel_password_manager/features/security/data/repositories/breach_repository.dart';
import 'package:citadel_password_manager/features/security/data/services/breach_service.dart';
import 'package:citadel_password_manager/features/security/domain/entities/breach_result.dart';
import 'package:flutter_test/flutter_test.dart';

/// In-memory SettingsDao for testing.
class FakeSettingsDao implements SettingsDao {
  final Map<String, String> _store = {};

  @override
  Future<void> setSetting(String key, String value) async {
    _store[key] = value;
  }

  @override
  Future<String?> getSetting(String key) async {
    return _store[key];
  }

  @override
  Future<void> deleteSetting(String key) async {
    _store.remove(key);
  }
}

/// Fake BreachService for testing repository caching.
class FakeBreachService extends BreachService {
  int pwnedCallCount = 0;
  int allBreachesCallCount = 0;
  int breachedAccountCallCount = 0;

  int nextPwnedCount = 5;
  List<BreachRecord> nextBreaches = [];
  List<BreachRecord> nextAccountBreaches = [];

  FakeBreachService() : super();

  @override
  Future<int> pwnedPasswordCount(String password) async {
    pwnedCallCount++;
    return nextPwnedCount;
  }

  @override
  Future<List<BreachRecord>> getAllBreaches() async {
    allBreachesCallCount++;
    return nextBreaches;
  }

  @override
  Future<List<BreachRecord>> breachedAccount(String email) async {
    breachedAccountCallCount++;
    return nextAccountBreaches;
  }
}

void main() {
  late FakeSettingsDao settingsDao;
  late FakeBreachService breachService;
  late BreachRepository repository;

  setUp(() {
    settingsDao = FakeSettingsDao();
    breachService = FakeBreachService();
    repository = BreachRepository(
      breachService: breachService,
      settingsDao: settingsDao,
    );
  });

  group('BreachResult sealed class', () {
    test('NotChecked is a valid BreachResult', () {
      const result = BreachResult.notChecked();
      expect(result, isA<BreachResultNotChecked>());
    });

    test('Clean is a valid BreachResult', () {
      const result = BreachResult.clean();
      expect(result, isA<BreachResultClean>());
    });

    test('Breached(count) holds the count', () {
      const result = BreachResult.breached(42);
      expect(result, isA<BreachResultBreached>());
      expect((result as BreachResultBreached).count, 42);
    });
  });

  group('BreachRepository - checkPasswordCached', () {
    test('returns cached result within 24h TTL', () async {
      // First call - should hit the service
      final result1 = await repository.checkPasswordCached('test123');
      expect(result1, isA<BreachResultBreached>());
      expect((result1 as BreachResultBreached).count, 5);
      expect(breachService.pwnedCallCount, 1);

      // Second call - should use cache
      final result2 = await repository.checkPasswordCached('test123');
      expect(result2, isA<BreachResultBreached>());
      expect((result2 as BreachResultBreached).count, 5);
      expect(breachService.pwnedCallCount, 1); // still 1, cache hit
    });

    test('fetches fresh after 24h TTL expires', () async {
      // Seed cache with expired entry
      final expiredTime =
          DateTime.now().subtract(const Duration(hours: 25)).toIso8601String();
      // We need to compute the SHA1 hash of 'test123' to build the cache key
      // For this test, we'll call once, then manually expire the cache
      await repository.checkPasswordCached('test123');
      expect(breachService.pwnedCallCount, 1);

      // Manually expire the cache entry by rewriting with old timestamp
      final cacheKey = repository.passwordCacheKey('test123');
      await settingsDao.setSetting(
        cacheKey,
        jsonEncode({'count': 5, 'cachedAt': expiredTime}),
      );

      // This should fetch fresh
      breachService.nextPwnedCount = 10;
      final result = await repository.checkPasswordCached('test123');
      expect(breachService.pwnedCallCount, 2);
      expect(result, isA<BreachResultBreached>());
      expect((result as BreachResultBreached).count, 10);
    });
  });

  group('BreachRepository - getAllBreachesCached', () {
    test('caches catalog with 7d TTL', () async {
      breachService.nextBreaches = [
        BreachRecord(
          name: 'Test',
          title: 'Test',
          domain: 'test.com',
          breachDate: DateTime(2023),
          dataClasses: ['Passwords'],
          verified: true,
          isSensitive: false,
        ),
      ];

      // First call
      final result1 = await repository.getAllBreachesCached();
      expect(result1, hasLength(1));
      expect(breachService.allBreachesCallCount, 1);

      // Second call - should use cache
      final result2 = await repository.getAllBreachesCached();
      expect(result2, hasLength(1));
      expect(breachService.allBreachesCallCount, 1); // still 1
    });
  });

  group('BreachRepository - invalidatePasswordCache', () {
    test('removes cache entry for password', () async {
      await repository.checkPasswordCached('test123');
      expect(breachService.pwnedCallCount, 1);

      await repository.invalidatePasswordCache('test123');

      // Should fetch fresh after invalidation
      await repository.checkPasswordCached('test123');
      expect(breachService.pwnedCallCount, 2);
    });
  });
}
