import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../features/vault/domain/entities/custom_field.dart';
import '../../../../features/vault/domain/entities/vault_item.dart';
import '../utils/form_decoration.dart';
import '../utils/type_form_mixin.dart';

/// Form fields for the [VaultItemType.softwareLicense] type.
class SoftwareLicenseFormFields extends ConsumerStatefulWidget {
  const SoftwareLicenseFormFields({super.key, this.existingItem});

  final VaultItemEntity? existingItem;

  @override
  ConsumerState<SoftwareLicenseFormFields> createState() =>
      SoftwareLicenseFormFieldsState();
}

class SoftwareLicenseFormFieldsState
    extends ConsumerState<SoftwareLicenseFormFields>
    implements TypeFormContract {
  late final TextEditingController _softwareNameController;
  late final TextEditingController _licenseKeyController;
  late final TextEditingController _versionController;
  late final TextEditingController _licensedToController;
  late final TextEditingController _licenseExpiryController;
  late final TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    final item = widget.existingItem;
    _softwareNameController = TextEditingController(
        text: _cf('softwareName').isNotEmpty
            ? _cf('softwareName')
            : (item?.name ?? ''));
    _licenseKeyController = TextEditingController(text: _cf('licenseKey'));
    _versionController = TextEditingController(text: _cf('version'));
    _licensedToController = TextEditingController(text: _cf('licensedTo'));
    _licenseExpiryController =
        TextEditingController(text: _cf('licenseExpiry'));
    _notesController = TextEditingController(text: item?.notes ?? '');
  }

  String _cf(String name) {
    final existing = widget.existingItem?.customFields;
    if (existing == null) return '';
    return existing.where((f) => f.name == name).firstOrNull?.value ?? '';
  }

  @override
  void dispose() {
    _softwareNameController.dispose();
    _licenseKeyController.dispose();
    _versionController.dispose();
    _licensedToController.dispose();
    _licenseExpiryController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  String getName() => _softwareNameController.text.trim();

  @override
  List<CustomField> getCustomFields() {
    final fields = <CustomField>[];
    void addText(String n, String v) {
      if (v.isNotEmpty) {
        fields.add(CustomField(name: n, value: v, type: CustomFieldType.text));
      }
    }

    void addHidden(String n, String v) {
      if (v.isNotEmpty) {
        fields
            .add(CustomField(name: n, value: v, type: CustomFieldType.hidden));
      }
    }

    addText('softwareName', _softwareNameController.text.trim());
    addHidden('licenseKey', _licenseKeyController.text.trim());
    addText('version', _versionController.text.trim());
    addText('licensedTo', _licensedToController.text.trim());
    addText('licenseExpiry', _licenseExpiryController.text.trim());
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
          controller: _softwareNameController,
          decoration: citadelInputDecoration('Software Name *'),
          validator: requiredValidator,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _licenseKeyController,
          decoration: citadelInputDecoration('License Key'),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _versionController,
          decoration: citadelInputDecoration('Version'),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _licensedToController,
          decoration: citadelInputDecoration('Licensed To'),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _licenseExpiryController,
          decoration: citadelInputDecoration('Expiry Date'),
          keyboardType: TextInputType.datetime,
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
