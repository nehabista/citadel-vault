import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../widgets/citadel_snackbar.dart';
import '../../../../core/utils/error_sanitizer.dart';
import '../../../../features/ssh_keys/presentation/providers/ssh_key_providers.dart';
import '../../../../features/vault/domain/entities/custom_field.dart';
import '../../../../features/vault/domain/entities/vault_item.dart';
import '../utils/form_decoration.dart';
import '../utils/type_form_mixin.dart';

/// Form fields for the [VaultItemType.sshKey] type.
///
/// Contains SSH key generation (Ed25519 / RSA 4096), import from PEM text,
/// read-only public/private/fingerprint display, comment, and passphrase.
class SshKeyFormFields extends ConsumerStatefulWidget {
  const SshKeyFormFields({super.key, this.existingItem});

  final VaultItemEntity? existingItem;

  @override
  ConsumerState<SshKeyFormFields> createState() => SshKeyFormFieldsState();
}

class SshKeyFormFieldsState extends ConsumerState<SshKeyFormFields>
    implements TypeFormContract {
  late final TextEditingController _sshNameController;
  late final TextEditingController _sshPublicKeyController;
  late final TextEditingController _sshPrivateKeyController;
  late final TextEditingController _sshFingerprintController;
  late final TextEditingController _sshCommentController;
  late final TextEditingController _sshPassphraseController;
  late final TextEditingController _sshImportController;
  late final TextEditingController _notesController;

  String _sshKeyType = 'ed25519';
  bool _sshGenerating = false;
  bool _sshPrivateKeyVisible = false;
  bool _sshPassphraseVisible = false;
  bool _sshImportMode = false;

  static const _primaryColor = Color(0xFF4D4DCD);

  @override
  void initState() {
    super.initState();
    final item = widget.existingItem;
    _sshNameController = TextEditingController(
        text: _customFieldValue('sshName').isNotEmpty
            ? _customFieldValue('sshName')
            : (item?.name ?? ''));
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
    _notesController = TextEditingController(text: item?.notes ?? '');

    final existingKeyType = _customFieldValue('keyType');
    if (existingKeyType.isNotEmpty) {
      _sshKeyType = existingKeyType;
    }
  }

  String _customFieldValue(String name) {
    final existing = widget.existingItem?.customFields;
    if (existing == null) return '';
    final field = existing.where((f) => f.name == name).firstOrNull;
    return field?.value ?? '';
  }

  @override
  void dispose() {
    _sshNameController.dispose();
    _sshPublicKeyController.dispose();
    _sshPrivateKeyController.dispose();
    _sshFingerprintController.dispose();
    _sshCommentController.dispose();
    _sshPassphraseController.dispose();
    _sshImportController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  // --- TypeFormContract implementation ---

  @override
  String getName() => _sshNameController.text.trim();

  @override
  List<CustomField> getCustomFields() {
    final fields = <CustomField>[];

    void addText(String name, String value) {
      if (value.isNotEmpty) {
        fields.add(CustomField(
            name: name, value: value, type: CustomFieldType.text));
      }
    }

    void addHidden(String name, String value) {
      if (value.isNotEmpty) {
        fields.add(CustomField(
            name: name, value: value, type: CustomFieldType.hidden));
      }
    }

    addText('sshName', _sshNameController.text.trim());
    addHidden('privateKey', _sshPrivateKeyController.text.trim());
    addText('publicKey', _sshPublicKeyController.text.trim());
    addText('keyType', _sshKeyType);
    addText('fingerprint', _sshFingerprintController.text.trim());
    addText('comment', _sshCommentController.text.trim());
    addHidden('passphrase', _sshPassphraseController.text.trim());
    return fields;
  }

  /// Return the notes text for the save method.
  String? getNotes() {
    final text = _notesController.text.trim();
    return text.isEmpty ? null : text;
  }

  // --- SSH key actions ---

  Future<void> _generateSshKey() async {
    setState(() => _sshGenerating = true);
    try {
      final service = ref.read(sshKeyServiceProvider);
      final comment = _sshCommentController.text.trim();
      final keyData = _sshKeyType == 'rsa4096'
          ? await service.generateRsa4096(
              comment: comment.isEmpty ? null : comment)
          : await service.generateEd25519(
              comment: comment.isEmpty ? null : comment);
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
        'Key generation failed: ${sanitizeErrorMessage(e)}',
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
        'Import failed: ${sanitizeErrorMessage(e)}',
        type: SnackBarType.error,
      );
    }
  }

  void _copySshField(String value, String label) {
    Clipboard.setData(ClipboardData(text: value));
    showCitadelSnackBar(context, '$label copied to clipboard.');
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // --- Name field ---
        TextFormField(
          controller: _sshNameController,
          decoration: citadelInputDecoration('Key Name *'),
          validator: requiredValidator,
        ),
        const SizedBox(height: 16),

        // --- Key Type dropdown ---
        DropdownButtonFormField<String>(
          initialValue: _sshKeyType,
          decoration: citadelInputDecoration('Key Type'),
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
                  backgroundColor: _primaryColor,
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
              onPressed: () =>
                  setState(() => _sshImportMode = !_sshImportMode),
              icon: Icon(
                _sshImportMode ? Icons.close : Icons.file_upload_outlined,
                size: 18,
              ),
              label: Text(
                _sshImportMode ? 'Cancel' : 'Import',
                style: const TextStyle(fontFamily: 'Poppins'),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: _primaryColor,
                side: const BorderSide(color: _primaryColor),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                padding:
                    const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // --- Import mode: paste private key ---
        if (_sshImportMode) ...[
          TextFormField(
            controller: _sshImportController,
            decoration: citadelInputDecoration('Paste Private Key').copyWith(
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
                backgroundColor: _primaryColor,
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
            decoration: citadelInputDecoration('Public Key').copyWith(
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
            decoration: citadelInputDecoration('Private Key').copyWith(
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
            decoration: citadelInputDecoration('Fingerprint').copyWith(
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
          decoration: citadelInputDecoration('Comment (e.g. user@host)'),
        ),
        const SizedBox(height: 16),

        // --- Passphrase (optional) ---
        TextFormField(
          controller: _sshPassphraseController,
          decoration: citadelInputDecoration('Passphrase').copyWith(
            suffixIcon: IconButton(
              icon: Icon(
                _sshPassphraseVisible
                    ? Icons.visibility_off
                    : Icons.visibility,
                size: 18,
              ),
              onPressed: () => setState(
                  () => _sshPassphraseVisible = !_sshPassphraseVisible),
            ),
          ),
          obscureText: !_sshPassphraseVisible,
        ),
        const SizedBox(height: 16),

        // --- Notes ---
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
