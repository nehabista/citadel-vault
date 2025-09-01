import 'dart:convert';

import 'package:crypto/crypto.dart';

import '../../../../core/database/daos/settings_dao.dart';
import '../../domain/entities/breach_result.dart';
import '../models/breach_record.dart';
import '../services/breach_service.dart';

/// Repository that wraps [BreachService] with caching via [SettingsDao].
///
/// Cache strategy:
/// - Password breach results: 24-hour TTL (key: `breach_pwd_{SHA1}`)
/// - Breach catalog: 7-day TTL (key: `breach_catalog`)
/// - Email breach results: not cached (changes frequently)
class BreachRepository {
  final BreachService _breachService;
  final SettingsDao _settingsDao;

  static const _passwordTtl = Duration(hours: 24);
  static const _catalogTtl = Duration(days: 7);

  BreachRepository({
    required BreachService breachService,
    required SettingsDao settingsDao,
  })  : _breachService = breachService,
        _settingsDao = settingsDao;

  /// Compute the cache key for a password.
  /// Exposed for testing purposes.
  String passwordCacheKey(String password) {
    final hash =
        sha1.convert(utf8.encode(password)).toString().toUpperCase();
    return 'breach_pwd_$hash';
  }

  /// Check a password against HIBP with 24-hour caching.
  ///
  /// Returns [BreachResultBreached] with count if found,
  /// [BreachResultClean] if not found, using cached results within TTL.
  Future<BreachResult> checkPasswordCached(String password) async {
    final cacheKey = passwordCacheKey(password);

    // Check cache
    final cached = await _settingsDao.getSetting(cacheKey);
    if (cached != null) {
      try {
        final data = jsonDecode(cached) as Map<String, dynamic>;
        final cachedAt = DateTime.parse(data['cachedAt'] as String);
        if (DateTime.now().difference(cachedAt) < _passwordTtl) {
          final count = data['count'] as int;
          return count > 0
              ? BreachResult.breached(count)
              : const BreachResult.clean();
        }
      } catch (_) {
        // Invalid cache entry, fetch fresh
      }
    }

    // Fetch fresh
    final count = await _breachService.pwnedPasswordCount(password);

    // Cache result
    await _settingsDao.setSetting(
      cacheKey,
      jsonEncode({
        'count': count,
        'cachedAt': DateTime.now().toIso8601String(),
      }),
    );

    return count > 0
        ? BreachResult.breached(count)
        : const BreachResult.clean();
  }

  /// Get breached accounts for an email (not cached).
  Future<List<BreachRecord>> getBreachedAccounts(String email) async {
    return _breachService.breachedAccount(email);
  }

  /// Get the full breach catalog with 7-day caching.
  Future<List<BreachRecord>> getAllBreachesCached() async {
    const cacheKey = 'breach_catalog';

    // Check cache
    final cached = await _settingsDao.getSetting(cacheKey);
    if (cached != null) {
      try {
        final data = jsonDecode(cached) as Map<String, dynamic>;
        final cachedAt = DateTime.parse(data['cachedAt'] as String);
        if (DateTime.now().difference(cachedAt) < _catalogTtl) {
          final list = (data['breaches'] as List<dynamic>)
              .map((e) => BreachRecord.fromJson(e as Map<String, dynamic>))
              .toList();
          return list;
        }
      } catch (_) {
        // Invalid cache entry, fetch fresh
      }
    }

    // Fetch fresh
    final breaches = await _breachService.getAllBreaches();

    // Cache result
    await _settingsDao.setSetting(
      cacheKey,
      jsonEncode({
        'cachedAt': DateTime.now().toIso8601String(),
        'breaches': breaches.map((b) => b.toJson()).toList(),
      }),
    );

    return breaches;
  }

  /// Invalidate cached breach result for a password.
  ///
  /// Call this when a password is changed so the next check fetches fresh data.
  Future<void> invalidatePasswordCache(String password) async {
    final cacheKey = passwordCacheKey(password);
    await _settingsDao.deleteSetting(cacheKey);
  }
}
