import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/core_providers.dart';
import '../../../../features/security/domain/entities/breach_result.dart';
import '../../../../features/password_generator/presentation/providers/strength_provider.dart';
import '../../../../features/password_generator/presentation/widgets/password_generator_sheet.dart';
import '../../../../features/vault/data/services/logo_search_service.dart';
import '../../../../features/vault/domain/entities/custom_field.dart';
import '../../../../features/vault/domain/entities/vault_item.dart';
import '../utils/form_decoration.dart';
import '../utils/type_form_mixin.dart';

/// Form fields for the [VaultItemType.password] type.
///
/// Includes logo search overlay, breach check indicator, and password
/// generator integration.
class PasswordFormFields extends ConsumerStatefulWidget {
  const PasswordFormFields({super.key, this.existingItem});

  final VaultItemEntity? existingItem;

  @override
  ConsumerState<PasswordFormFields> createState() => PasswordFormFieldsState();
}

class PasswordFormFieldsState extends ConsumerState<PasswordFormFields>
    implements TypeFormContract {
  late final TextEditingController _nameController;
  late final TextEditingController _urlController;
  late final TextEditingController _usernameController;
  late final TextEditingController _passwordController;
  late final TextEditingController _notesController;

  bool _passwordVisible = false;

  // Breach check state
  Timer? _breachDebounce;
  int? _breachCount;
  bool _breachChecking = false;

  // Logo search state
  Timer? _logoDebounce;
  List<LogoResult> _logoResults = [];
  String? _selectedLogoUrl;
  final LayerLink _logoLayerLink = LayerLink();
  OverlayEntry? _logoOverlayEntry;

  /// The notes controller is shared with the parent — expose it for reading.
  TextEditingController get notesController => _notesController;

  /// The password controller — exposed so the parent can read its text for
  /// the strength gauge and expiry section.
  TextEditingController get passwordController => _passwordController;

  @override
  void initState() {
    super.initState();
    final item = widget.existingItem;
    _nameController = TextEditingController(text: item?.name ?? '');
    _urlController = TextEditingController(text: item?.url ?? '');
    _usernameController = TextEditingController(text: item?.username ?? '');
    _passwordController = TextEditingController(text: item?.password ?? '');
    _notesController = TextEditingController(text: item?.notes ?? '');

    // Initialize logo URL from existing custom fields.
    final existingLogoUrl = _customFieldValue('logoUrl');
    if (existingLogoUrl.isNotEmpty) {
      _selectedLogoUrl = existingLogoUrl;
    }

    // Initialize strength provider with current password.
    if (_passwordController.text.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref
            .read(currentPasswordProvider.notifier)
            .set(_passwordController.text);
        _debouncedBreachCheck();
      });
    }

    _passwordController.addListener(_onPasswordChanged);
    _nameController.addListener(_onNameChangedForLogo);
  }

  String _customFieldValue(String name) {
    final existing = widget.existingItem?.customFields;
    if (existing == null) return '';
    final field = existing.where((f) => f.name == name).firstOrNull;
    return field?.value ?? '';
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
                                  color:
                                      const Color(0xFF4D4DCD).withAlpha(25),
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
    super.dispose();
  }

  // --- TypeFormContract implementation ---

  @override
  String getName() => _nameController.text.trim();

  @override
  List<CustomField> getCustomFields() {
    final fields = <CustomField>[];
    if (_selectedLogoUrl != null && _selectedLogoUrl!.isNotEmpty) {
      fields.add(CustomField(
        name: 'logoUrl',
        value: _selectedLogoUrl!,
        type: CustomFieldType.text,
      ));
    }
    return fields;
  }

  /// Return the URL for the save method (password-type specific).
  String? getUrl() {
    final text = _urlController.text.trim();
    return text.isEmpty ? null : text;
  }

  /// Return the username for the save method (password-type specific).
  String? getUsername() {
    final text = _usernameController.text.trim();
    return text.isEmpty ? null : text;
  }

  /// Return the password value for the save method (password-type specific).
  String? getPassword() {
    final text = _passwordController.text;
    return text.isEmpty ? null : text;
  }

  /// Return the notes text for the save method.
  String? getNotes() {
    final text = _notesController.text.trim();
    return text.isEmpty ? null : text;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CompositedTransformTarget(
          link: _logoLayerLink,
          child: TextFormField(
            controller: _nameController,
            decoration: citadelInputDecoration('Name *').copyWith(
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
            validator: requiredValidator,
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _urlController,
          decoration: citadelInputDecoration('URL'),
          keyboardType: TextInputType.url,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _usernameController,
          decoration: citadelInputDecoration('Username'),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _passwordController,
          obscureText: !_passwordVisible,
          decoration: citadelInputDecoration('Password').copyWith(
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
          decoration: citadelInputDecoration('Notes'),
          maxLines: 3,
          keyboardType: TextInputType.multiline,
        ),
      ],
    );
  }
}
