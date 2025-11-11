import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../features/vault/domain/entities/custom_field.dart';
import '../../../../features/vault/domain/entities/vault_item.dart';
import '../utils/form_decoration.dart';
import '../utils/type_form_mixin.dart';

/// Form fields for the [VaultItemType.paymentCard] type.
class PaymentCardFormFields extends ConsumerStatefulWidget {
  const PaymentCardFormFields({super.key, this.existingItem});

  final VaultItemEntity? existingItem;

  @override
  ConsumerState<PaymentCardFormFields> createState() =>
      PaymentCardFormFieldsState();
}

class PaymentCardFormFieldsState extends ConsumerState<PaymentCardFormFields>
    implements TypeFormContract {
  late final TextEditingController _cardNameController;
  late final TextEditingController _cardholderNameController;
  late final TextEditingController _cardNumberController;
  late final TextEditingController _expiryDateController;
  late final TextEditingController _cvvController;
  late final TextEditingController _pinController;
  late final TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    final item = widget.existingItem;
    _cardNameController = TextEditingController(
        text: _cf('cardName').isNotEmpty ? _cf('cardName') : (item?.name ?? ''));
    _cardholderNameController =
        TextEditingController(text: _cf('cardholderName'));
    _cardNumberController = TextEditingController(text: _cf('cardNumber'));
    _expiryDateController = TextEditingController(text: _cf('expiryDate'));
    _cvvController = TextEditingController(text: _cf('cvv'));
    _pinController = TextEditingController(text: _cf('pin'));
    _notesController = TextEditingController(text: item?.notes ?? '');
  }

  String _cf(String name) {
    final existing = widget.existingItem?.customFields;
    if (existing == null) return '';
    return existing.where((f) => f.name == name).firstOrNull?.value ?? '';
  }

  @override
  void dispose() {
    _cardNameController.dispose();
    _cardholderNameController.dispose();
    _cardNumberController.dispose();
    _expiryDateController.dispose();
    _cvvController.dispose();
    _pinController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  String getName() => _cardNameController.text.trim();

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

    addText('cardName', _cardNameController.text.trim());
    addText('cardholderName', _cardholderNameController.text.trim());
    addHidden('cardNumber', _cardNumberController.text.trim());
    addText('expiryDate', _expiryDateController.text.trim());
    addHidden('cvv', _cvvController.text.trim());
    addHidden('pin', _pinController.text.trim());
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
          controller: _cardNameController,
          decoration: citadelInputDecoration('Card Name *'),
          validator: requiredValidator,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _cardholderNameController,
          decoration: citadelInputDecoration('Cardholder Name'),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _cardNumberController,
          decoration: citadelInputDecoration('Card Number'),
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _expiryDateController,
                decoration: citadelInputDecoration('Expiry (MM/YY)'),
                keyboardType: TextInputType.datetime,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: _cvvController,
                decoration: citadelInputDecoration('CVV'),
                keyboardType: TextInputType.number,
                obscureText: true,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _pinController,
          decoration: citadelInputDecoration('PIN'),
          keyboardType: TextInputType.number,
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
