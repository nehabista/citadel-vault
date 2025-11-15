// File: lib/core/utils/error_sanitizer.dart
// Utility for sanitizing exception messages before displaying to users.
//
// Prevents leaking server paths, SQL errors, stack traces, or other
// internal details through error messages shown in snackbars and dialogs.

/// Sanitizes an error object's message for safe display to the user.
///
/// Strips internal details such as:
/// - PocketBase [ClientException] internals (extracts just the message)
/// - Server file paths and SQL error details
/// - Excessively long messages (truncated to a generic fallback)
///
/// Usage:
/// ```dart
/// } catch (e) {
///   showCitadelSnackBar(context, sanitizeErrorMessage(e));
/// }
/// ```
String sanitizeErrorMessage(Object error) {
  final msg = error.toString();

  // PocketBase ClientException: extract just the user-friendly message.
  if (msg.contains('ClientException')) {
    final match = RegExp(r'message:\s*(.+?)[,}]').firstMatch(msg);
    return match?.group(1)?.trim() ?? 'Something went wrong. Please try again.';
  }

  // BreachServiceError: already has a user-friendly message field.
  if (msg.contains('BreachServiceError')) {
    final match = RegExp(r'BreachServiceError\([^)]*\):\s*(.+)').firstMatch(msg);
    return match?.group(1)?.trim() ?? 'Breach check failed. Please try again.';
  }

  // Strip messages that look like they contain server internals.
  if (msg.contains('SQL') ||
      msg.contains('SQLITE') ||
      msg.contains('stack trace') ||
      msg.contains('/home/') ||
      msg.contains('/var/') ||
      msg.contains('at 0x')) {
    return 'An unexpected error occurred. Please try again.';
  }

  // Truncate overly long messages that likely contain debug info.
  if (msg.length > 200) {
    return 'An unexpected error occurred.';
  }

  return msg;
}
