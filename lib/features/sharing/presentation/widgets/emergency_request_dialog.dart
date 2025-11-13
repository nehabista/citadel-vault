// File: lib/features/sharing/presentation/widgets/emergency_request_dialog.dart
// Dialog for adding a new trusted emergency contact.
// Per D-10, D-11: configurable waiting period 1-30 days, default 7.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/core_providers.dart';
import '../../../../core/utils/pb_filter_sanitizer.dart';
import '../../../../presentation/widgets/citadel_snackbar.dart';
import '../providers/emergency_providers.dart';

/// Dialog that allows the user (grantor) to add a trusted contact
/// for emergency vault access.
///
/// Fields:
/// - Email input for grantee lookup
/// - Waiting period slider (1-30 days, default 7)
/// - Explanation text about the waiting period
class EmergencyRequestDialog extends ConsumerStatefulWidget {
  const EmergencyRequestDialog({super.key});

  @override
  ConsumerState<EmergencyRequestDialog> createState() =>
      _EmergencyRequestDialogState();
}

class _EmergencyRequestDialogState
    extends ConsumerState<EmergencyRequestDialog> {
  final _emailController = TextEditingController();
  double _waitingPeriodDays = 7;
  bool _isLoading = false;
  String? _errorText;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  bool _validateEmail(String email) {
    return email.isNotEmpty && email.contains('@');
  }

  Future<void> _addContact() async {
    final email = _emailController.text.trim();

    if (!_validateEmail(email)) {
      setState(() => _errorText = 'Please enter a valid email address');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorText = null;
    });

    try {
      final repo = ref.read(emergencyRepositoryProvider);
      final pb = ref.read(pocketBaseClientProvider);
      final currentUserId = pb.authStore.record?.id;

      if (currentUserId == null) {
        setState(() {
          _errorText = 'Not authenticated. Please log in.';
          _isLoading = false;
        });
        return;
      }

      // Look up user by email to get their ID and public key
      final safeEmail = sanitizePbFilter(email);
      final users = await pb.collection('users').getFullList(
            filter: 'email = "$safeEmail"',
          );

      if (users.isEmpty) {
        setState(() {
          _errorText = 'User not found. They must have a Citadel account.';
          _isLoading = false;
        });
        return;
      }

      final grantee = users.first;
      final granteeId = grantee.id;

      // Look up the grantee's public key from user_keys collection
      final safeGranteeId = sanitizePbFilter(granteeId);
      final keyRecords = await pb.collection('user_keys').getFullList(
            filter: 'userId = "$safeGranteeId"',
          );

      final granteePublicKey = keyRecords.isNotEmpty
          ? keyRecords.first.getStringValue('publicKey')
          : '';

      await repo.addTrustedContact(
        granteeEmail: email,
        waitingPeriodDays: _waitingPeriodDays.round(),
        currentUserId: currentUserId,
        granteePublicKey: granteePublicKey,
        granteeId: granteeId,
      );

      if (mounted) {
        showCitadelSnackBar(context, 'Emergency contact added',
            type: SnackBarType.success);
        // Invalidate providers to refresh the list
        ref.invalidate(grantorContactsProvider);
        Navigator.pop(context);
      }
    } catch (e) {
      setState(() {
        _errorText = 'Failed to add contact: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final days = _waitingPeriodDays.round();

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      title: const Text(
        'Add Trusted Contact',
        style: TextStyle(
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w600,
          fontSize: 18,
          color: Color(0xFF1A1A2E),
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Explanation
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF4D4DCD).withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info_outline,
                      size: 18, color: Color(0xFF4D4DCD)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'If you don\'t reject within $days days, they will receive read-only access to your vault.',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Email input
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              style: const TextStyle(fontFamily: 'Poppins', fontSize: 14),
              decoration: InputDecoration(
                labelText: 'Contact Email',
                labelStyle: const TextStyle(fontFamily: 'Poppins'),
                hintText: 'user@example.com',
                hintStyle: TextStyle(
                    fontFamily: 'Poppins', color: Colors.grey.shade400),
                prefixIcon:
                    const Icon(Icons.email_outlined, color: Color(0xFF4D4DCD)),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14)),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: Color(0xFF4D4DCD)),
                ),
                errorText: _errorText,
                errorStyle: const TextStyle(fontFamily: 'Poppins'),
              ),
              onChanged: (_) {
                if (_errorText != null) {
                  setState(() => _errorText = null);
                }
              },
            ),

            const SizedBox(height: 20),

            // Waiting period slider
            Text(
              'Waiting Period: $days days',
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w500,
                fontSize: 14,
                color: Color(0xFF1A1A2E),
              ),
            ),
            const SizedBox(height: 4),
            SliderTheme(
              data: SliderThemeData(
                activeTrackColor: const Color(0xFF4D4DCD),
                thumbColor: const Color(0xFF4D4DCD),
                inactiveTrackColor:
                    const Color(0xFF4D4DCD).withValues(alpha: 0.2),
                overlayColor: const Color(0xFF4D4DCD).withValues(alpha: 0.1),
              ),
              child: Slider(
                value: _waitingPeriodDays,
                min: 1,
                max: 30,
                divisions: 29,
                label: '$days days',
                onChanged: (value) {
                  setState(() => _waitingPeriodDays = value);
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('1 day',
                    style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 11,
                        color: Colors.grey.shade500)),
                Text('30 days',
                    style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 11,
                        color: Colors.grey.shade500)),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: Text('Cancel',
              style: TextStyle(
                  fontFamily: 'Poppins', color: Colors.grey.shade600)),
        ),
        FilledButton(
          onPressed: _isLoading ? null : _addContact,
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFF4D4DCD),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text('Add Contact',
                  style: TextStyle(fontFamily: 'Poppins')),
        ),
      ],
    );
  }
}
