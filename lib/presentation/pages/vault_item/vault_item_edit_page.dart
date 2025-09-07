import 'dart:math';

import 'package:cryptography/cryptography.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers/core_providers.dart';
import '../../../core/providers/session_provider.dart';
import '../../../core/session/session_state.dart';
import '../../../features/password_generator/presentation/providers/strength_provider.dart';
import '../../../features/password_generator/presentation/widgets/entropy_gauge.dart';
import '../../../features/password_generator/presentation/widgets/password_generator_sheet.dart';
import '../../../features/vault/domain/entities/custom_field.dart';
import '../../../features/vault/domain/entities/vault_item.dart';
import '../../../features/vault/presentation/providers/vault_provider.dart';
import 'widgets/custom_fields_section.dart';

/// Page for creating or editing a vault item.
///
/// If [existingItem] is null, operates in create mode.
/// Otherwise operates in edit mode with pre-filled fields.
class VaultItemEditPage extends ConsumerStatefulWidget {
  const VaultItemEditPage({super.key, this.existingItem});

  final VaultItemEntity? existingItem;

  @override
  ConsumerState<VaultItemEditPage> createState() => _VaultItemEditPageState();
}

class _VaultItemEditPageState extends ConsumerState<VaultItemEditPage> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _urlController;
  late final TextEditingController _usernameController;
  late final TextEditingController _passwordController;
  late final TextEditingController _notesController;

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
    _nameController = TextEditingController(text: item?.name ?? '');
    _urlController = TextEditingController(text: item?.url ?? '');
    _usernameController = TextEditingController(text: item?.username ?? '');
    _passwordController = TextEditingController(text: item?.password ?? '');
    _notesController = TextEditingController(text: item?.notes ?? '');
    _selectedType = item?.type ?? VaultItemType.password;
    _isFavorite = item?.isFavorite ?? false;
    _customFields = List.of(item?.customFields ?? []);
    _expiryDays = item?.expiryDays;

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

      final entity = VaultItemEntity(
        id: widget.existingItem?.id ?? _generateId(),
        vaultId: widget.existingItem?.vaultId ?? 'default',
        name: _nameController.text.trim(),
        url: _urlController.text.trim().isEmpty
            ? null
            : _urlController.text.trim(),
        username: _usernameController.text.trim().isEmpty
            ? null
            : _usernameController.text.trim(),
        password: _passwordController.text.isEmpty
            ? null
            : _passwordController.text,
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
        type: _selectedType,
        isFavorite: _isFavorite,
        customFields: _customFields.isEmpty ? null : _customFields,
        expiryDays: _expiryDays,
        createdAt: widget.existingItem?.createdAt ?? now,
        updatedAt: now,
      );

      if (_isCreateMode) {
        await repo.createItem(entity, vaultKey);
      } else {
        await repo.updateItem(entity, vaultKey);
      }

      // Refresh vault items.
      ref.read(vaultProvider.notifier).fetchItems();

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
            // Item type dropdown
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

            // Name
            TextFormField(
              controller: _nameController,
              decoration: _inputDecoration('Name *'),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Name is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // URL
            TextFormField(
              controller: _urlController,
              decoration: _inputDecoration('URL'),
              keyboardType: TextInputType.url,
            ),
            const SizedBox(height: 16),

            // Username
            TextFormField(
              controller: _usernameController,
              decoration: _inputDecoration('Username'),
            ),
            const SizedBox(height: 16),

            // Password
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

            // Notes
            TextFormField(
              controller: _notesController,
              decoration: _inputDecoration('Notes'),
              maxLines: 3,
              keyboardType: TextInputType.multiline,
            ),
            const SizedBox(height: 24),

            // Custom fields section
            CustomFieldsSection(
              fields: _customFields,
              onChanged: (fields) {
                setState(() => _customFields = fields);
              },
            ),
            const SizedBox(height: 24),

            // Password Expiry section — per D-18
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
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(fontFamily: 'Poppins'),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
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
