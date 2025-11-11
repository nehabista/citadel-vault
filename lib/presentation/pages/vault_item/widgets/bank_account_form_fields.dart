import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../features/vault/domain/entities/custom_field.dart';
import '../../../../features/vault/domain/entities/vault_item.dart';
import '../utils/form_decoration.dart';
import '../utils/type_form_mixin.dart';

/// Form fields for the [VaultItemType.bankAccount] type.
class BankAccountFormFields extends ConsumerStatefulWidget {
  const BankAccountFormFields({super.key, this.existingItem});

  final VaultItemEntity? existingItem;

  @override
  ConsumerState<BankAccountFormFields> createState() =>
      BankAccountFormFieldsState();
}

class BankAccountFormFieldsState extends ConsumerState<BankAccountFormFields>
    implements TypeFormContract {
  late final TextEditingController _bankNameController;
  late final TextEditingController _accountHolderController;
  late final TextEditingController _accountNumberController;
  late final TextEditingController _routingNumberController;
  late final TextEditingController _swiftBicController;
  late final TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    final item = widget.existingItem;
    _bankNameController = TextEditingController(
        text: _cf('bankName').isNotEmpty ? _cf('bankName') : (item?.name ?? ''));
    _accountHolderController =
        TextEditingController(text: _cf('accountHolder'));
    _accountNumberController =
        TextEditingController(text: _cf('accountNumber'));
    _routingNumberController =
        TextEditingController(text: _cf('routingNumber'));
    _swiftBicController = TextEditingController(text: _cf('swiftBic'));
    _notesController = TextEditingController(text: item?.notes ?? '');
  }

  String _cf(String name) {
    final existing = widget.existingItem?.customFields;
    if (existing == null) return '';
    return existing.where((f) => f.name == name).firstOrNull?.value ?? '';
  }

  @override
  void dispose() {
    _bankNameController.dispose();
    _accountHolderController.dispose();
    _accountNumberController.dispose();
    _routingNumberController.dispose();
    _swiftBicController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  String getName() => _bankNameController.text.trim();

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

    addText('bankName', _bankNameController.text.trim());
    addText('accountHolder', _accountHolderController.text.trim());
    addHidden('accountNumber', _accountNumberController.text.trim());
    addText('routingNumber', _routingNumberController.text.trim());
    addText('swiftBic', _swiftBicController.text.trim());
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
          controller: _bankNameController,
          decoration: citadelInputDecoration('Bank Name *'),
          validator: requiredValidator,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _accountHolderController,
          decoration: citadelInputDecoration('Account Holder'),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _accountNumberController,
          decoration: citadelInputDecoration('Account Number'),
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _routingNumberController,
          decoration: citadelInputDecoration('Routing Number'),
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _swiftBicController,
          decoration: citadelInputDecoration('SWIFT / BIC'),
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
