import 'package:citadel_password_manager/features/security/data/models/health_score.dart';
import 'package:citadel_password_manager/features/security/data/services/watchtower_service.dart';
import 'package:citadel_password_manager/features/security/domain/entities/watchtower_category.dart';
import 'package:citadel_password_manager/features/vault/domain/entities/vault_item.dart';
import 'package:flutter_test/flutter_test.dart';

/// Helper to create a VaultItemEntity with specified password and dates.
VaultItemEntity _makeItem({
  String id = '1',
  String password = 'Str0ng!Pass#2024',
  DateTime? updatedAt,
}) {
  return VaultItemEntity(
    id: id,
    vaultId: 'vault1',
    name: 'Test Item $id',
    password: password,
    type: VaultItemType.password,
    createdAt: DateTime(2024, 1, 1),
    updatedAt: updatedAt ?? DateTime.now(),
  );
}

void main() {
  late WatchtowerService service;

  setUp(() {
    service = WatchtowerService();
  });

  group('WatchtowerService - computeScore', () {
    test('empty list returns score 100', () {
      final score = service.computeScore([]);
      expect(score.score, 100);
      expect(score.weakItems, isEmpty);
      expect(score.reusedItems, isEmpty);
      expect(score.oldItems, isEmpty);
    });

    test('all strong, unique, fresh passwords returns 100', () {
      final items = [
        _makeItem(id: '1', password: 'C0mpl3x!P@ssw0rd#1'),
        _makeItem(id: '2', password: 'An0th3r!Str0ng#P@ss'),
        _makeItem(id: '3', password: 'Y3t!M0re#Secur1ty!'),
      ];
      final score = service.computeScore(items);
      // All strong, all unique, none breached, none old => 100
      expect(score.score, 100);
    });

    test('all weak passwords returns score reflecting 0% strong (0.3 weight)',
        () {
      final items = [
        _makeItem(id: '1', password: 'abc'),
        _makeItem(id: '2', password: 'xyz'),
        _makeItem(id: '3', password: '123'),
      ];
      final score = service.computeScore(items);
      // strongPct = 0, uniquePct = 1.0, notBreachedPct = 1.0, notOldPct = 1.0
      // score = (0*0.3 + 1.0*0.3 + 1.0*0.25 + 1.0*0.15) * 100 = 70
      expect(score.score, 70);
      expect(score.weakItems, hasLength(3));
    });

    test(
        '50% reused passwords returns score reflecting 50% unique (0.3 weight)',
        () {
      // 4 items: 2 with same password, 2 unique
      final items = [
        _makeItem(id: '1', password: 'C0mpl3x!P@ssw0rd#1'),
        _makeItem(id: '2', password: 'C0mpl3x!P@ssw0rd#1'), // reused
        _makeItem(id: '3', password: 'An0th3r!Str0ng#P@ss'),
        _makeItem(id: '4', password: 'Y3t!M0re#Secur1ty!'),
      ];
      final score = service.computeScore(items);
      // strongPct = 1.0, uniquePct = 0.5 (2 of 4 are reused), notBreachedPct = 1.0, notOldPct = 1.0
      // score = (1.0*0.3 + 0.5*0.3 + 1.0*0.25 + 1.0*0.15) * 100 = 85
      expect(score.score, 85);
      expect(score.reusedItems, hasLength(2));
    });

    test('passwords older than 90 days flags them as old', () {
      final oldDate = DateTime.now().subtract(const Duration(days: 100));
      final items = [
        _makeItem(id: '1', password: 'C0mpl3x!P@ssw0rd#1', updatedAt: oldDate),
        _makeItem(id: '2', password: 'An0th3r!Str0ng#P@ss'),
      ];
      final score = service.computeScore(items);
      expect(score.oldItems, hasLength(1));
      expect(score.oldItems.first.id, '1');
    });
  });

  group('HealthScore', () {
    test('color is green for 80-100', () {
      final score = HealthScore(
        score: 85,
        weakItems: [],
        reusedItems: [],
        oldItems: [],
        breachedItems: [],
      );
      expect(score.color, ScoreColor.green);
    });

    test('color is yellow for 50-79', () {
      final score = HealthScore(
        score: 65,
        weakItems: [],
        reusedItems: [],
        oldItems: [],
        breachedItems: [],
      );
      expect(score.color, ScoreColor.yellow);
    });

    test('color is red for 0-49', () {
      final score = HealthScore(
        score: 30,
        weakItems: [],
        reusedItems: [],
        oldItems: [],
        breachedItems: [],
      );
      expect(score.color, ScoreColor.red);
    });

    test('weakItems list contains only items with weak classification', () {
      final items = [
        _makeItem(id: '1', password: 'abc'),       // weak
        _makeItem(id: '2', password: 'C0mpl3x!P@ssw0rd#1'), // strong
      ];
      final score = service.computeScore(items);
      expect(score.weakItems.length, 1);
      expect(score.weakItems.first.id, '1');
    });

    test('reusedItems correctly identifies duplicate passwords', () {
      final items = [
        _makeItem(id: '1', password: 'Same!Pass#123'),
        _makeItem(id: '2', password: 'Same!Pass#123'),
        _makeItem(id: '3', password: 'Diff3r3nt!Pass#456'),
      ];
      final score = service.computeScore(items);
      expect(score.reusedItems.length, 2);
      final reusedIds = score.reusedItems.map((i) => i.id).toSet();
      expect(reusedIds, containsAll(['1', '2']));
    });

    test('oldItems contains items with updatedAt > 90 days ago', () {
      final old = DateTime.now().subtract(const Duration(days: 91));
      final recent = DateTime.now().subtract(const Duration(days: 10));
      final items = [
        _makeItem(id: '1', password: 'C0mpl3x!P@ssw0rd#1', updatedAt: old),
        _makeItem(id: '2', password: 'An0th3r!Str0ng#P@ss', updatedAt: recent),
      ];
      final score = service.computeScore(items);
      expect(score.oldItems.length, 1);
      expect(score.oldItems.first.id, '1');
    });

    test('withBreachedItems merges breach data into existing score', () {
      final items = [
        _makeItem(id: '1', password: 'C0mpl3x!P@ssw0rd#1'),
        _makeItem(id: '2', password: 'An0th3r!Str0ng#P@ss'),
      ];
      final score = service.computeScore(items);
      expect(score.score, 100);
      expect(score.breachedItems, isEmpty);

      // Now add breached items
      final breachedItem = items.first;
      final updated = score.withBreachedItems([breachedItem]);
      expect(updated.breachedItems, hasLength(1));
      // Score should decrease because notBreachedPct < 1.0
      expect(updated.score, lessThan(100));
    });

    test('categories returns 4 WatchtowerCategory entries', () {
      final score = HealthScore.empty();
      final categories = score.categories;
      expect(categories, hasLength(4));
      expect(
        categories.map((c) => c.type).toSet(),
        containsAll(WatchtowerCategoryType.values),
      );
    });
  });

  group('WatchtowerService - getExpiredItems', () {
    test('returns empty for items without expiry concept (default >90 days)',
        () {
      final items = [
        _makeItem(id: '1', password: 'C0mpl3x!P@ssw0rd#1'),
      ];
      // getExpiredItems checks items older than 90 days
      final expired = service.getExpiredItems(items);
      expect(expired, isEmpty);
    });

    test('returns items older than 90 days', () {
      final old = DateTime.now().subtract(const Duration(days: 100));
      final items = [
        _makeItem(id: '1', password: 'C0mpl3x!P@ssw0rd#1', updatedAt: old),
        _makeItem(id: '2', password: 'An0th3r!Str0ng#P@ss'),
      ];
      final expired = service.getExpiredItems(items);
      expect(expired, hasLength(1));
      expect(expired.first.id, '1');
    });
  });
}
