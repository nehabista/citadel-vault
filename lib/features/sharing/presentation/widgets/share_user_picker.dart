// File: lib/features/sharing/presentation/widgets/share_user_picker.dart
// Email-based user lookup widget for sharing vault items with Citadel users.
// Per D-20: email lookup for recipient.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/sharing_providers.dart';

/// Widget that allows searching for a Citadel user by email address.
///
/// Shows a text field for email input with a "Look up" action.
/// On successful lookup, displays user info with a "Share" button.
/// Calls [onUserSelected] with the userId and email when user confirms.
class ShareUserPicker extends ConsumerStatefulWidget {
  /// Callback when a user is selected for sharing.
  final void Function(String userId, String email) onUserSelected;

  const ShareUserPicker({
    super.key,
    required this.onUserSelected,
  });

  @override
  ConsumerState<ShareUserPicker> createState() => _ShareUserPickerState();
}

class _ShareUserPickerState extends ConsumerState<ShareUserPicker> {
  final _emailController = TextEditingController();
  final _focusNode = FocusNode();

  bool _isSearching = false;
  String? _foundUserId;
  String? _foundEmail;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _lookupUser() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) return;

    setState(() {
      _isSearching = true;
      _foundUserId = null;
      _foundEmail = null;
      _errorMessage = null;
    });

    try {
      final service = ref.read(sharingServiceProvider);
      final userId = await service.lookupUserByEmail(email);

      if (userId != null) {
        setState(() {
          _foundUserId = userId;
          _foundEmail = email;
          _isSearching = false;
        });
      } else {
        setState(() {
          _errorMessage = 'No Citadel user found with this email';
          _isSearching = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to look up user. Please try again.';
        _isSearching = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Email input field.
        TextField(
          controller: _emailController,
          focusNode: _focusNode,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.search,
          onSubmitted: (_) => _lookupUser(),
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 14,
          ),
          decoration: InputDecoration(
            hintText: 'Enter recipient email',
            hintStyle: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
            prefixIcon: const Icon(
              Icons.email_outlined,
              color: Color(0xFF4D4DCD),
              size: 20,
            ),
            suffixIcon: _isSearching
                ? const Padding(
                    padding: EdgeInsets.all(12),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation(Color(0xFF4D4DCD)),
                      ),
                    ),
                  )
                : IconButton(
                    icon: const Icon(Icons.search, color: Color(0xFF4D4DCD)),
                    onPressed: _lookupUser,
                  ),
            filled: true,
            fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(
                color: Color(0xFF4D4DCD),
                width: 1.5,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Error message.
        if (_errorMessage != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 16),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      color: Colors.red,
                    ),
                  ),
                ),
              ],
            ),
          ),

        // Found user card.
        if (_foundUserId != null && _foundEmail != null)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF4D4DCD).withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: const Color(0xFF4D4DCD).withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor:
                      const Color(0xFF4D4DCD).withValues(alpha: 0.15),
                  child: const Icon(
                    Icons.person,
                    color: Color(0xFF4D4DCD),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Citadel User Found',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF4D4DCD),
                        ),
                      ),
                      Text(
                        _foundEmail!,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 13,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                FilledButton(
                  onPressed: () =>
                      widget.onUserSelected(_foundUserId!, _foundEmail!),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF4D4DCD),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                  ),
                  child: const Text(
                    'Share',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
