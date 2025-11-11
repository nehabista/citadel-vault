import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../features/vault/domain/entities/custom_field.dart';
import '../../../../features/vault/domain/entities/vault_item.dart';
import '../utils/form_decoration.dart';
import '../utils/type_form_mixin.dart';

/// Form fields for the [VaultItemType.contactInfo] type.
class ContactFormFields extends ConsumerStatefulWidget {
  const ContactFormFields({super.key, this.existingItem});

  final VaultItemEntity? existingItem;

  @override
  ConsumerState<ContactFormFields> createState() => ContactFormFieldsState();
}

class ContactFormFieldsState extends ConsumerState<ContactFormFields>
    implements TypeFormContract {
  late final TextEditingController _contactNameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _addressController;
  late final TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    final item = widget.existingItem;
    _contactNameController = TextEditingController(
        text: _cf('contactName').isNotEmpty
            ? _cf('contactName')
            : (item?.name ?? ''));
    _emailController = TextEditingController(text: _cf('email'));
    _phoneController = TextEditingController(text: _cf('phone'));
    _addressController = TextEditingController(text: _cf('address'));
    _notesController = TextEditingController(text: item?.notes ?? '');
  }

  String _cf(String name) {
    final existing = widget.existingItem?.customFields;
    if (existing == null) return '';
    return existing.where((f) => f.name == name).firstOrNull?.value ?? '';
  }

  @override
  void dispose() {
    _contactNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  String getName() => _contactNameController.text.trim();

  @override
  List<CustomField> getCustomFields() {
    final fields = <CustomField>[];
    void addText(String n, String v) {
      if (v.isNotEmpty) {
        fields.add(CustomField(name: n, value: v, type: CustomFieldType.text));
      }
    }

    addText('contactName', _contactNameController.text.trim());
    addText('email', _emailController.text.trim());
    addText('phone', _phoneController.text.trim());
    addText('address', _addressController.text.trim());
    return fields;
  }

  String? getNotes() {
    final text = _notesController.text.trim();
    return text.isEmpty ? null : text;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextFormField(
          controller: _contactNameController,
          decoration: citadelInputDecoration('Name *'),
          validator: requiredValidator,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _emailController,
          decoration: citadelInputDecoration('Email'),
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _phoneController,
          decoration: citadelInputDecoration('Phone'),
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _addressController,
          decoration: citadelInputDecoration('Address'),
          maxLines: 2,
          keyboardType: TextInputType.streetAddress,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _notesController,
          decoration: citadelInputDecoration('Notes'),
          maxLines: 3,
          keyboardType: TextInputType.multiline,
        ),
      ],
    );
  }
}
