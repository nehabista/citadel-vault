import 'package:cryptography/cryptography.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../widgets/citadel_snackbar.dart';
import '../../../core/providers/core_providers.dart';
import '../../../core/providers/session_provider.dart';
import '../../../core/providers/sync_providers.dart';
import '../../../core/session/session_state.dart';
import '../../../features/password_generator/presentation/providers/strength_provider.dart';
import '../../../features/password_generator/presentation/widgets/entropy_gauge.dart';
import '../../../features/vault/domain/entities/custom_field.dart';
import '../../../features/vault/domain/entities/vault_item.dart';
import '../../../features/vault/presentation/providers/multi_vault_provider.dart';
import 'utils/form_decoration.dart';
import 'utils/id_generator.dart';
import 'utils/type_form_mixin.dart';
import 'widgets/bank_account_form_fields.dart';
import 'widgets/contact_form_fields.dart';
import 'widgets/custom_fields_section.dart';
import 'widgets/identity_form_fields.dart';
import 'widgets/license_form_fields.dart';
import 'widgets/misc_form_fields.dart';
import 'widgets/password_form_fields.dart';
import 'widgets/payment_card_form_fields.dart';
import 'widgets/secure_note_form_fields.dart';
import 'widgets/ssh_key_form_fields.dart';
import 'widgets/wifi_form_fields.dart';

/// Page for creating or editing a vault item.
///
/// If [existingItem] is null, operates in create mode.
/// Otherwise operates in edit mode with pre-filled fields.
///
/// Shows type-specific form fields based on the selected [VaultItemType].
/// Each type's form is a self-contained widget that owns its own controllers
/// and exposes [TypeFormContract] via a [GlobalKey].
class VaultItemEditPage extends ConsumerStatefulWidget {
  const VaultItemEditPage({super.key, this.existingItem, this.initialType});

  final VaultItemEntity? existingItem;
  final VaultItemType? initialType;

  @override
  ConsumerState<VaultItemEditPage> createState() => _VaultItemEditPageState();
}

class _VaultItemEditPageState extends ConsumerState<VaultItemEditPage> {
  final _formKey = GlobalKey<FormState>();

  late VaultItemType _selectedType;
  late bool _isFavorite;
  late List<CustomField> _customFields;
  late int? _expiryDays;
  bool _isSaving = false;

  // --- GlobalKeys for each type-specific form widget ---
  // These are used to call getName() / getCustomFields() on save.
  final _passwordKey = GlobalKey<PasswordFormFieldsState>();
  final _secureNoteKey = GlobalKey<SecureNoteFormFieldsState>();
  final _bankAccountKey = GlobalKey<BankAccountFormFieldsState>();
  final _paymentCardKey = GlobalKey<PaymentCardFormFieldsState>();
  final _wifiKey = GlobalKey<WifiFormFieldsState>();
  final _contactKey = GlobalKey<ContactFormFieldsState>();
  final _licenseKey = GlobalKey<SoftwareLicenseFormFieldsState>();
  final _sshKeyKey = GlobalKey<SshKeyFormFieldsState>();
  final _identityKey = GlobalKey<IdentityFormFieldsState>();
  final _miscKey = GlobalKey<MiscFormFieldsState>();

  bool get _isCreateMode => widget.existingItem == null;

  @override
  void initState() {
    super.initState();
    final item = widget.existingItem;
    _selectedType = item?.type ?? widget.initialType ?? VaultItemType.password;
    _isFavorite = item?.isFavorite ?? false;
    _customFields = List.of(item?.customFields ?? []);
    _expiryDays = item?.expiryDays;
  }

  /// Get the active [TypeFormContract] from the currently-visible form widget.
  TypeFormContract? get _activeForm {
    switch (_selectedType) {
      case VaultItemType.password:
        return _passwordKey.currentState;
      case VaultItemType.secureNote:
        return _secureNoteKey.currentState;
      case VaultItemType.bankAccount:
        return _bankAccountKey.currentState;
      case VaultItemType.paymentCard:
        return _paymentCardKey.currentState;
      case VaultItemType.wifiPassword:
        return _wifiKey.currentState;
      case VaultItemType.contactInfo:
        return _contactKey.currentState;
      case VaultItemType.softwareLicense:
        return _licenseKey.currentState;
      case VaultItemType.sshKey:
        return _sshKeyKey.currentState;
      case VaultItemType.driversLicense:
      case VaultItemType.passport:
      case VaultItemType.socialSecurityNumber:
        return _identityKey.currentState;
      case VaultItemType.healthInsurance:
      case VaultItemType.insurancePolicy:
      case VaultItemType.membershipCard:
      case VaultItemType.emailAccount:
      case VaultItemType.instantMessenger:
      case VaultItemType.database:
      case VaultItemType.server:
        return _miscKey.currentState;
    }
  }

