import 'package:flutter/material.dart';

/// Shared input decoration used across all vault item form fields.
///
/// Provides the consistent Citadel styling: rounded corners, Poppins labels,
/// subtle fill color, and the primary accent border on focus.
InputDecoration citadelInputDecoration(String label) {
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

/// Shared required-field validator.
String? requiredValidator(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'This field is required';
  }
  return null;
}
