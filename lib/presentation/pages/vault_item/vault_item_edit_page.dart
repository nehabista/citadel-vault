import 'dart:async';
import 'dart:math';

import 'package:cryptography/cryptography.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../widgets/citadel_snackbar.dart';

import '../../../features/ssh_keys/data/models/ssh_key_data.dart';
import '../../../features/ssh_keys/presentation/providers/ssh_key_providers.dart';
import '../../../core/providers/core_providers.dart';
import '../../../features/security/domain/entities/breach_result.dart';
import '../../../core/providers/session_provider.dart';
import '../../../core/providers/sync_providers.dart';
import '../../../core/session/session_state.dart';
import '../../../features/password_generator/presentation/providers/strength_provider.dart';
import '../../../features/password_generator/presentation/widgets/entropy_gauge.dart';
import '../../../features/password_generator/presentation/widgets/password_generator_sheet.dart';
import '../../../features/vault/data/services/logo_search_service.dart';
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

  // --- Drivers License ---
  late final TextEditingController _dlNameController;
  late final TextEditingController _dlNumberController;
  late final TextEditingController _dlStateController;
  late final TextEditingController _dlExpiryController;
  late final TextEditingController _dlDobController;

  // --- Passport ---
  late final TextEditingController _passportNameController;
  late final TextEditingController _passportNumberController;
  late final TextEditingController _passportCountryController;
  late final TextEditingController _passportExpiryController;
  late final TextEditingController _passportDobController;

  // --- Social Security Number ---
  late final TextEditingController _ssnNameController;
  late final TextEditingController _ssnNumberController;

  // --- Health Insurance ---
  late final TextEditingController _hiProviderController;
  late final TextEditingController _hiPolicyController;
  late final TextEditingController _hiGroupController;
  late final TextEditingController _hiMemberIdController;

  // --- Insurance Policy ---
  late final TextEditingController _ipCompanyController;
  late final TextEditingController _ipPolicyController;
  late final TextEditingController _ipTypeController;
  late final TextEditingController _ipExpiryController;

  // --- Membership Card ---
  late final TextEditingController _mcOrgController;
  late final TextEditingController _mcMemberIdController;
  late final TextEditingController _mcMemberNameController;
  late final TextEditingController _mcExpiryController;

  // --- Email Account ---
  late final TextEditingController _eaEmailController;
  late final TextEditingController _eaPasswordController;
  late final TextEditingController _eaServerController;
  late final TextEditingController _eaPortController;

  // --- Instant Messenger ---
  late final TextEditingController _imServiceController;
  late final TextEditingController _imUsernameController;
  late final TextEditingController _imPasswordController;

  // --- Database ---
  late final TextEditingController _dbNameController;
  late final TextEditingController _dbHostController;
  late final TextEditingController _dbPortController;
  late final TextEditingController _dbDbNameController;
  late final TextEditingController _dbUsernameController;
  late final TextEditingController _dbPasswordController;

  // --- Server ---
  late final TextEditingController _srvNameController;
  late final TextEditingController _srvHostController;
  late final TextEditingController _srvPortController;
  late final TextEditingController _srvUsernameController;
  late final TextEditingController _srvPasswordController;

  // --- SSH Key ---
  late final TextEditingController _sshNameController;
  late final TextEditingController _sshPublicKeyController;
  late final TextEditingController _sshPrivateKeyController;
  late final TextEditingController _sshFingerprintController;
  late final TextEditingController _sshCommentController;
  late final TextEditingController _sshPassphraseController;
  late final TextEditingController _sshImportController;
  String _sshKeyType = 'ed25519'; // 'ed25519' or 'rsa4096'
  bool _sshGenerating = false;
  bool _sshPrivateKeyVisible = false;
  bool _sshPassphraseVisible = false;
  bool _sshImportMode = false;

  late VaultItemType _selectedType;
  late bool _isFavorite;
  late List<CustomField> _customFields;
  late int? _expiryDays;
  bool _passwordVisible = false;
  bool _isSaving = false;

  // Breach check state
  Timer? _breachDebounce;
  int? _breachCount; // null = not checked yet, 0 = clean, >0 = breached
  bool _breachChecking = false;

  // Logo search state (Password type only)
  Timer? _logoDebounce;
  List<LogoResult> _logoResults = [];
  String? _selectedLogoUrl;
  final LayerLink _logoLayerLink = LayerLink();
  OverlayEntry? _logoOverlayEntry;

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

    // Drivers License
    _dlNameController =
        TextEditingController(text: _customFieldValue('dlName'));
    _dlNumberController =
        TextEditingController(text: _customFieldValue('dlNumber'));
    _dlStateController =
        TextEditingController(text: _customFieldValue('dlState'));
    _dlExpiryController =
        TextEditingController(text: _customFieldValue('dlExpiry'));
    _dlDobController =
        TextEditingController(text: _customFieldValue('dlDob'));

    // Passport
    _passportNameController =
        TextEditingController(text: _customFieldValue('passportName'));
    _passportNumberController =
        TextEditingController(text: _customFieldValue('passportNumber'));
    _passportCountryController =
        TextEditingController(text: _customFieldValue('passportCountry'));
    _passportExpiryController =
        TextEditingController(text: _customFieldValue('passportExpiry'));
    _passportDobController =
        TextEditingController(text: _customFieldValue('passportDob'));

    // Social Security Number
    _ssnNameController =
        TextEditingController(text: _customFieldValue('ssnName'));
    _ssnNumberController =
        TextEditingController(text: _customFieldValue('ssnNumber'));

    // Health Insurance
    _hiProviderController =
        TextEditingController(text: _customFieldValue('hiProvider'));
    _hiPolicyController =
        TextEditingController(text: _customFieldValue('hiPolicy'));
    _hiGroupController =
        TextEditingController(text: _customFieldValue('hiGroup'));
    _hiMemberIdController =
        TextEditingController(text: _customFieldValue('hiMemberId'));

    // Insurance Policy
    _ipCompanyController =
        TextEditingController(text: _customFieldValue('ipCompany'));
    _ipPolicyController =
        TextEditingController(text: _customFieldValue('ipPolicy'));
    _ipTypeController =
        TextEditingController(text: _customFieldValue('ipType'));
    _ipExpiryController =
        TextEditingController(text: _customFieldValue('ipExpiry'));

    // Membership Card
    _mcOrgController =
        TextEditingController(text: _customFieldValue('mcOrg'));
    _mcMemberIdController =
        TextEditingController(text: _customFieldValue('mcMemberId'));
    _mcMemberNameController =
        TextEditingController(text: _customFieldValue('mcMemberName'));
    _mcExpiryController =
        TextEditingController(text: _customFieldValue('mcExpiry'));

    // Email Account
    _eaEmailController =
        TextEditingController(text: _customFieldValue('eaEmail'));
    _eaPasswordController =
        TextEditingController(text: _customFieldValue('eaPassword'));
    _eaServerController =
        TextEditingController(text: _customFieldValue('eaServer'));
    _eaPortController =
        TextEditingController(text: _customFieldValue('eaPort'));

    // Instant Messenger
    _imServiceController =
        TextEditingController(text: _customFieldValue('imService'));
    _imUsernameController =
        TextEditingController(text: _customFieldValue('imUsername'));
    _imPasswordController =
        TextEditingController(text: _customFieldValue('imPassword'));

    // Database
    _dbNameController =
        TextEditingController(text: _customFieldValue('dbName'));
    _dbHostController =
        TextEditingController(text: _customFieldValue('dbHost'));
    _dbPortController =
        TextEditingController(text: _customFieldValue('dbPort'));
    _dbDbNameController =
        TextEditingController(text: _customFieldValue('dbDbName'));
    _dbUsernameController =
        TextEditingController(text: _customFieldValue('dbUsername'));
    _dbPasswordController =
        TextEditingController(text: _customFieldValue('dbPassword'));

    // Server
    _srvNameController =
        TextEditingController(text: _customFieldValue('srvName'));
    _srvHostController =
        TextEditingController(text: _customFieldValue('srvHost'));
    _srvPortController =
        TextEditingController(text: _customFieldValue('srvPort'));
    _srvUsernameController =
        TextEditingController(text: _customFieldValue('srvUsername'));
    _srvPasswordController =
        TextEditingController(text: _customFieldValue('srvPassword'));

    // SSH Key
    _sshNameController =
        TextEditingController(text: _customFieldValue('sshName'));
    _sshPublicKeyController =
        TextEditingController(text: _customFieldValue('publicKey'));
    _sshPrivateKeyController =
        TextEditingController(text: _customFieldValue('privateKey'));
    _sshFingerprintController =
        TextEditingController(text: _customFieldValue('fingerprint'));
    _sshCommentController =
        TextEditingController(text: _customFieldValue('comment'));
    _sshPassphraseController =
        TextEditingController(text: _customFieldValue('passphrase'));
    _sshImportController = TextEditingController();
    final existingKeyType = _customFieldValue('keyType');
    if (existingKeyType.isNotEmpty) {
      _sshKeyType = existingKeyType;
    }

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
        // Trigger initial breach check for existing passwords.
        _debouncedBreachCheck();
      });
    }

    _passwordController.addListener(_onPasswordChanged);

    // Initialize logo URL from existing custom fields.
    final existingLogoUrl = _customFieldValue('logoUrl');
    if (existingLogoUrl.isNotEmpty) {
      _selectedLogoUrl = existingLogoUrl;
    }

    // Add logo search listener for password type.
    _nameController.addListener(_onNameChangedForLogo);
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
      case VaultItemType.sshKey:
        if (_sshNameController.text.isEmpty) {
          _sshNameController.text = item.name;
        }
        break;
      default:
        break;
    }
  }

  void _onPasswordChanged() {
    ref.read(currentPasswordProvider.notifier).set(_passwordController.text);
    _debouncedBreachCheck();
  }

  void _debouncedBreachCheck() {
    _breachDebounce?.cancel();
    final password = _passwordController.text;

    if (password.isEmpty) {
      setState(() {
        _breachCount = null;
        _breachChecking = false;
      });
      return;
    }

    setState(() => _breachChecking = true);

    _breachDebounce = Timer(const Duration(milliseconds: 500), () async {
      if (!mounted) return;
      try {
        final breachRepo = ref.read(breachRepositoryProvider);
        final result = await breachRepo.checkPasswordCached(password);
        if (!mounted) return;
        setState(() {
          _breachCount =
              result is BreachResultBreached ? result.count : 0;
          _breachChecking = false;
        });
      } catch (_) {
        if (!mounted) return;
        setState(() {
          _breachCount = null;
          _breachChecking = false;
        });
      }
    });
  }

  void _onNameChangedForLogo() {
    if (_selectedType != VaultItemType.password) return;
    _logoDebounce?.cancel();
    final query = _nameController.text.trim();
    if (query.length < 2) {
      _removeLogoOverlay();
      setState(() => _logoResults = []);
      return;
    }
    _logoDebounce = Timer(const Duration(milliseconds: 300), () async {
      if (!mounted) return;
      final service = ref.read(logoSearchServiceProvider);
      final results = await service.search(query);
      if (!mounted) return;
      setState(() => _logoResults = results);
      if (results.isNotEmpty) {
        _showLogoOverlay();
      } else {
        _removeLogoOverlay();
      }
    });
  }

  void _showLogoOverlay() {
    _removeLogoOverlay();
    final overlay = Overlay.of(context);
    _logoOverlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        width: MediaQuery.of(context).size.width - 32,
        child: CompositedTransformFollower(
          link: _logoLayerLink,
          showWhenUnlinked: false,
          offset: const Offset(0, 60),
          child: Material(
            elevation: 8,
            shadowColor: Colors.black26,
            borderRadius: BorderRadius.circular(14),
            color: Colors.white,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 220),
              child: ListView.builder(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(vertical: 6),
                itemCount: _logoResults.length,
                itemBuilder: (context, index) {
                  final result = _logoResults[index];
                  return InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: () => _selectLogoResult(result),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              result.logoUrl,
                              width: 24,
                              height: 24,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF4D4DCD)
                                      .withAlpha(25),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.language_rounded,
                                  size: 14,
                                  color: Color(0xFF4D4DCD),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  result.name,
                                  style: const TextStyle(
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                    color: Color(0xFF1A1A2E),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  result.domain,
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 12,
                                    color: Colors.grey.shade500,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
    overlay.insert(_logoOverlayEntry!);
  }

  void _removeLogoOverlay() {
    _logoOverlayEntry?.remove();
    _logoOverlayEntry = null;
  }

  void _selectLogoResult(LogoResult result) {
    _removeLogoOverlay();
    _nameController.removeListener(_onNameChangedForLogo);
    _nameController.text = result.name;
    _nameController.addListener(_onNameChangedForLogo);
    _urlController.text = 'https://${result.domain}';
    setState(() {
      _selectedLogoUrl = result.logoUrl;
      _logoResults = [];
    });
  }

  @override
  void dispose() {
    _breachDebounce?.cancel();
    _logoDebounce?.cancel();
    _removeLogoOverlay();
    _nameController.removeListener(_onNameChangedForLogo);
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
    _hiProviderController.dispose();
    _hiPolicyController.dispose();
    _hiGroupController.dispose();
    _hiMemberIdController.dispose();
    _ipCompanyController.dispose();
    _ipPolicyController.dispose();
    _ipTypeController.dispose();
    _ipExpiryController.dispose();
    _mcOrgController.dispose();
    _mcMemberIdController.dispose();
    _mcMemberNameController.dispose();
    _mcExpiryController.dispose();
    _eaEmailController.dispose();
    _eaPasswordController.dispose();
    _eaServerController.dispose();
    _eaPortController.dispose();
    _imServiceController.dispose();
    _imUsernameController.dispose();
    _imPasswordController.dispose();
    _dbNameController.dispose();
    _dbHostController.dispose();
    _dbPortController.dispose();
    _dbDbNameController.dispose();
    _dbUsernameController.dispose();
    _dbPasswordController.dispose();
    _srvNameController.dispose();
    _srvHostController.dispose();
    _srvPortController.dispose();
    _srvUsernameController.dispose();
    _srvPasswordController.dispose();
    _sshNameController.dispose();
    _sshPublicKeyController.dispose();
    _sshPrivateKeyController.dispose();
    _sshFingerprintController.dispose();
    _sshCommentController.dispose();
    _sshPassphraseController.dispose();
    _sshImportController.dispose();
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
      case VaultItemType.sshKey:
        return _sshNameController.text.trim();
      case VaultItemType.driversLicense:
        return _dlNameController.text.trim();
      case VaultItemType.passport:
        return _passportNameController.text.trim();
      case VaultItemType.socialSecurityNumber:
        return _ssnNameController.text.trim();
      case VaultItemType.healthInsurance:
        return _hiProviderController.text.trim();
      case VaultItemType.insurancePolicy:
        return _ipCompanyController.text.trim();
      case VaultItemType.membershipCard:
        return _mcOrgController.text.trim();
      case VaultItemType.emailAccount:
        return _eaEmailController.text.trim();
      case VaultItemType.instantMessenger:
        return _imServiceController.text.trim();
      case VaultItemType.database:
        return _dbNameController.text.trim();
      case VaultItemType.server:
        return _srvNameController.text.trim();
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
        // Store logo URL if selected.
        if (_selectedLogoUrl != null && _selectedLogoUrl!.isNotEmpty) {
          addText('logoUrl', _selectedLogoUrl!);
        }
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
      case VaultItemType.sshKey:
        addText('sshName', _sshNameController.text.trim());
        addHidden('privateKey', _sshPrivateKeyController.text.trim());
        addText('publicKey', _sshPublicKeyController.text.trim());
        addText('keyType', _sshKeyType);
        addText('fingerprint', _sshFingerprintController.text.trim());
        addText('comment', _sshCommentController.text.trim());
        addHidden('passphrase', _sshPassphraseController.text.trim());
        break;
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
      case VaultItemType.healthInsurance:
        addText('hiProvider', _hiProviderController.text.trim());
        addText('hiPolicy', _hiPolicyController.text.trim());
        addText('hiGroup', _hiGroupController.text.trim());
        addText('hiMemberId', _hiMemberIdController.text.trim());
        break;
      case VaultItemType.insurancePolicy:
        addText('ipCompany', _ipCompanyController.text.trim());
        addText('ipPolicy', _ipPolicyController.text.trim());
        addText('ipType', _ipTypeController.text.trim());
        addText('ipExpiry', _ipExpiryController.text.trim());
        break;
      case VaultItemType.membershipCard:
        addText('mcOrg', _mcOrgController.text.trim());
        addText('mcMemberId', _mcMemberIdController.text.trim());
        addText('mcMemberName', _mcMemberNameController.text.trim());
        addText('mcExpiry', _mcExpiryController.text.trim());
        break;
      case VaultItemType.emailAccount:
        addText('eaEmail', _eaEmailController.text.trim());
        addHidden('eaPassword', _eaPasswordController.text.trim());
        addText('eaServer', _eaServerController.text.trim());
        addText('eaPort', _eaPortController.text.trim());
        break;
      case VaultItemType.instantMessenger:
        addText('imService', _imServiceController.text.trim());
        addText('imUsername', _imUsernameController.text.trim());
        addHidden('imPassword', _imPasswordController.text.trim());
        break;
      case VaultItemType.database:
        addText('dbName', _dbNameController.text.trim());
        addText('dbHost', _dbHostController.text.trim());
        addText('dbPort', _dbPortController.text.trim());
        addText('dbDbName', _dbDbNameController.text.trim());
        addText('dbUsername', _dbUsernameController.text.trim());
        addHidden('dbPassword', _dbPasswordController.text.trim());
        break;
      case VaultItemType.server:
        addText('srvName', _srvNameController.text.trim());
        addText('srvHost', _srvHostController.text.trim());
        addText('srvPort', _srvPortController.text.trim());
        addText('srvUsername', _srvUsernameController.text.trim());
        addHidden('srvPassword', _srvPasswordController.text.trim());
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
        showCitadelSnackBar(context, 'Vault is locked',
            type: SnackBarType.error);
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
      case VaultItemType.sshKey:
        return _buildSshKeyFields();
      case VaultItemType.driversLicense:
        return _buildDriversLicenseFields();
      case VaultItemType.passport:
        return _buildPassportFields();
      case VaultItemType.socialSecurityNumber:
        return _buildSocialSecurityNumberFields();
      case VaultItemType.healthInsurance:
        return _buildHealthInsuranceFields();
      case VaultItemType.insurancePolicy:
        return _buildInsurancePolicyFields();
      case VaultItemType.membershipCard:
        return _buildMembershipCardFields();
      case VaultItemType.emailAccount:
        return _buildEmailAccountFields();
      case VaultItemType.instantMessenger:
        return _buildInstantMessengerFields();
      case VaultItemType.database:
        return _buildDatabaseFields();
      case VaultItemType.server:
        return _buildServerFields();
    }
  }

  List<Widget> _buildPasswordFields() {
    return [
      CompositedTransformTarget(
        link: _logoLayerLink,
        child: TextFormField(
          controller: _nameController,
          decoration: _inputDecoration('Name *').copyWith(
            prefixIcon: _selectedLogoUrl != null &&
                    _selectedLogoUrl!.isNotEmpty
                ? Padding(
                    padding: const EdgeInsets.all(8),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        _selectedLogoUrl!,
                        width: 32,
                        height: 32,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: const Color(0xFF4D4DCD).withAlpha(25),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.lock_outline,
                            size: 18,
                            color: Color(0xFF4D4DCD),
                          ),
                        ),
                      ),
                    ),
                  )
                : null,
          ),
          validator: _requiredValidator,
        ),
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
      // Inline breach warning
      if (_breachChecking)
        const Padding(
          padding: EdgeInsets.only(top: 6, left: 4),
          child: Row(
            children: [
              SizedBox(
                width: 12,
                height: 12,
                child: CircularProgressIndicator(
                  strokeWidth: 1.5,
                  color: Color(0xFF9E9E9E),
                ),
              ),
              SizedBox(width: 8),
              Text(
                'Checking breach databases...',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  color: Color(0xFF9E9E9E),
                ),
              ),
            ],
          ),
        )
      else if (_breachCount != null && _breachCount! > 0)
        Padding(
          padding: const EdgeInsets.only(top: 6, left: 4),
          child: Row(
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                size: 16,
                color: Color(0xFFE53935),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'This password appeared in $_breachCount data breach${_breachCount == 1 ? '' : 'es'}',
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFFE53935),
                  ),
                ),
              ),
            ],
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

  List<Widget> _buildSshKeyFields() {
    const primaryColor = Color(0xFF4D4DCD);
    return [
      // --- Name field ---
      TextFormField(
        controller: _sshNameController,
        decoration: _inputDecoration('Key Name *'),
        validator: _requiredValidator,
      ),
      const SizedBox(height: 16),

      // --- Key Type dropdown ---
      DropdownButtonFormField<String>(
        initialValue: _sshKeyType,
        decoration: _inputDecoration('Key Type'),
        items: const [
          DropdownMenuItem(value: 'ed25519', child: Text('Ed25519')),
          DropdownMenuItem(value: 'rsa4096', child: Text('RSA 4096')),
        ],
        onChanged: _sshPublicKeyController.text.isEmpty
            ? (v) {
                if (v != null) setState(() => _sshKeyType = v);
              }
            : null,
      ),
      const SizedBox(height: 20),

      // --- Generate / Import toggle ---
      Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _sshGenerating ? null : _generateSshKey,
              icon: _sshGenerating
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.vpn_key_rounded, size: 18),
              label: Text(
                _sshGenerating ? 'Generating...' : 'Generate Key',
                style: const TextStyle(fontFamily: 'Poppins'),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          const SizedBox(width: 12),
          OutlinedButton.icon(
            onPressed: () => setState(() => _sshImportMode = !_sshImportMode),
            icon: Icon(
              _sshImportMode ? Icons.close : Icons.file_upload_outlined,
              size: 18,
            ),
            label: Text(
              _sshImportMode ? 'Cancel' : 'Import',
              style: const TextStyle(fontFamily: 'Poppins'),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: primaryColor,
              side: const BorderSide(color: primaryColor),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            ),
          ),
        ],
      ),
      const SizedBox(height: 16),

      // --- Import mode: paste private key ---
      if (_sshImportMode) ...[
        TextFormField(
          controller: _sshImportController,
          decoration: _inputDecoration('Paste Private Key').copyWith(
            hintText: '-----BEGIN OPENSSH PRIVATE KEY-----',
            hintStyle: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
          maxLines: 6,
          style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
          keyboardType: TextInputType.multiline,
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _importSshKey,
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: const Text(
              'Import Key',
              style: TextStyle(fontFamily: 'Poppins'),
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],

      // --- Public Key (read-only) ---
      if (_sshPublicKeyController.text.isNotEmpty) ...[
        TextFormField(
          controller: _sshPublicKeyController,
          decoration: _inputDecoration('Public Key').copyWith(
            suffixIcon: IconButton(
              icon: const Icon(Icons.copy, size: 18),
              onPressed: () {
                _copySshField(_sshPublicKeyController.text, 'Public key');
              },
            ),
          ),
          readOnly: true,
          maxLines: 3,
          style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
        ),
        const SizedBox(height: 16),
      ],

      // --- Private Key (read-only, obscured) ---
      if (_sshPrivateKeyController.text.isNotEmpty) ...[
        TextFormField(
          controller: _sshPrivateKeyController,
          decoration: _inputDecoration('Private Key').copyWith(
            suffixIcon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(
                    _sshPrivateKeyVisible
                        ? Icons.visibility_off
                        : Icons.visibility,
                    size: 18,
                  ),
                  onPressed: () => setState(
                      () => _sshPrivateKeyVisible = !_sshPrivateKeyVisible),
                ),
                IconButton(
                  icon: const Icon(Icons.copy, size: 18),
                  onPressed: () {
                    _copySshField(
                        _sshPrivateKeyController.text, 'Private key');
                  },
                ),
              ],
            ),
          ),
          readOnly: true,
          maxLines: _sshPrivateKeyVisible ? 4 : 1,
          obscureText: !_sshPrivateKeyVisible,
          style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
        ),
        const SizedBox(height: 16),
      ],

      // --- Fingerprint (read-only) ---
      if (_sshFingerprintController.text.isNotEmpty) ...[
        TextFormField(
          controller: _sshFingerprintController,
          decoration: _inputDecoration('Fingerprint').copyWith(
            suffixIcon: IconButton(
              icon: const Icon(Icons.copy, size: 18),
              onPressed: () {
                _copySshField(
                    _sshFingerprintController.text, 'Fingerprint');
              },
            ),
          ),
          readOnly: true,
          style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
        ),
        const SizedBox(height: 16),
      ],

      // --- Comment (optional) ---
      TextFormField(
        controller: _sshCommentController,
        decoration: _inputDecoration('Comment (e.g. user@host)'),
      ),
      const SizedBox(height: 16),

      // --- Passphrase (optional) ---
      TextFormField(
        controller: _sshPassphraseController,
        decoration: _inputDecoration('Passphrase').copyWith(
          suffixIcon: IconButton(
            icon: Icon(
              _sshPassphraseVisible ? Icons.visibility_off : Icons.visibility,
              size: 18,
            ),
            onPressed: () =>
                setState(() => _sshPassphraseVisible = !_sshPassphraseVisible),
          ),
        ),
        obscureText: !_sshPassphraseVisible,
      ),
      const SizedBox(height: 16),

      // --- Notes ---
      TextFormField(
        controller: _notesController,
        decoration: _inputDecoration('Notes'),
        maxLines: 3,
        keyboardType: TextInputType.multiline,
      ),
    ];
  }

  Future<void> _generateSshKey() async {
    setState(() => _sshGenerating = true);
    try {
      final service = ref.read(sshKeyServiceProvider);
      final comment = _sshCommentController.text.trim();
      final SshKeyData keyData;
      if (_sshKeyType == 'rsa4096') {
        keyData =
            await service.generateRsa4096(comment: comment.isEmpty ? null : comment);
      } else {
        keyData =
            await service.generateEd25519(comment: comment.isEmpty ? null : comment);
      }
      if (!mounted) return;
      setState(() {
        _sshPublicKeyController.text = keyData.publicKey;
        _sshPrivateKeyController.text = keyData.privateKey;
        _sshFingerprintController.text = keyData.fingerprint;
        _sshKeyType = keyData.keyType;
        _sshImportMode = false;
        _sshGenerating = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _sshGenerating = false);
      showCitadelSnackBar(
        context,
        'Key generation failed: $e',
        type: SnackBarType.error,
      );
    }
  }

  void _importSshKey() {
    final text = _sshImportController.text.trim();
    if (text.isEmpty) {
      showCitadelSnackBar(
        context,
        'Please paste a private key to import.',
        type: SnackBarType.error,
      );
      return;
    }
    try {
      final service = ref.read(sshKeyServiceProvider);
      final comment = _sshCommentController.text.trim();
      final keyData =
          service.importFromText(text, comment: comment.isEmpty ? null : comment);
      setState(() {
        _sshPublicKeyController.text = keyData.publicKey;
        _sshPrivateKeyController.text = keyData.privateKey;
        _sshFingerprintController.text = keyData.fingerprint;
        _sshKeyType = keyData.keyType;
        if (keyData.comment != null && _sshCommentController.text.isEmpty) {
          _sshCommentController.text = keyData.comment!;
        }
        _sshImportMode = false;
        _sshImportController.clear();
      });
      showCitadelSnackBar(
        context,
        'SSH key imported successfully.',
        type: SnackBarType.success,
      );
    } catch (e) {
      showCitadelSnackBar(
        context,
        'Import failed: $e',
        type: SnackBarType.error,
      );
    }
  }

  void _copySshField(String value, String label) {
    Clipboard.setData(ClipboardData(text: value));
    showCitadelSnackBar(context, '$label copied to clipboard.');
  }

  List<Widget> _buildDriversLicenseFields() {
    return [
      TextFormField(
        controller: _dlNameController,
        decoration: _inputDecoration('Name *'),
        validator: _requiredValidator,
      ),
      const SizedBox(height: 16),
      TextFormField(
        controller: _dlNumberController,
        decoration: _inputDecoration('License Number'),
      ),
      const SizedBox(height: 16),
      TextFormField(
        controller: _dlStateController,
        decoration: _inputDecoration('State / Province'),
      ),
      const SizedBox(height: 16),
      TextFormField(
        controller: _dlExpiryController,
        decoration: _inputDecoration('Expiry Date'),
        keyboardType: TextInputType.datetime,
      ),
      const SizedBox(height: 16),
      TextFormField(
        controller: _dlDobController,
        decoration: _inputDecoration('Date of Birth'),
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

  List<Widget> _buildPassportFields() {
    return [
      TextFormField(
        controller: _passportNameController,
        decoration: _inputDecoration('Name *'),
        validator: _requiredValidator,
      ),
      const SizedBox(height: 16),
      TextFormField(
        controller: _passportNumberController,
        decoration: _inputDecoration('Passport Number'),
      ),
      const SizedBox(height: 16),
      TextFormField(
        controller: _passportCountryController,
        decoration: _inputDecoration('Country'),
      ),
      const SizedBox(height: 16),
      TextFormField(
        controller: _passportExpiryController,
        decoration: _inputDecoration('Expiry Date'),
        keyboardType: TextInputType.datetime,
      ),
      const SizedBox(height: 16),
      TextFormField(
        controller: _passportDobController,
        decoration: _inputDecoration('Date of Birth'),
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

  List<Widget> _buildSocialSecurityNumberFields() {
    return [
      TextFormField(
        controller: _ssnNameController,
        decoration: _inputDecoration('Name *'),
        validator: _requiredValidator,
      ),
      const SizedBox(height: 16),
      TextFormField(
        controller: _ssnNumberController,
        decoration: _inputDecoration('SSN'),
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

  List<Widget> _buildHealthInsuranceFields() {
    return [
      TextFormField(
        controller: _hiProviderController,
        decoration: _inputDecoration('Provider *'),
        validator: _requiredValidator,
      ),
      const SizedBox(height: 16),
      TextFormField(
        controller: _hiPolicyController,
        decoration: _inputDecoration('Policy #'),
      ),
      const SizedBox(height: 16),
      TextFormField(
        controller: _hiGroupController,
        decoration: _inputDecoration('Group #'),
      ),
      const SizedBox(height: 16),
      TextFormField(
        controller: _hiMemberIdController,
        decoration: _inputDecoration('Member ID'),
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

  List<Widget> _buildInsurancePolicyFields() {
    return [
      TextFormField(
        controller: _ipCompanyController,
        decoration: _inputDecoration('Company *'),
        validator: _requiredValidator,
      ),
      const SizedBox(height: 16),
      TextFormField(
        controller: _ipPolicyController,
        decoration: _inputDecoration('Policy #'),
      ),
      const SizedBox(height: 16),
      TextFormField(
        controller: _ipTypeController,
        decoration: _inputDecoration('Type'),
      ),
      const SizedBox(height: 16),
      TextFormField(
        controller: _ipExpiryController,
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

  List<Widget> _buildMembershipCardFields() {
    return [
      TextFormField(
        controller: _mcOrgController,
        decoration: _inputDecoration('Organization *'),
        validator: _requiredValidator,
      ),
      const SizedBox(height: 16),
      TextFormField(
        controller: _mcMemberIdController,
        decoration: _inputDecoration('Member ID'),
      ),
      const SizedBox(height: 16),
      TextFormField(
        controller: _mcMemberNameController,
        decoration: _inputDecoration('Member Name'),
      ),
      const SizedBox(height: 16),
      TextFormField(
        controller: _mcExpiryController,
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

  List<Widget> _buildEmailAccountFields() {
    return [
      TextFormField(
        controller: _eaEmailController,
        decoration: _inputDecoration('Email *'),
        validator: _requiredValidator,
        keyboardType: TextInputType.emailAddress,
      ),
      const SizedBox(height: 16),
      TextFormField(
        controller: _eaPasswordController,
        decoration: _inputDecoration('Password'),
        obscureText: true,
      ),
      const SizedBox(height: 16),
      TextFormField(
        controller: _eaServerController,
        decoration: _inputDecoration('Server'),
      ),
      const SizedBox(height: 16),
      TextFormField(
        controller: _eaPortController,
        decoration: _inputDecoration('Port'),
        keyboardType: TextInputType.number,
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

  List<Widget> _buildInstantMessengerFields() {
    return [
      TextFormField(
        controller: _imServiceController,
        decoration: _inputDecoration('Service *'),
        validator: _requiredValidator,
      ),
      const SizedBox(height: 16),
      TextFormField(
        controller: _imUsernameController,
        decoration: _inputDecoration('Username'),
      ),
      const SizedBox(height: 16),
      TextFormField(
        controller: _imPasswordController,
        decoration: _inputDecoration('Password'),
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

  List<Widget> _buildDatabaseFields() {
    return [
      TextFormField(
        controller: _dbNameController,
        decoration: _inputDecoration('Name *'),
        validator: _requiredValidator,
      ),
      const SizedBox(height: 16),
      TextFormField(
        controller: _dbHostController,
        decoration: _inputDecoration('Host'),
      ),
      const SizedBox(height: 16),
      TextFormField(
        controller: _dbPortController,
        decoration: _inputDecoration('Port'),
        keyboardType: TextInputType.number,
      ),
      const SizedBox(height: 16),
      TextFormField(
        controller: _dbDbNameController,
        decoration: _inputDecoration('Database Name'),
      ),
      const SizedBox(height: 16),
      TextFormField(
        controller: _dbUsernameController,
        decoration: _inputDecoration('Username'),
      ),
      const SizedBox(height: 16),
      TextFormField(
        controller: _dbPasswordController,
        decoration: _inputDecoration('Password'),
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

  List<Widget> _buildServerFields() {
    return [
      TextFormField(
        controller: _srvNameController,
        decoration: _inputDecoration('Name *'),
        validator: _requiredValidator,
      ),
      const SizedBox(height: 16),
      TextFormField(
        controller: _srvHostController,
        decoration: _inputDecoration('Host'),
      ),
      const SizedBox(height: 16),
      TextFormField(
        controller: _srvPortController,
        decoration: _inputDecoration('Port'),
        keyboardType: TextInputType.number,
      ),
      const SizedBox(height: 16),
      TextFormField(
        controller: _srvUsernameController,
        decoration: _inputDecoration('Username'),
      ),
      const SizedBox(height: 16),
      TextFormField(
        controller: _srvPasswordController,
        decoration: _inputDecoration('Password'),
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
