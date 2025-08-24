// Test: vault search filtering logic
// Tests the search filtering function independently of Riverpod/Notifier

import 'package:flutter_test/flutter_test.dart';
import 'package:citadel_password_manager/features/vault/domain/entities/vault_item.dart';
import 'package:citadel_password_manager/features/search/presentation/providers/vault_search_provider.dart';

void main() {
  final testItems = [
    VaultItemEntity(
      id: '1',
      vaultId: 'v1',
      name: 'Google Account',
      username: 'user@gmail.com',
      url: 'https://accounts.google.com',
      notes: 'Primary email',
      type: VaultItemType.password,
      createdAt: DateTime(2024, 1, 1),
      updatedAt: DateTime(2024, 1, 1),
    ),
    VaultItemEntity(
      id: '2',
      vaultId: 'v1',
      name: 'Facebook',
      username: 'john.doe',
      url: 'https://facebook.com',
      notes: 'Social media account',
      type: VaultItemType.password,
      createdAt: DateTime(2024, 1, 2),
      updatedAt: DateTime(2024, 1, 2),
    ),
    VaultItemEntity(
      id: '3',
      vaultId: 'v1',
      name: 'WiFi Home Network',
      type: VaultItemType.wifiPassword,
      notes: 'Router password for home',
      createdAt: DateTime(2024, 1, 3),
      updatedAt: DateTime(2024, 1, 3),
    ),
    VaultItemEntity(
      id: '4',
      vaultId: 'v1',
      name: 'Bank of America',
      username: 'bankuser123',
      url: 'https://bankofamerica.com',
      type: VaultItemType.bankAccount,
      createdAt: DateTime(2024, 1, 4),
      updatedAt: DateTime(2024, 1, 4),
    ),
  ];

  group('filterItems', () {
    test('filters by name (case insensitive)', () {
      final results = filterItems(testItems, 'goo');
      expect(results.length, 1);
      expect(results.first.name, 'Google Account');
    });

    test('filters by name uppercase query', () {
      final results = filterItems(testItems, 'GOOGLE');
      expect(results.length, 1);
      expect(results.first.name, 'Google Account');
    });

    test('filters by username', () {
      final results = filterItems(testItems, 'john.doe');
      expect(results.length, 1);
      expect(results.first.name, 'Facebook');
    });

    test('filters by URL', () {
      final results = filterItems(testItems, 'bankofamerica');
      expect(results.length, 1);
      expect(results.first.name, 'Bank of America');
    });

    test('filters by notes', () {
      final results = filterItems(testItems, 'Router password');
      expect(results.length, 1);
      expect(results.first.name, 'WiFi Home Network');
    });

    test('empty query returns empty list', () {
      final results = filterItems(testItems, '');
      expect(results, isEmpty);
    });

    test('no matches returns empty list', () {
      final results = filterItems(testItems, 'zzzznonexistent');
      expect(results, isEmpty);
    });

    test('matches multiple items', () {
      // 'account' appears in 'Google Account' (name) and 'Social media account' (notes)
      final results = filterItems(testItems, 'account');
      expect(results.length, 2);
    });

    test('matches items with null fields gracefully', () {
      // WiFi Home Network has no username/url - should not crash
      final results = filterItems(testItems, 'wifi');
      expect(results.length, 1);
      expect(results.first.name, 'WiFi Home Network');
    });
  });
}