  /// Get the notes from the active form widget (each form owns its own notes
  /// controller, except password which uses top-level fields).
  String? _getNotesFromActiveForm() {
    switch (_selectedType) {
      case VaultItemType.password:
        return _passwordKey.currentState?.getNotes();
      case VaultItemType.secureNote:
        return _secureNoteKey.currentState?.getNotes();
      case VaultItemType.bankAccount:
        return _bankAccountKey.currentState?.getNotes();
      case VaultItemType.paymentCard:
        return _paymentCardKey.currentState?.getNotes();
      case VaultItemType.wifiPassword:
        return _wifiKey.currentState?.getNotes();
      case VaultItemType.contactInfo:
        return _contactKey.currentState?.getNotes();
      case VaultItemType.softwareLicense:
        return _licenseKey.currentState?.getNotes();
      case VaultItemType.sshKey:
        return _sshKeyKey.currentState?.getNotes();
      case VaultItemType.driversLicense:
      case VaultItemType.passport:
      case VaultItemType.socialSecurityNumber:
        return _identityKey.currentState?.getNotes();
      case VaultItemType.healthInsurance:
      case VaultItemType.insurancePolicy:
      case VaultItemType.membershipCard:
      case VaultItemType.emailAccount:
      case VaultItemType.instantMessenger:
      case VaultItemType.database:
      case VaultItemType.server:
        return _miscKey.currentState?.getNotes();
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final session = ref.read(sessionProvider);
    if (session is! Unlocked) {
      if (mounted) {
        showCitadelSnackBar(context, 'Vault is locked',
            type: SnackBarType.error);
      }
      return;
    }

    final form = _activeForm;
    if (form == null) return;

    setState(() => _isSaving = true);

    try {
      final vaultKey = SecretKey(session.vaultKey);
      final repo = ref.read(vaultRepositoryProvider);
      final now = DateTime.now();

      final selectedVaultId =
          ref.read(multiVaultProvider).selectedVaultId ?? 'default';

      final typeFields = form.getCustomFields();
      final allCustomFields = [...typeFields, ..._customFields];
      final itemName = form.getName();

      // For password type, use top-level url/username/password from the
      // PasswordFormFields widget. For other types, leave null.
      String? url;
      String? username;
      String? password;
      if (_selectedType == VaultItemType.password) {
        final pwState = _passwordKey.currentState;
        url = pwState?.getUrl();
        username = pwState?.getUsername();
        password = pwState?.getPassword();
      }

      final notes = _getNotesFromActiveForm();

      final entity = VaultItemEntity(
        id: widget.existingItem?.id ?? generateVaultItemId(),
        vaultId: widget.existingItem?.vaultId ?? selectedVaultId,
        name: itemName,
        url: url,
        username: username,
        password: password,
        notes: notes,
        type: _selectedType,
        isFavorite: _isFavorite,
        customFields: allCustomFields.isEmpty ? null : allCustomFields,
        expiryDays:
            _selectedType == VaultItemType.password ? _expiryDays : null,
        createdAt: widget.existingItem?.createdAt ?? now,
        updatedAt: now,
      );

      if (_isCreateMode) {
        await repo.createItem(entity, vaultKey);
      } else {
        await repo.updateItem(entity, vaultKey);
      }

      ref.read(multiVaultProvider.notifier).refreshItems();
      ref.read(syncEngineProvider).syncNow();

      if (mounted) {
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        showCitadelSnackBar(context, 'Error saving item: $e',
            type: SnackBarType.error);
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
              decoration: citadelInputDecoration('Item Type'),
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

            // Type-specific fields — each is a self-contained widget
            _buildFormForType(_selectedType),

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
                decoration: citadelInputDecoration('Expiry Period'),
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
              // Password strength gauge — only when text is present.
              // The PasswordFormFields widget drives currentPasswordProvider.
              Consumer(
                builder: (context, ref, _) {
                  final pw = ref.watch(currentPasswordProvider);
                  if (pw.isEmpty) return const SizedBox.shrink();
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Build the form widget for the given type, keyed so state persists
  /// across rebuilds (but not across type changes, which is correct).
  Widget _buildFormForType(VaultItemType type) {
    switch (type) {
      case VaultItemType.password:
        return PasswordFormFields(
          key: _passwordKey,
          existingItem: widget.existingItem,
        );
      case VaultItemType.secureNote:
        return SecureNoteFormFields(
          key: _secureNoteKey,
          existingItem: widget.existingItem,
        );
      case VaultItemType.bankAccount:
        return BankAccountFormFields(
          key: _bankAccountKey,
          existingItem: widget.existingItem,
        );
      case VaultItemType.paymentCard:
        return PaymentCardFormFields(
          key: _paymentCardKey,
          existingItem: widget.existingItem,
        );
      case VaultItemType.wifiPassword:
        return WifiFormFields(
          key: _wifiKey,
          existingItem: widget.existingItem,
        );
      case VaultItemType.contactInfo:
        return ContactFormFields(
          key: _contactKey,
          existingItem: widget.existingItem,
        );
      case VaultItemType.softwareLicense:
        return SoftwareLicenseFormFields(
          key: _licenseKey,
          existingItem: widget.existingItem,
        );
      case VaultItemType.sshKey:
        return SshKeyFormFields(
          key: _sshKeyKey,
          existingItem: widget.existingItem,
        );
      case VaultItemType.driversLicense:
      case VaultItemType.passport:
      case VaultItemType.socialSecurityNumber:
        return IdentityFormFields(
          key: _identityKey,
          identityType: type,
          existingItem: widget.existingItem,
        );
      case VaultItemType.healthInsurance:
      case VaultItemType.insurancePolicy:
      case VaultItemType.membershipCard:
      case VaultItemType.emailAccount:
      case VaultItemType.instantMessenger:
      case VaultItemType.database:
      case VaultItemType.server:
        return MiscFormFields(
          key: _miscKey,
          miscType: type,
          existingItem: widget.existingItem,
        );
    }
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
      case VaultItemType.sshKey:
        return 'SSH Key';
      case VaultItemType.driversLicense:
        return 'Drivers License';
      case VaultItemType.passport:
        return 'Passport';
      case VaultItemType.socialSecurityNumber:
        return 'Social Security Number';
      case VaultItemType.healthInsurance:
        return 'Health Insurance';
      case VaultItemType.insurancePolicy:
        return 'Insurance Policy';
      case VaultItemType.membershipCard:
        return 'Membership Card';
      case VaultItemType.emailAccount:
        return 'Email Account';
      case VaultItemType.instantMessenger:
        return 'Instant Messenger';
      case VaultItemType.database:
        return 'Database';
      case VaultItemType.server:
        return 'Server';
    }
  }
}
