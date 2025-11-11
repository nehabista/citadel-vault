import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../features/vault/domain/entities/custom_field.dart';
import '../../../../features/vault/domain/entities/vault_item.dart';
import '../utils/form_decoration.dart';
import '../utils/type_form_mixin.dart';

/// Combined form fields for the smaller vault item types:
/// [VaultItemType.healthInsurance], [VaultItemType.insurancePolicy],
/// [VaultItemType.membershipCard], [VaultItemType.emailAccount],
/// [VaultItemType.instantMessenger], [VaultItemType.database],
/// [VaultItemType.server].
class MiscFormFields extends ConsumerStatefulWidget {
  const MiscFormFields({
    super.key,
    required this.miscType,
    this.existingItem,
  });

  final VaultItemType miscType;
  final VaultItemEntity? existingItem;

  @override
  ConsumerState<MiscFormFields> createState() => MiscFormFieldsState();
}

class MiscFormFieldsState extends ConsumerState<MiscFormFields>
    implements TypeFormContract {
  // Health Insurance
  late final TextEditingController _hiProviderController;
  late final TextEditingController _hiPolicyController;
  late final TextEditingController _hiGroupController;
  late final TextEditingController _hiMemberIdController;

  // Insurance Policy
  late final TextEditingController _ipCompanyController;
  late final TextEditingController _ipPolicyController;
  late final TextEditingController _ipTypeController;
  late final TextEditingController _ipExpiryController;

  // Membership Card
  late final TextEditingController _mcOrgController;
  late final TextEditingController _mcMemberIdController;
  late final TextEditingController _mcMemberNameController;
  late final TextEditingController _mcExpiryController;

  // Email Account
  late final TextEditingController _eaEmailController;
  late final TextEditingController _eaPasswordController;
  late final TextEditingController _eaServerController;
  late final TextEditingController _eaPortController;

  // Instant Messenger
  late final TextEditingController _imServiceController;
  late final TextEditingController _imUsernameController;
  late final TextEditingController _imPasswordController;

  // Database
  late final TextEditingController _dbNameController;
  late final TextEditingController _dbHostController;
  late final TextEditingController _dbPortController;
  late final TextEditingController _dbDbNameController;
  late final TextEditingController _dbUsernameController;
  late final TextEditingController _dbPasswordController;

  // Server
  late final TextEditingController _srvNameController;
  late final TextEditingController _srvHostController;
  late final TextEditingController _srvPortController;
  late final TextEditingController _srvUsernameController;
  late final TextEditingController _srvPasswordController;

  late final TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    final item = widget.existingItem;
    _notesController = TextEditingController(text: item?.notes ?? '');

    // Health Insurance
    _hiProviderController = TextEditingController(
        text: _cf('hiProvider').isNotEmpty
            ? _cf('hiProvider')
            : (widget.miscType == VaultItemType.healthInsurance
                ? (item?.name ?? '')
                : ''));
    _hiPolicyController = TextEditingController(text: _cf('hiPolicy'));
    _hiGroupController = TextEditingController(text: _cf('hiGroup'));
    _hiMemberIdController = TextEditingController(text: _cf('hiMemberId'));

    // Insurance Policy
    _ipCompanyController = TextEditingController(
        text: _cf('ipCompany').isNotEmpty
            ? _cf('ipCompany')
            : (widget.miscType == VaultItemType.insurancePolicy
                ? (item?.name ?? '')
                : ''));
    _ipPolicyController = TextEditingController(text: _cf('ipPolicy'));
    _ipTypeController = TextEditingController(text: _cf('ipType'));
    _ipExpiryController = TextEditingController(text: _cf('ipExpiry'));

    // Membership Card
    _mcOrgController = TextEditingController(
        text: _cf('mcOrg').isNotEmpty
            ? _cf('mcOrg')
            : (widget.miscType == VaultItemType.membershipCard
                ? (item?.name ?? '')
                : ''));
    _mcMemberIdController = TextEditingController(text: _cf('mcMemberId'));
    _mcMemberNameController =
        TextEditingController(text: _cf('mcMemberName'));
    _mcExpiryController = TextEditingController(text: _cf('mcExpiry'));

    // Email Account
    _eaEmailController = TextEditingController(
        text: _cf('eaEmail').isNotEmpty
            ? _cf('eaEmail')
            : (widget.miscType == VaultItemType.emailAccount
                ? (item?.name ?? '')
                : ''));
    _eaPasswordController = TextEditingController(text: _cf('eaPassword'));
    _eaServerController = TextEditingController(text: _cf('eaServer'));
    _eaPortController = TextEditingController(text: _cf('eaPort'));

    // Instant Messenger
    _imServiceController = TextEditingController(
        text: _cf('imService').isNotEmpty
            ? _cf('imService')
            : (widget.miscType == VaultItemType.instantMessenger
                ? (item?.name ?? '')
                : ''));
    _imUsernameController = TextEditingController(text: _cf('imUsername'));
    _imPasswordController = TextEditingController(text: _cf('imPassword'));

    // Database
    _dbNameController = TextEditingController(
        text: _cf('dbName').isNotEmpty
            ? _cf('dbName')
            : (widget.miscType == VaultItemType.database
                ? (item?.name ?? '')
                : ''));
    _dbHostController = TextEditingController(text: _cf('dbHost'));
    _dbPortController = TextEditingController(text: _cf('dbPort'));
    _dbDbNameController = TextEditingController(text: _cf('dbDbName'));
    _dbUsernameController = TextEditingController(text: _cf('dbUsername'));
    _dbPasswordController = TextEditingController(text: _cf('dbPassword'));

    // Server
    _srvNameController = TextEditingController(
        text: _cf('srvName').isNotEmpty
            ? _cf('srvName')
            : (widget.miscType == VaultItemType.server
                ? (item?.name ?? '')
                : ''));
    _srvHostController = TextEditingController(text: _cf('srvHost'));
    _srvPortController = TextEditingController(text: _cf('srvPort'));
    _srvUsernameController = TextEditingController(text: _cf('srvUsername'));
    _srvPasswordController = TextEditingController(text: _cf('srvPassword'));
  }

  String _cf(String name) {
    final existing = widget.existingItem?.customFields;
    if (existing == null) return '';
    return existing.where((f) => f.name == name).firstOrNull?.value ?? '';
  }

  @override
  void dispose() {
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
    _notesController.dispose();
    super.dispose();
  }

  // --- TypeFormContract ---

  @override
  String getName() {
    switch (widget.miscType) {
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
      default:
        return '';
    }
  }

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

    switch (widget.miscType) {
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
      default:
        break;
    }
    return fields;
  }

  String? getNotes() {
    final text = _notesController.text.trim();
    return text.isEmpty ? null : text;
  }

  @override
  Widget build(BuildContext context) {
    switch (widget.miscType) {
      case VaultItemType.healthInsurance:
        return _buildHealthInsurance();
      case VaultItemType.insurancePolicy:
        return _buildInsurancePolicy();
      case VaultItemType.membershipCard:
        return _buildMembershipCard();
      case VaultItemType.emailAccount:
        return _buildEmailAccount();
      case VaultItemType.instantMessenger:
        return _buildInstantMessenger();
      case VaultItemType.database:
        return _buildDatabase();
      case VaultItemType.server:
        return _buildServer();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildHealthInsurance() {
    return Column(
      children: [
        TextFormField(
          controller: _hiProviderController,
          decoration: citadelInputDecoration('Provider *'),
          validator: requiredValidator,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _hiPolicyController,
          decoration: citadelInputDecoration('Policy #'),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _hiGroupController,
          decoration: citadelInputDecoration('Group #'),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _hiMemberIdController,
          decoration: citadelInputDecoration('Member ID'),
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

  Widget _buildInsurancePolicy() {
    return Column(
      children: [
        TextFormField(
          controller: _ipCompanyController,
          decoration: citadelInputDecoration('Company *'),
          validator: requiredValidator,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _ipPolicyController,
          decoration: citadelInputDecoration('Policy #'),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _ipTypeController,
          decoration: citadelInputDecoration('Type'),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _ipExpiryController,
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

  Widget _buildMembershipCard() {
    return Column(
      children: [
        TextFormField(
          controller: _mcOrgController,
          decoration: citadelInputDecoration('Organization *'),
          validator: requiredValidator,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _mcMemberIdController,
          decoration: citadelInputDecoration('Member ID'),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _mcMemberNameController,
          decoration: citadelInputDecoration('Member Name'),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _mcExpiryController,
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

  Widget _buildEmailAccount() {
    return Column(
      children: [
        TextFormField(
          controller: _eaEmailController,
          decoration: citadelInputDecoration('Email *'),
          validator: requiredValidator,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _eaPasswordController,
          decoration: citadelInputDecoration('Password'),
          obscureText: true,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _eaServerController,
          decoration: citadelInputDecoration('Server'),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _eaPortController,
          decoration: citadelInputDecoration('Port'),
          keyboardType: TextInputType.number,
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

  Widget _buildInstantMessenger() {
    return Column(
      children: [
        TextFormField(
          controller: _imServiceController,
          decoration: citadelInputDecoration('Service *'),
          validator: requiredValidator,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _imUsernameController,
          decoration: citadelInputDecoration('Username'),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _imPasswordController,
          decoration: citadelInputDecoration('Password'),
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

  Widget _buildDatabase() {
    return Column(
      children: [
        TextFormField(
          controller: _dbNameController,
          decoration: citadelInputDecoration('Name *'),
          validator: requiredValidator,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _dbHostController,
          decoration: citadelInputDecoration('Host'),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _dbPortController,
          decoration: citadelInputDecoration('Port'),
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _dbDbNameController,
          decoration: citadelInputDecoration('Database Name'),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _dbUsernameController,
          decoration: citadelInputDecoration('Username'),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _dbPasswordController,
          decoration: citadelInputDecoration('Password'),
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

  Widget _buildServer() {
    return Column(
      children: [
        TextFormField(
          controller: _srvNameController,
          decoration: citadelInputDecoration('Name *'),
          validator: requiredValidator,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _srvHostController,
          decoration: citadelInputDecoration('Host'),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _srvPortController,
          decoration: citadelInputDecoration('Port'),
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _srvUsernameController,
          decoration: citadelInputDecoration('Username'),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _srvPasswordController,
          decoration: citadelInputDecoration('Password'),
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
