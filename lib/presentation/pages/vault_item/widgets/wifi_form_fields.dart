import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../features/vault/domain/entities/custom_field.dart';
import '../../../../features/vault/domain/entities/vault_item.dart';
import '../utils/form_decoration.dart';
import '../utils/type_form_mixin.dart';

/// Form fields for the [VaultItemType.wifiPassword] type.
class WifiFormFields extends ConsumerStatefulWidget {
  const WifiFormFields({super.key, this.existingItem});

  final VaultItemEntity? existingItem;

  @override
  ConsumerState<WifiFormFields> createState() => WifiFormFieldsState();
}

class WifiFormFieldsState extends ConsumerState<WifiFormFields>
    implements TypeFormContract {
  late final TextEditingController _ssidController;
  late final TextEditingController _wifiPasswordController;
  late final TextEditingController _notesController;
  String _wifiSecurityType = 'WPA2';
  final bool _passwordVisible = false;

  @override
  void initState() {
    super.initState();
    final item = widget.existingItem;
    _ssidController = TextEditingController(
        text: _cf('ssid').isNotEmpty ? _cf('ssid') : (item?.name ?? ''));
    _wifiPasswordController =
        TextEditingController(text: _cf('wifiPassword'));
    _notesController = TextEditingController(text: item?.notes ?? '');
    final sec = _cf('securityType');
    if (sec.isNotEmpty) _wifiSecurityType = sec;
  }

  String _cf(String name) {
    final existing = widget.existingItem?.customFields;
    if (existing == null) return '';
    return existing.where((f) => f.name == name).firstOrNull?.value ?? '';
  }

  @override
  void dispose() {
    _ssidController.dispose();
    _wifiPasswordController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  String getName() => _ssidController.text.trim();

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

    addText('ssid', _ssidController.text.trim());
    addHidden('wifiPassword', _wifiPasswordController.text.trim());
    addText('securityType', _wifiSecurityType);
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
          controller: _ssidController,
          decoration: citadelInputDecoration('Network Name (SSID) *'),
          validator: requiredValidator,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _wifiPasswordController,
          decoration: citadelInputDecoration('Password'),
          obscureText: !_passwordVisible,
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          initialValue: _wifiSecurityType,
          decoration: citadelInputDecoration('Security Type'),
          items: const [
            DropdownMenuItem(value: 'WPA2', child: Text('WPA2')),
            DropdownMenuItem(value: 'WPA3', child: Text('WPA3')),
            DropdownMenuItem(value: 'WEP', child: Text('WEP')),
            DropdownMenuItem(value: 'Open', child: Text('Open')),
          ],
          onChanged: (value) {
            if (value != null) setState(() => _wifiSecurityType = value);
          },
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
