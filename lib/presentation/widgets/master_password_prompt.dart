// File: lib/presentation/widgets/master_password_prompt.dart
import 'package:flutter/material.dart';

/// Shows a bottom sheet prompting for the master password.
///
/// Used by both home_page.dart (quick unlock setup) and settings_page.dart
/// (PIN / biometrics configuration).
Future<void> showMasterPasswordPrompt({
  required BuildContext context,
  String title = 'Enter Master Password',
  String subtitle = 'Required to continue',
  required Future<void> Function(String masterPassword) onSubmit,
}) {
  final controller = TextEditingController();
  bool obscure = true;
  bool isSubmitting = false;

  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) {
      return StatefulBuilder(
        builder: (ctx, setSheetState) {
          return Padding(
            padding: EdgeInsets.only(
              left: 24,
              right: 24,
              top: 24,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle bar
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE0E0E0),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13,
                    color: Colors.grey.shade500,
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: controller,
                  obscureText: obscure,
                  autofocus: true,
                  decoration: InputDecoration(
                    labelText: 'Master Password',
                    labelStyle: const TextStyle(fontFamily: 'Poppins'),
                    filled: true,
                    fillColor: const Color(0xFFF8FAFC),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide:
                          const BorderSide(color: Color(0xFFE8EDF5)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(
                          color: Color(0xFF4D4DCD), width: 2),
                    ),
                    prefixIcon: const Icon(Icons.lock_outline,
                        color: Color(0xFF4D4DCD)),
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscure
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        setSheetState(() => obscure = !obscure);
                      },
                    ),
                  ),
                  onSubmitted: isSubmitting
                      ? null
                      : (_) async {
                          if (controller.text.trim().isEmpty) return;
                          setSheetState(() => isSubmitting = true);
                          Navigator.of(ctx).pop();
                          await onSubmit(controller.text.trim());
                        },
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: isSubmitting
                        ? null
                        : () async {
                            if (controller.text.trim().isEmpty) return;
                            setSheetState(() => isSubmitting = true);
                            Navigator.of(ctx).pop();
                            await onSubmit(controller.text.trim());
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4D4DCD),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                    child: isSubmitting
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white),
                          )
                        : const Text(
                            'Continue',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}
