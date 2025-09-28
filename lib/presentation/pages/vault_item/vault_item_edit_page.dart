import 'dart:math';

import 'package:cryptography/cryptography.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers/core_providers.dart';
import '../../../core/providers/session_provider.dart';
import '../../../core/providers/sync_providers.dart';
import '../../../core/session/session_state.dart';
import '../../../features/password_generator/presentation/providers/strength_provider.dart';
import '../../../features/password_generator/presentation/widgets/entropy_gauge.dart';
import '../../../features/password_generator/presentation/widgets/password_generator_sheet.dart';
import '../../../features/vault/domain/entities/custom_field.dart';
import '../../../features/vault/domain/entities/vault_item.dart';
import '../../../features/vault/presentation/providers/multi_vault_provider.dart';
import 'widgets/custom_fields_section.dart';

/// Page for creating or editing a vault item.
///
/// If [existingItem] is null, operates in create mode.
/// Otherwise operates in edit mode with pre-filled fields.
///
/// Shows type-specific form fields based on the selected [VaultItemType].
class VaultItemEditPage extends ConsumerStatefulWidget {
  const VaultItemEditPage({super.key, this.existingItem, this.initialType});

  final VaultItemEntity? existingItem;
  final VaultItemType? initialType;

  @override
  ConsumerState<VaultItemEditPage> createState() => _VaultItemEditPageState();
}

class _VaultItemEditPageState extends ConsumerState<VaultItemEditPage> {
  final _formKey = GlobalKey<FormState>();

  // --- Shared / Password type controllers ---
  late final TextEditingController _nameController;
  late final TextEditingController _urlController;
  late final TextEditingController _usernameController;
  late final TextEditingController _passwordController;
  late final TextEditingController _notesController;

  // --- Secure Note ---
  late final TextEditingController _contentController;

  // --- Bank Account ---
  late final TextEditingController _bankNameController;
  late final TextEditingController _accountHolderController;
  late final TextEditingController _accountNumberController;
  late final TextEditingController _routingNumberController;
  late final TextEditingController _swiftBicController;

  // --- Payment Card ---
  late final TextEditingController _cardNameController;
  late final TextEditingController _cardholderNameController;
  late final TextEditingController _cardNumberController;
  late final TextEditingController _expiryDateController;
  late final TextEditingController _cvvController;
  late final TextEditingController _pinController;

  // --- WiFi ---
  late final TextEditingController _ssidController;
  late final TextEditingController _wifiPasswordController;
  String _wifiSecurityType = 'WPA2';

  // --- Contact ---
  late final TextEditingController _contactNameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _addressController;

  // --- Software License ---
  late final TextEditingController _softwareNameController;
  late final TextEditingController _licenseKeyController;
  late final TextEditingController _versionController;
  late final TextEditingController _licensedToController;
  late final TextEditingController _licenseExpiryController;

  late VaultItemType _selectedType;
  late bool _isFavorite;
  late List<CustomField> _customFields;
  late int? _expiryDays;
  bool _passwordVisible = false;
  bool _isSaving = false;

  bool get _isCreateMode => widget.existingItem == null;

