import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../features/vault/domain/entities/custom_field.dart';
import '../../../../features/vault/domain/entities/vault_item.dart';
import '../utils/form_decoration.dart';
import '../utils/type_form_mixin.dart';

/// Form fields for the [VaultItemType.secureNote] type.
class SecureNoteFormFields extends ConsumerStatefulWidget {
  const SecureNoteFormFields({super.key, this.existingItem});

  final VaultItemEntity? existingItem;

  @override
  ConsumerState<SecureNoteFormFields> createState() =>
      SecureNoteFormFieldsState();
}

class SecureNoteFormFieldsState extends ConsumerState<SecureNoteFormFields>
    implements TypeFormContract {
  late final TextEditingController _nameController;
  late final TextEditingController _contentController;

  @override
  void initState() {
    super.initState();
    final item = widget.existingItem;
    _nameController = TextEditingController(text: item?.name ?? '');
    _contentController = TextEditingController(text: _cf('content'));
  }

  String _cf(String name) {
    final existing = widget.existingItem?.customFields;
    if (existing == null) return '';
    return existing.where((f) => f.name == name).firstOrNull?.value ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  String getName() => _nameController.text.trim();

  @override
  List<CustomField> getCustomFields() {
    final content = _contentController.text.trim();
    if (content.isEmpty) return [];
    return [
      CustomField(name: 'content', value: content, type: CustomFieldType.text),
    ];
  }

  /// Secure notes have no separate notes field — return null.
  String? getNotes() => null;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextFormField(
          controller: _nameController,
          decoration: citadelInputDecoration('Title *'),
          validator: requiredValidator,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _contentController,
          decoration: citadelInputDecoration('Content'),
          maxLines: 8,
          minLines: 4,
          keyboardType: TextInputType.multiline,
        ),
      ],
    );
  }
}
