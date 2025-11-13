// File: lib/core/utils/pb_filter_sanitizer.dart
// Utility to prevent PocketBase filter injection attacks.
//
// All user-supplied values interpolated into PocketBase filter strings
// MUST be passed through sanitizePbFilter() to escape special characters
// that could alter the filter query semantics.

/// Sanitizes a user-provided string before interpolation into a PocketBase
/// filter expression.
///
/// Escapes backslashes and double quotes to prevent filter injection:
/// ```dart
/// final filter = 'email = "${sanitizePbFilter(userEmail)}"';
/// ```
String sanitizePbFilter(String input) {
  return input.replaceAll('\\', '\\\\').replaceAll('"', '\\"');
}