  @override
  void initState() {
    super.initState();
    final item = widget.existingItem;
    _selectedType = item?.type ?? widget.initialType ?? VaultItemType.password;
    _isFavorite = item?.isFavorite ?? false;
    _customFields = List.of(item?.customFields ?? []);
    _expiryDays = item?.expiryDays;

    // Password type / shared
    _nameController = TextEditingController(text: item?.name ?? '');
    _urlController = TextEditingController(text: item?.url ?? '');
    _usernameController = TextEditingController(text: item?.username ?? '');
    _passwordController = TextEditingController(text: item?.password ?? '');
    _notesController = TextEditingController(text: item?.notes ?? '');

    // Secure Note
    _contentController =
        TextEditingController(text: _customFieldValue('content'));

    // Bank Account
    _bankNameController =
        TextEditingController(text: _customFieldValue('bankName'));
    _accountHolderController =
        TextEditingController(text: _customFieldValue('accountHolder'));
    _accountNumberController =
        TextEditingController(text: _customFieldValue('accountNumber'));
    _routingNumberController =
        TextEditingController(text: _customFieldValue('routingNumber'));
    _swiftBicController =
        TextEditingController(text: _customFieldValue('swiftBic'));

    // Payment Card
    _cardNameController =
        TextEditingController(text: _customFieldValue('cardName'));
    _cardholderNameController =
        TextEditingController(text: _customFieldValue('cardholderName'));
    _cardNumberController =
        TextEditingController(text: _customFieldValue('cardNumber'));
    _expiryDateController =
        TextEditingController(text: _customFieldValue('expiryDate'));
    _cvvController = TextEditingController(text: _customFieldValue('cvv'));
    _pinController = TextEditingController(text: _customFieldValue('pin'));

    // WiFi
    _ssidController = TextEditingController(text: _customFieldValue('ssid'));
    _wifiPasswordController =
        TextEditingController(text: _customFieldValue('wifiPassword'));
    _wifiSecurityType = _customFieldValue('securityType').isNotEmpty
        ? _customFieldValue('securityType')
        : 'WPA2';

    // Contact
    _contactNameController =
        TextEditingController(text: _customFieldValue('contactName'));
    _emailController = TextEditingController(text: _customFieldValue('email'));
    _phoneController = TextEditingController(text: _customFieldValue('phone'));
    _addressController =
        TextEditingController(text: _customFieldValue('address'));

    // Software License
    _softwareNameController =
        TextEditingController(text: _customFieldValue('softwareName'));
    _licenseKeyController =
        TextEditingController(text: _customFieldValue('licenseKey'));
    _versionController =
        TextEditingController(text: _customFieldValue('version'));
    _licensedToController =
        TextEditingController(text: _customFieldValue('licensedTo'));
    _licenseExpiryController =
        TextEditingController(text: _customFieldValue('licenseExpiry'));

    // For existing items, also populate name from type-specific name fields.
    if (item != null) {
      _populateNameFromItem(item);
    }

    // Initialize strength provider with current password.
    if (_passwordController.text.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref
            .read(currentPasswordProvider.notifier)
            .set(_passwordController.text);
      });
    }

    _passwordController.addListener(_onPasswordChanged);
  }

  /// Read a custom field value by name from the existing item's custom fields.
  String _customFieldValue(String name) {
    final existing = widget.existingItem?.customFields;
    if (existing == null) return '';
    final field = existing.where((f) => f.name == name).firstOrNull;
    return field?.value ?? '';
  }

  /// Populate name fields for editing existing items with type-specific names.
  void _populateNameFromItem(VaultItemEntity item) {
    switch (item.type) {
      case VaultItemType.secureNote:
        // For secure notes, the top-level name is the title.
        break;
      case VaultItemType.bankAccount:
        if (_bankNameController.text.isEmpty) {
          _bankNameController.text = item.name;
        }
        break;
      case VaultItemType.wifiPassword:
        if (_ssidController.text.isEmpty) {
          _ssidController.text = item.name;
        }
        break;
      case VaultItemType.contactInfo:
        if (_contactNameController.text.isEmpty) {
          _contactNameController.text = item.name;
        }
        break;
      case VaultItemType.softwareLicense:
        if (_softwareNameController.text.isEmpty) {
          _softwareNameController.text = item.name;
        }
        break;
      case VaultItemType.paymentCard:
        if (_cardNameController.text.isEmpty) {
          _cardNameController.text = item.name;
        }
        break;
      default:
        break;
    }
  }

  void _onPasswordChanged() {
    ref.read(currentPasswordProvider.notifier).set(_passwordController.text);
  }

  @override
  void dispose() {
    _passwordController.removeListener(_onPasswordChanged);
    _nameController.dispose();
    _urlController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _notesController.dispose();
    _contentController.dispose();
    _bankNameController.dispose();
    _accountHolderController.dispose();
    _accountNumberController.dispose();
    _routingNumberController.dispose();
    _swiftBicController.dispose();
    _cardNameController.dispose();
    _cardholderNameController.dispose();
    _cardNumberController.dispose();
    _expiryDateController.dispose();
    _cvvController.dispose();
    _pinController.dispose();
    _ssidController.dispose();
    _wifiPasswordController.dispose();
    _contactNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _softwareNameController.dispose();
    _licenseKeyController.dispose();
    _versionController.dispose();
    _licensedToController.dispose();
    _licenseExpiryController.dispose();
    super.dispose();
  }

  void _openPasswordGenerator() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => PasswordGeneratorSheet(
        onPasswordSelected: (password) {
          _passwordController.text = password;
        },
      ),
    );
  }

  /// Derive the item name from type-specific primary field.
  String _deriveItemName() {
    switch (_selectedType) {
      case VaultItemType.password:
        return _nameController.text.trim();
      case VaultItemType.secureNote:
        return _nameController.text.trim();
      case VaultItemType.bankAccount:
        return _bankNameController.text.trim();
      case VaultItemType.paymentCard:
        return _cardNameController.text.trim();
      case VaultItemType.wifiPassword:
        return _ssidController.text.trim();
      case VaultItemType.contactInfo:
        return _contactNameController.text.trim();
      case VaultItemType.softwareLicense:
        return _softwareNameController.text.trim();
    }
  }

  /// Build type-specific custom fields from controllers.
  List<CustomField> _buildTypeSpecificFields() {
    final fields = <CustomField>[];

    void addText(String name, String value) {
      if (value.isNotEmpty) {
        fields.add(CustomField(
          name: name,
          value: value,
          type: CustomFieldType.text,
        ));
      }
    }

    void addHidden(String name, String value) {
      if (value.isNotEmpty) {
        fields.add(CustomField(
          name: name,
          value: value,
          type: CustomFieldType.hidden,
        ));
      }
    }

    switch (_selectedType) {
      case VaultItemType.password:
        // All stored in top-level fields, no extra custom fields needed.
        break;
      case VaultItemType.secureNote:
        addText('content', _contentController.text.trim());
        break;
      case VaultItemType.bankAccount:
        addText('bankName', _bankNameController.text.trim());
        addText('accountHolder', _accountHolderController.text.trim());
        addHidden('accountNumber', _accountNumberController.text.trim());
        addText('routingNumber', _routingNumberController.text.trim());
        addText('swiftBic', _swiftBicController.text.trim());
        break;
      case VaultItemType.paymentCard:
        addText('cardName', _cardNameController.text.trim());
        addText('cardholderName', _cardholderNameController.text.trim());
        addHidden('cardNumber', _cardNumberController.text.trim());
        addText('expiryDate', _expiryDateController.text.trim());
        addHidden('cvv', _cvvController.text.trim());
        addHidden('pin', _pinController.text.trim());
        break;
      case VaultItemType.wifiPassword:
        addText('ssid', _ssidController.text.trim());
        addHidden('wifiPassword', _wifiPasswordController.text.trim());
        addText('securityType', _wifiSecurityType);
        break;
      case VaultItemType.contactInfo:
        addText('contactName', _contactNameController.text.trim());
        addText('email', _emailController.text.trim());
        addText('phone', _phoneController.text.trim());
        addText('address', _addressController.text.trim());
        break;
      case VaultItemType.softwareLicense:
        addText('softwareName', _softwareNameController.text.trim());
        addHidden('licenseKey', _licenseKeyController.text.trim());
        addText('version', _versionController.text.trim());
        addText('licensedTo', _licensedToController.text.trim());
        addText('licenseExpiry', _licenseExpiryController.text.trim());
        break;
    }

    // Append any user-added custom fields.
    fields.addAll(_customFields);
    return fields;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final session = ref.read(sessionProvider);
    if (session is! Unlocked) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vault is locked')),
        );
      }
      return;
    }

    setState(() => _isSaving = true);

    try {
      final vaultKey = SecretKey(session.vaultKey);
      final repo = ref.read(vaultRepositoryProvider);
      final now = DateTime.now();

      // Use the currently selected vault ID, or fall back to 'default'.
      final selectedVaultId =
          ref.read(multiVaultProvider).selectedVaultId ?? 'default';

      final allCustomFields = _buildTypeSpecificFields();
      final itemName = _deriveItemName();

      // For password type, use top-level url/username/password.
      // For other types, store password in notes or leave null.
      final entity = VaultItemEntity(
        id: widget.existingItem?.id ?? _generateId(),
        vaultId: widget.existingItem?.vaultId ?? selectedVaultId,
        name: itemName,
        url: _selectedType == VaultItemType.password
            ? (_urlController.text.trim().isEmpty
                ? null
                : _urlController.text.trim())
            : null,
        username: _selectedType == VaultItemType.password
            ? (_usernameController.text.trim().isEmpty
                ? null
                : _usernameController.text.trim())
            : null,
        password: _selectedType == VaultItemType.password
            ? (_passwordController.text.isEmpty
                ? null
                : _passwordController.text)
            : null,
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
        type: _selectedType,
        isFavorite: _isFavorite,
        customFields: allCustomFields.isEmpty ? null : allCustomFields,
        expiryDays: _selectedType == VaultItemType.password ? _expiryDays : null,
        createdAt: widget.existingItem?.createdAt ?? now,
        updatedAt: now,
      );

      if (_isCreateMode) {
        await repo.createItem(entity, vaultKey);
      } else {
        await repo.updateItem(entity, vaultKey);
      }

      // Refresh vault items.
      ref.read(multiVaultProvider.notifier).refreshItems();

      // Trigger immediate sync to PocketBase (write-through).
      ref.read(syncEngineProvider).syncNow();

      if (mounted) {
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving item: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          _isCreateMode ? 'New Item' : 'Edit Item',
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              setState(() => _isFavorite = !_isFavorite);
            },
            icon: Icon(
              _isFavorite ? Icons.star_rounded : Icons.star_outline_rounded,
              color: _isFavorite ? Colors.amber : null,
            ),
            tooltip: 'Favorite',
          ),
          TextButton(
            onPressed: _isSaving ? null : _save,
            child: _isSaving
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text(
                    'Save',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF4D4DCD),
                    ),
                  ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Item type selector
            DropdownButtonFormField<VaultItemType>(
              initialValue: _selectedType,
              decoration: _inputDecoration('Item Type'),
              items: VaultItemType.values.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(_itemTypeLabel(type)),
                );
              }).toList(),
              onChanged: (type) {
                if (type != null) setState(() => _selectedType = type);
              },
            ),
            const SizedBox(height: 16),

            // Type-specific fields
            ..._buildFieldsForType(_selectedType),

            const SizedBox(height: 24),

            // Custom fields section (user-added extras)
            CustomFieldsSection(
              fields: _customFields,
              onChanged: (fields) {
                setState(() => _customFields = fields);
              },
            ),

            // Password expiry (only for password type)
            if (_selectedType == VaultItemType.password) ...[
              const SizedBox(height: 24),
              Text(
                'Password Expiry',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<int?>(
                initialValue: _expiryDays,
                decoration: _inputDecoration('Expiry Period'),
                items: const [
                  DropdownMenuItem<int?>(value: null, child: Text('No expiry')),
                  DropdownMenuItem<int?>(value: 30, child: Text('30 days')),
                  DropdownMenuItem<int?>(value: 60, child: Text('60 days')),
                  DropdownMenuItem<int?>(value: 90, child: Text('90 days')),
                  DropdownMenuItem<int?>(value: 180, child: Text('180 days')),
                  DropdownMenuItem<int?>(value: 365, child: Text('365 days')),
                ],
                onChanged: (value) {
                  setState(() => _expiryDays = value);
                },
              ),
              const SizedBox(height: 24),
              // Password strength gauge
              if (_passwordController.text.isNotEmpty) ...[
                Text(
                  'Password Strength',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                const EntropyGauge(),
              ],
            ],
          ],
        ),
      ),
    );
  }

  /// Build form fields specific to the selected vault item type.
  List<Widget> _buildFieldsForType(VaultItemType type) {
    switch (type) {
      case VaultItemType.password:
        return _buildPasswordFields();
      case VaultItemType.secureNote:
        return _buildSecureNoteFields();
      case VaultItemType.bankAccount:
        return _buildBankAccountFields();
      case VaultItemType.paymentCard:
        return _buildPaymentCardFields();
      case VaultItemType.wifiPassword:
        return _buildWifiFields();
      case VaultItemType.contactInfo:
        return _buildContactFields();
      case VaultItemType.softwareLicense:
        return _buildSoftwareLicenseFields();
    }
  }

  List<Widget> _buildPasswordFields() {
    return [
      TextFormField(
        controller: _nameController,
        decoration: _inputDecoration('Name *'),
        validator: _requiredValidator,
      ),
      const SizedBox(height: 16),
      TextFormField(
        controller: _urlController,
        decoration: _inputDecoration('URL'),
        keyboardType: TextInputType.url,
      ),
      const SizedBox(height: 16),
      TextFormField(
        controller: _usernameController,
        decoration: _inputDecoration('Username'),
      ),
      const SizedBox(height: 16),
      TextFormField(
        controller: _passwordController,
        obscureText: !_passwordVisible,
        decoration: _inputDecoration('Password').copyWith(
          suffixIcon: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: () {
                  setState(() => _passwordVisible = !_passwordVisible);
                },
                icon: Icon(
                  _passwordVisible
                      ? Icons.visibility_off_rounded
                      : Icons.visibility_rounded,
                  size: 20,
                ),
              ),
              IconButton(
                onPressed: _openPasswordGenerator,
                icon: const Icon(Icons.auto_awesome_rounded, size: 20),
                tooltip: 'Generate Password',
              ),
            ],
          ),
        ),
      ),
      const SizedBox(height: 16),
      TextFormField(
        controller: _notesController,
        decoration: _inputDecoration('Notes'),
        maxLines: 3,
        keyboardType: TextInputType.multiline,
      ),
    ];
  }

  List<Widget> _buildSecureNoteFields() {
    return [
      TextFormField(
        controller: _nameController,
        decoration: _inputDecoration('Title *'),
        validator: _requiredValidator,
      ),
      const SizedBox(height: 16),
      TextFormField(
        controller: _contentController,
        decoration: _inputDecoration('Content'),
        maxLines: 8,
        minLines: 4,
        keyboardType: TextInputType.multiline,
      ),
    ];
  }

  List<Widget> _buildBankAccountFields() {
    return [
      TextFormField(
        controller: _bankNameController,
        decoration: _inputDecoration('Bank Name *'),
        validator: _requiredValidator,
      ),
      const SizedBox(height: 16),
      TextFormField(
        controller: _accountHolderController,
        decoration: _inputDecoration('Account Holder'),
      ),
      const SizedBox(height: 16),
      TextFormField(
        controller: _accountNumberController,
        decoration: _inputDecoration('Account Number'),
        keyboardType: TextInputType.number,
      ),
      const SizedBox(height: 16),
      TextFormField(
        controller: _routingNumberController,
        decoration: _inputDecoration('Routing Number'),
        keyboardType: TextInputType.number,
      ),
      const SizedBox(height: 16),
      TextFormField(
        controller: _swiftBicController,
        decoration: _inputDecoration('SWIFT / BIC'),
      ),
      const SizedBox(height: 16),
      TextFormField(
        controller: _notesController,
        decoration: _inputDecoration('Notes'),
        maxLines: 3,
        keyboardType: TextInputType.multiline,
      ),
    ];
  }

  List<Widget> _buildPaymentCardFields() {
    return [
      TextFormField(
        controller: _cardNameController,
        decoration: _inputDecoration('Card Name *'),
        validator: _requiredValidator,
      ),
      const SizedBox(height: 16),
      TextFormField(
        controller: _cardholderNameController,
        decoration: _inputDecoration('Cardholder Name'),
      ),
      const SizedBox(height: 16),
      TextFormField(
        controller: _cardNumberController,
        decoration: _inputDecoration('Card Number'),
        keyboardType: TextInputType.number,
      ),
      const SizedBox(height: 16),
      Row(
        children: [
          Expanded(
            child: TextFormField(
              controller: _expiryDateController,
              decoration: _inputDecoration('Expiry (MM/YY)'),
              keyboardType: TextInputType.datetime,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextFormField(
              controller: _cvvController,
              decoration: _inputDecoration('CVV'),
              keyboardType: TextInputType.number,
              obscureText: true,
            ),
          ),
        ],
      ),
      const SizedBox(height: 16),
      TextFormField(
        controller: _pinController,
        decoration: _inputDecoration('PIN'),
        keyboardType: TextInputType.number,
        obscureText: true,
      ),
      const SizedBox(height: 16),
      TextFormField(
        controller: _notesController,
        decoration: _inputDecoration('Notes'),
        maxLines: 3,
        keyboardType: TextInputType.multiline,
      ),
    ];
  }

  List<Widget> _buildWifiFields() {
    return [
      TextFormField(
        controller: _ssidController,
        decoration: _inputDecoration('Network Name (SSID) *'),
        validator: _requiredValidator,
      ),
      const SizedBox(height: 16),
      TextFormField(
        controller: _wifiPasswordController,
        decoration: _inputDecoration('Password'),
        obscureText: !_passwordVisible,
      ),
      const SizedBox(height: 16),
      DropdownButtonFormField<String>(
        initialValue: _wifiSecurityType,
        decoration: _inputDecoration('Security Type'),
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
        decoration: _inputDecoration('Notes'),
        maxLines: 3,
        keyboardType: TextInputType.multiline,
      ),
    ];
  }

  List<Widget> _buildContactFields() {
    return [
      TextFormField(
        controller: _contactNameController,
        decoration: _inputDecoration('Name *'),
        validator: _requiredValidator,
      ),
      const SizedBox(height: 16),
      TextFormField(
        controller: _emailController,
        decoration: _inputDecoration('Email'),
        keyboardType: TextInputType.emailAddress,
      ),
      const SizedBox(height: 16),
      TextFormField(
        controller: _phoneController,
        decoration: _inputDecoration('Phone'),
        keyboardType: TextInputType.phone,
      ),
      const SizedBox(height: 16),
      TextFormField(
        controller: _addressController,
        decoration: _inputDecoration('Address'),
        maxLines: 2,
        keyboardType: TextInputType.streetAddress,
      ),
      const SizedBox(height: 16),
      TextFormField(
        controller: _notesController,
        decoration: _inputDecoration('Notes'),
        maxLines: 3,
        keyboardType: TextInputType.multiline,
      ),
    ];
  }

  List<Widget> _buildSoftwareLicenseFields() {
    return [
      TextFormField(
        controller: _softwareNameController,
        decoration: _inputDecoration('Software Name *'),
        validator: _requiredValidator,
      ),
      const SizedBox(height: 16),
      TextFormField(
        controller: _licenseKeyController,
        decoration: _inputDecoration('License Key'),
      ),
      const SizedBox(height: 16),
      TextFormField(
        controller: _versionController,
        decoration: _inputDecoration('Version'),
      ),
      const SizedBox(height: 16),
      TextFormField(
        controller: _licensedToController,
        decoration: _inputDecoration('Licensed To'),
      ),
      const SizedBox(height: 16),
      TextFormField(
        controller: _licenseExpiryController,
        decoration: _inputDecoration('Expiry Date'),
        keyboardType: TextInputType.datetime,
      ),
      const SizedBox(height: 16),
      TextFormField(
        controller: _notesController,
        decoration: _inputDecoration('Notes'),
        maxLines: 3,
        keyboardType: TextInputType.multiline,
      ),
    ];
  }

  String? _requiredValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'This field is required';
    }
    return null;
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(fontFamily: 'Poppins'),
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFF4D4DCD), width: 2),
      ),
    );
  }

  /// Generate a random hex ID (32 chars).
  String _generateId() {
    final random = Random.secure();
    final bytes = List<int>.generate(16, (_) => random.nextInt(256));
    return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }

  String _itemTypeLabel(VaultItemType type) {
    switch (type) {
      case VaultItemType.password:
        return 'Password';
      case VaultItemType.secureNote:
        return 'Secure Note';
      case VaultItemType.contactInfo:
        return 'Contact Info';
      case VaultItemType.bankAccount:
        return 'Bank Account';
      case VaultItemType.paymentCard:
        return 'Payment Card';
      case VaultItemType.wifiPassword:
        return 'WiFi Password';
      case VaultItemType.softwareLicense:
        return 'Software License';
    }
  }
}
