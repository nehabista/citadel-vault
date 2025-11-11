import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../features/vault/domain/entities/custom_field.dart';
import '../../../../features/vault/domain/entities/vault_item.dart';
import '../utils/form_decoration.dart';
import '../utils/type_form_mixin.dart';

/// Form fields for identity-document types: [VaultItemType.driversLicense],
/// [VaultItemType.passport], and [VaultItemType.socialSecurityNumber].
///
/// Uses a single widget parameterised by the identity sub-type to avoid
/// three near-identical classes.
class IdentityFormFields extends ConsumerStatefulWidget {
  const IdentityFormFields({
    super.key,
    required this.identityType,
    this.existingItem,
  });

  /// Which identity sub-type to render.
  final VaultItemType identityType;
  final VaultItemEntity? existingItem;

  @override
  ConsumerState<IdentityFormFields> createState() => IdentityFormFieldsState();
}

class IdentityFormFieldsState extends ConsumerState<IdentityFormFields>
    implements TypeFormContract {
  // Drivers License
  late final TextEditingController _dlNameController;
  late final TextEditingController _dlNumberController;
  late final TextEditingController _dlStateController;
  late final TextEditingController _dlExpiryController;
  late final TextEditingController _dlDobController;

  // Passport
  late final TextEditingController _passportNameController;
  late final TextEditingController _passportNumberController;
  late final TextEditingController _passportCountryController;
  late final TextEditingController _passportExpiryController;
  late final TextEditingController _passportDobController;

  // SSN
  late final TextEditingController _ssnNameController;
  late final TextEditingController _ssnNumberController;

  late final TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    final item = widget.existingItem;
    _notesController = TextEditingController(text: item?.notes ?? '');

    // Drivers License
    _dlNameController = TextEditingController(
        text: _cf('dlName').isNotEmpty ? _cf('dlName') : (item?.name ?? ''));
    _dlNumberController = TextEditingController(text: _cf('dlNumber'));
    _dlStateController = TextEditingController(text: _cf('dlState'));
    _dlExpiryController = TextEditingController(text: _cf('dlExpiry'));
    _dlDobController = TextEditingController(text: _cf('dlDob'));

    // Passport
    _passportNameController = TextEditingController(
        text: _cf('passportName').isNotEmpty
            ? _cf('passportName')
            : (item?.name ?? ''));
    _passportNumberController =
        TextEditingController(text: _cf('passportNumber'));
    _passportCountryController =
        TextEditingController(text: _cf('passportCountry'));
    _passportExpiryController =
        TextEditingController(text: _cf('passportExpiry'));
    _passportDobController = TextEditingController(text: _cf('passportDob'));

    // SSN
    _ssnNameController = TextEditingController(
        text: _cf('ssnName').isNotEmpty ? _cf('ssnName') : (item?.name ?? ''));
    _ssnNumberController = TextEditingController(text: _cf('ssnNumber'));
  }

  String _cf(String name) {
    final existing = widget.existingItem?.customFields;
    if (existing == null) return '';
    final field = existing.where((f) => f.name == name).firstOrNull;
    return field?.value ?? '';
  }

  @override
  void dispose() {
    _dlNameController.dispose();
    _dlNumberController.dispose();
    _dlStateController.dispose();
    _dlExpiryController.dispose();
    _dlDobController.dispose();
    _passportNameController.dispose();
    _passportNumberController.dispose();
    _passportCountryController.dispose();
    _passportExpiryController.dispose();
    _passportDobController.dispose();
    _ssnNameController.dispose();
    _ssnNumberController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  // --- TypeFormContract implementation ---

  @override
  String getName() {
    switch (widget.identityType) {
      case VaultItemType.driversLicense:
        return _dlNameController.text.trim();
      case VaultItemType.passport:
        return _passportNameController.text.trim();
      case VaultItemType.socialSecurityNumber:
        return _ssnNameController.text.trim();
      default:
        return '';
    }
  }

  @override
  List<CustomField> getCustomFields() {
    final fields = <CustomField>[];

    void addText(String name, String value) {
      if (value.isNotEmpty) {
        fields.add(
            CustomField(name: name, value: value, type: CustomFieldType.text));
      }
    }

    void addHidden(String name, String value) {
      if (value.isNotEmpty) {
        fields.add(CustomField(
            name: name, value: value, type: CustomFieldType.hidden));
      }
    }

    switch (widget.identityType) {
      case VaultItemType.driversLicense:
        addText('dlName', _dlNameController.text.trim());
        addText('dlNumber', _dlNumberController.text.trim());
        addText('dlState', _dlStateController.text.trim());
        addText('dlExpiry', _dlExpiryController.text.trim());
        addText('dlDob', _dlDobController.text.trim());
        break;
      case VaultItemType.passport:
        addText('passportName', _passportNameController.text.trim());
        addText('passportNumber', _passportNumberController.text.trim());
        addText('passportCountry', _passportCountryController.text.trim());
        addText('passportExpiry', _passportExpiryController.text.trim());
        addText('passportDob', _passportDobController.text.trim());
        break;
      case VaultItemType.socialSecurityNumber:
        addText('ssnName', _ssnNameController.text.trim());
        addHidden('ssnNumber', _ssnNumberController.text.trim());
        break;
      default:
        break;
    }
    return fields;
  }

  /// Return the notes text for the save method.
  String? getNotes() {
    final text = _notesController.text.trim();
    return text.isEmpty ? null : text;
  }

  @override
  Widget build(BuildContext context) {
    switch (widget.identityType) {
      case VaultItemType.driversLicense:
        return _buildDriversLicense();
      case VaultItemType.passport:
        return _buildPassport();
      case VaultItemType.socialSecurityNumber:
        return _buildSsn();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildDriversLicense() {
    return Column(
      children: [
        TextFormField(
          controller: _dlNameController,
          decoration: citadelInputDecoration('Name *'),
          validator: requiredValidator,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _dlNumberController,
          decoration: citadelInputDecoration('License Number'),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _dlStateController,
          decoration: citadelInputDecoration('State / Province'),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _dlExpiryController,
          decoration: citadelInputDecoration('Expiry Date'),
          keyboardType: TextInputType.datetime,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _dlDobController,
          decoration: citadelInputDecoration('Date of Birth'),
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

  Widget _buildPassport() {
    return Column(
      children: [
        TextFormField(
          controller: _passportNameController,
          decoration: citadelInputDecoration('Name *'),
          validator: requiredValidator,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _passportNumberController,
          decoration: citadelInputDecoration('Passport Number'),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _passportCountryController,
          decoration: citadelInputDecoration('Country'),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _passportExpiryController,
          decoration: citadelInputDecoration('Expiry Date'),
          keyboardType: TextInputType.datetime,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _passportDobController,
          decoration: citadelInputDecoration('Date of Birth'),
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

  Widget _buildSsn() {
    return Column(
      children: [
        TextFormField(
          controller: _ssnNameController,
          decoration: citadelInputDecoration('Name *'),
          validator: requiredValidator,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _ssnNumberController,
          decoration: citadelInputDecoration('SSN'),
          obscureText: true,
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
