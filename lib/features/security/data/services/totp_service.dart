import 'package:otp/otp.dart';

/// Service for generating TOTP codes per RFC 6238.
///
/// Supports SHA1, SHA256, and SHA512 algorithms.
/// Uses the `otp` package with `isGoogle: true` for Google Authenticator
/// compatibility (per D-13).
class TotpService {
  /// Generate a TOTP code from a Base32-encoded secret.
  ///
  /// Returns a zero-padded string of [digits] length.
  /// [algorithm] must be one of: SHA1, SHA256, SHA512.
  String generateCode({
    required String base32Secret,
    int digits = 6,
    int period = 30,
    String algorithm = 'SHA1',
  }) {
    return OTP.generateTOTPCodeString(
      base32Secret,
      DateTime.now().millisecondsSinceEpoch,
      length: digits,
      interval: period,
      algorithm: _mapAlgorithm(algorithm),
      isGoogle: true,
    );
  }

  /// Get the number of seconds remaining in the current TOTP period.
  ///
  /// Returns a value between 0 and [period].
  int remainingSeconds({int period = 30}) {
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    return period - (now % period);
  }

  /// Map algorithm string to the OTP package's Algorithm enum.
  Algorithm _mapAlgorithm(String algorithm) {
    switch (algorithm.toUpperCase()) {
      case 'SHA256':
        return Algorithm.SHA256;
      case 'SHA512':
        return Algorithm.SHA512;
      case 'SHA1':
      default:
        return Algorithm.SHA1;
    }
  }
}
