import 'package:flutter_test/flutter_test.dart';

import 'package:citadel_password_manager/features/vault/domain/entities/custom_field.dart';
import 'package:citadel_password_manager/features/vault/domain/entities/vault_item.dart';

void main() {
  group('CustomField', () {
    test('toJson serializes correctly', () {
      const field = CustomField(
        name: 'api_key',
        value: 'abc123',
        type: CustomFieldType.hidden,
      );

      final json = field.toJson();

      expect(json['name'], 'api_key');
      expect(json['value'], 'abc123');
      expect(json['type'], 'hidden');
    });

    test('fromJson deserializes correctly', () {
      final json = {'name': 'api_key', 'value': 'abc123', 'type': 'hidden'};

      final field = CustomField.fromJson(json);

      expect(field.name, 'api_key');
      expect(field.value, 'abc123');
      expect(field.type, CustomFieldType.hidden);
    });

    test('fromJson with unknown type defaults to text', () {
      final json = {'name': 'field1', 'value': 'val', 'type': 'unknown_type'};

      final field = CustomField.fromJson(json);

      expect(field.type, CustomFieldType.text);
    });

    test('fromJson with missing type defaults to text', () {
      final json = {'name': 'field1', 'value': 'val'};

      final field = CustomField.fromJson(json);

      expect(field.type, CustomFieldType.text);
    });

    test('round-trip serialization preserves data', () {
      const original = CustomField(
        name: 'secret',
        value: 'my-secret-value',
        type: CustomFieldType.boolean,
      );

      final roundTripped = CustomField.fromJson(original.toJson());

      expect(roundTripped.name, original.name);
      expect(roundTripped.value, original.value);
      expect(roundTripped.type, original.type);
      expect(roundTripped, original);
    });

    test('copyWith creates copy with overrides', () {
      const original = CustomField(
        name: 'field1',
        value: 'val1',
        type: CustomFieldType.text,
      );

      final copied = original.copyWith(value: 'val2', type: CustomFieldType.hidden);

      expect(copied.name, 'field1');
      expect(copied.value, 'val2');
      expect(copied.type, CustomFieldType.hidden);
    });

    test('all CustomFieldType values serialize/deserialize', () {
      for (final type in CustomFieldType.values) {
        final field = CustomField(name: 'test', value: 'v', type: type);
        final deserialized = CustomField.fromJson(field.toJson());
        expect(deserialized.type, type);
      }
    });
  });

  group('VaultItemEntity with CustomField', () {
    test('toFieldsMap serializes customFields as List of JSON maps', () {
      final entity = VaultItemEntity(
        id: 'item-1',
        vaultId: 'vault-1',
        name: 'Test Item',
        type: VaultItemType.password,
        customFields: const [
          CustomField(name: 'api_key', value: 'abc', type: CustomFieldType.hidden),
          CustomField(name: 'active', value: 'true', type: CustomFieldType.boolean),
        ],
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      );

      final fields = entity.toFieldsMap();
      final customFields = fields['customFields'] as List;

      expect(customFields.length, 2);
      expect(customFields[0]['name'], 'api_key');
      expect(customFields[0]['type'], 'hidden');
      expect(customFields[1]['name'], 'active');
      expect(customFields[1]['type'], 'boolean');
    });

    test('fromFieldsMap deserializes customFields from List of maps', () {
      final fields = {
        'name': 'Test Item',
        'type': 'password',
        'customFields': [
          {'name': 'api_key', 'value': 'abc', 'type': 'hidden'},
          {'name': 'flag', 'value': 'true', 'type': 'boolean'},
        ],
      };

      final entity = VaultItemEntity.fromFields(
        id: 'item-1',
        vaultId: 'vault-1',
        fields: fields,
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      );

      expect(entity.customFields, isNotNull);
      expect(entity.customFields!.length, 2);
      expect(entity.customFields![0].name, 'api_key');
      expect(entity.customFields![0].type, CustomFieldType.hidden);
      expect(entity.customFields![1].name, 'flag');
      expect(entity.customFields![1].type, CustomFieldType.boolean);
    });

    test('fromFieldsMap handles null customFields', () {
      final fields = {
        'name': 'Test',
        'type': 'password',
        'customFields': null,
      };

      final entity = VaultItemEntity.fromFields(
        id: 'item-1',
        vaultId: 'vault-1',
        fields: fields,
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      );

      expect(entity.customFields, isNull);
    });

    test('fromFieldsMap handles empty customFields list', () {
      final fields = {
        'name': 'Test',
        'type': 'password',
        'customFields': <dynamic>[],
      };

      final entity = VaultItemEntity.fromFields(
        id: 'item-1',
        vaultId: 'vault-1',
        fields: fields,
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      );

      expect(entity.customFields, isNotNull);
      expect(entity.customFields!.isEmpty, true);
    });

    test('copyWith accepts List<CustomField>', () {
      final entity = VaultItemEntity(
        id: 'item-1',
        vaultId: 'vault-1',
        name: 'Test',
        type: VaultItemType.password,
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      );

      final updated = entity.copyWith(
        customFields: const [
          CustomField(name: 'new', value: 'field', type: CustomFieldType.text),
        ],
      );

      expect(updated.customFields!.length, 1);
      expect(updated.customFields![0].name, 'new');
    });
  });
}
