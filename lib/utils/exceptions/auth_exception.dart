import 'package:pocketbase/pocketbase.dart' show ClientException;

class AuthException implements Exception {
  final String message;
  final int? statusCode;

  AuthException(this.message, {this.statusCode});

  @override
  String toString() => message;

  // Factory to map from PocketBase ClientException
  factory AuthException.fromClientException(ClientException e) {
    final msg = e.response['message']?.toString().toLowerCase() ?? '';

    // Check specific structured errors
    if (e.response['data'] != null) {
      final data = e.response['data'] as Map;
      if (data.containsKey('identity')) {
        return AuthException(
          'Invalid email address.',
          statusCode: e.statusCode,
        );
      }
      if (data.containsKey('password')) {
        return AuthException('Incorrect password.', statusCode: e.statusCode);
      }
    }

    if (msg.contains('verify')) {
      return AuthException(
        'Please verify your email before logging in.',
        statusCode: e.statusCode,
      );
    }
    if (msg.contains('invalid credentials')) {
      return AuthException(
        'Incorrect email or password.',
        statusCode: e.statusCode,
      );
    }

    if (e.statusCode == 0 || e.isAbort) {
      return AuthException(
        'No internet connection. Please try again.',
        statusCode: e.statusCode,
      );
    }

    return AuthException(
      'Something went wrong. Please try again.',
      statusCode: e.statusCode,
    );
  }
}
