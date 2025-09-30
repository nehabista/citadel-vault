import '../../../presentation/widgets/citadel_snackbar.dart';
import 'dart:math';

import 'package:cryptography/cryptography.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../../core/providers/core_providers.dart';
import '../../../../core/providers/session_provider.dart';
import '../../../../core/session/session_state.dart';
import '../../data/models/otp_auth_uri.dart';
import '../../data/models/totp_entry_entity.dart';
import '../providers/totp_provider.dart';

/// Dialog for adding a TOTP entry via manual entry or QR code scan.
///
/// Per D-12: supports manual Base32 secret input and camera-based QR scanning.
/// On scan, auto-populates fields from the otpauth:// URI.
class TotpAddDialog extends ConsumerStatefulWidget {
  const TotpAddDialog({super.key, required this.vaultItemId});

  final String vaultItemId;

  @override
  ConsumerState<TotpAddDialog> createState() => _TotpAddDialogState();
}

class _TotpAddDialogState extends ConsumerState<TotpAddDialog>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final _formKey = GlobalKey<FormState>();

  final _secretController = TextEditingController();
  final _issuerController = TextEditingController();
  final _labelController = TextEditingController();

  int _digits = 6;
  int _period = 30;
  String _algorithm = 'SHA1';

  bool _isSaving = false;
  String? _scanError;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _secretController.dispose();
    _issuerController.dispose();
    _labelController.dispose();
    super.dispose();
  }

  /// Validate that the secret is valid Base32 (A-Z, 2-7, =).
  String? _validateBase32(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Secret is required';
    }
    final cleaned = value.trim().toUpperCase().replaceAll(' ', '');
    if (!RegExp(r'^[A-Z2-7=]+$').hasMatch(cleaned)) {
      return 'Invalid Base32 characters';
    }
    return null;
  }

  void _onQrDetected(BarcodeCapture capture) {
    final barcode = capture.barcodes.firstOrNull;
    if (barcode == null || barcode.rawValue == null) return;

    final rawValue = barcode.rawValue!;
    if (!rawValue.startsWith('otpauth://')) {
      setState(() => _scanError = 'Not a valid TOTP QR code');
      return;
    }

    try {
      final parsed = OtpAuthUri.parse(rawValue);
      setState(() {
        _secretController.text = parsed.secret;
        _issuerController.text = parsed.issuer ?? '';
        _labelController.text = parsed.label ?? '';
        _digits = parsed.digits;
        _period = parsed.period;
        _algorithm = parsed.algorithm;
        _scanError = null;
      });
      // Switch to manual tab to review parsed data.
      _tabController.animateTo(0);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('QR code scanned successfully'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } on FormatException catch (e) {
      setState(() => _scanError = e.message);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final session = ref.read(sessionProvider);
    if (session is! Unlocked) return;

    setState(() => _isSaving = true);

    try {
      final repo = ref.read(totpRepositoryProvider);
      final vaultKey = SecretKey(session.vaultKey);

      final entity = TotpEntryEntity(
        id: _generateId(),
        vaultItemId: widget.vaultItemId,
        secret: _secretController.text.trim().toUpperCase().replaceAll(' ', ''),
        digits: _digits,
        period: _period,
        algorithm: _algorithm,
      );

      await repo.addEntry(entity, vaultKey);

      // Invalidate the entries provider so the list refreshes.
      ref.invalidate(totpEntriesProvider(widget.vaultItemId));

      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving TOTP: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  String _generateId() {
    final random = Random.secure();
    final bytes = List.generate(16, (_) => random.nextInt(256));
    return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480, maxHeight: 560),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
              child: Row(
                children: [
                  const Icon(Icons.security_rounded,
                      color: Color(0xFF4D4DCD), size: 24),
                  const SizedBox(width: 12),
                  Text(
                    'Add TOTP',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
            ),
            // Tabs
            TabBar(
              controller: _tabController,
              labelColor: const Color(0xFF4D4DCD),
              indicatorColor: const Color(0xFF4D4DCD),
              tabs: const [
                Tab(text: 'Manual Entry'),
                Tab(text: 'Scan QR Code'),
              ],
            ),
            // Tab views
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildManualEntry(theme),
                  _buildQrScanner(theme),
                ],
              ),
            ),
            // Action buttons
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: _isSaving ? null : _save,
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF4D4DCD),
                    ),
                    child: _isSaving
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white),
                          )
                        : const Text('Save'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildManualEntry(ThemeData theme) {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          // Secret
          TextFormField(
            controller: _secretController,
            decoration: InputDecoration(
              labelText: 'Secret (Base32) *',
              labelStyle: const TextStyle(fontFamily: 'Poppins'),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    const BorderSide(color: Color(0xFF4D4DCD), width: 2),
              ),
            ),
            validator: _validateBase32,
            textCapitalization: TextCapitalization.characters,
          ),
          const SizedBox(height: 12),
          // Issuer
          TextFormField(
            controller: _issuerController,
            decoration: InputDecoration(
              labelText: 'Issuer (optional)',
              labelStyle: const TextStyle(fontFamily: 'Poppins'),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    const BorderSide(color: Color(0xFF4D4DCD), width: 2),
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Label
          TextFormField(
            controller: _labelController,
            decoration: InputDecoration(
              labelText: 'Label (optional)',
              labelStyle: const TextStyle(fontFamily: 'Poppins'),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    const BorderSide(color: Color(0xFF4D4DCD), width: 2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Digits & Period & Algorithm in a row
          Row(
            children: [
              // Digits dropdown
              Expanded(
                flex: 3,
                child: DropdownButtonFormField<int>(
                  initialValue: _digits,
                  decoration: InputDecoration(
                    labelText: 'Digits',
                    labelStyle: const TextStyle(fontFamily: 'Poppins', fontSize: 13),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    isDense: true,
                  ),
                  items: const [
                    DropdownMenuItem(value: 6, child: Text('6')),
                    DropdownMenuItem(value: 8, child: Text('8')),
                  ],
                  onChanged: (v) {
                    if (v != null) setState(() => _digits = v);
                  },
                ),
              ),
              const SizedBox(width: 6),
              // Period dropdown
              Expanded(
                flex: 3,
                child: DropdownButtonFormField<int>(
                  initialValue: _period,
                  decoration: InputDecoration(
                    labelText: 'Period',
                    labelStyle: const TextStyle(fontFamily: 'Poppins', fontSize: 13),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    isDense: true,
                  ),
                  items: const [
                    DropdownMenuItem(value: 30, child: Text('30s')),
                    DropdownMenuItem(value: 60, child: Text('60s')),
                  ],
                  onChanged: (v) {
                    if (v != null) setState(() => _period = v);
                  },
                ),
              ),
              const SizedBox(width: 6),
              // Algorithm dropdown
              Expanded(
                flex: 4,
                child: DropdownButtonFormField<String>(
                  initialValue: _algorithm,
                  decoration: InputDecoration(
                    labelText: 'Algo',
                    labelStyle: const TextStyle(fontFamily: 'Poppins', fontSize: 13),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    isDense: true,
                  ),
                  items: const [
                    DropdownMenuItem(value: 'SHA1', child: Text('SHA1')),
                    DropdownMenuItem(value: 'SHA256', child: Text('SHA256')),
                    DropdownMenuItem(value: 'SHA512', child: Text('SHA512')),
                  ],
                  onChanged: (v) {
                    if (v != null) setState(() => _algorithm = v);
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQrScanner(ThemeData theme) {
    return Column(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: MobileScanner(
                onDetect: _onQrDetected,
              ),
            ),
          ),
        ),
        if (_scanError != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Text(
              _scanError!,
              style: TextStyle(color: theme.colorScheme.error, fontSize: 13),
            ),
          ),
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            'Point camera at an otpauth:// QR code',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ),
      ],
    );
  }
}
