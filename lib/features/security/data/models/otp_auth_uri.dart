/// Parses `otpauth://totp/` URIs per RFC 6238 and the Key Uri Format.
///
/// Example URI:
///   otpauth://totp/Example:alice@example.com?secret=JBSWY3DPEHPK3PXP&issuer=Example&algorithm=SHA1&digits=6&period=30
class OtpAuthUri {
  /// Base32-encoded secret key.
  final String secret;

  /// Issuer name (e.g., "Google", "GitHub").
  final String? issuer;

  /// Label (typically account identifier like "user@example.com").
  final String? label;

  /// Number of digits in the TOTP code (default 6).
  final int digits;

  /// Time period in seconds (default 30).
  final int period;

  /// Hash algorithm: SHA1, SHA256, or SHA512.
  final String algorithm;

  const OtpAuthUri({
    required this.secret,
    this.issuer,
    this.label,
    this.digits = 6,
    this.period = 30,
    this.algorithm = 'SHA1',
  });

  /// Parse an otpauth:// URI string into an [OtpAuthUri].
  ///
  /// Validates that the scheme is `otpauth` and the host is `totp`.
  /// Throws [FormatException] for invalid URIs.
  factory OtpAuthUri.parse(String uriString) {
    final uri = Uri.parse(uriString);

    if (uri.scheme != 'otpauth') {
      throw FormatException(
        'Invalid scheme: expected "otpauth", got "${uri.scheme}"',
        uriString,
      );
    }

    if (uri.host != 'totp') {
      throw FormatException(
        'Invalid type: expected "totp", got "${uri.host}"',
        uriString,
      );
    }

    final params = uri.queryParameters;

    final secret = params['secret'];
    if (secret == null || secret.isEmpty) {
      throw FormatException('Missing required "secret" parameter', uriString);
    }

    // Extract label from path (after the leading /)
    String? label;
    if (uri.path.isNotEmpty) {
      label = Uri.decodeComponent(
        uri.path.startsWith('/') ? uri.path.substring(1) : uri.path,
      );
      if (label.isEmpty) label = null;
    }

    // Issuer from query param takes precedence over label prefix
    final issuer = params['issuer'];

    final digits = int.tryParse(params['digits'] ?? '') ?? 6;
    final period = int.tryParse(params['period'] ?? '') ?? 30;
    final algorithm = (params['algorithm'] ?? 'SHA1').toUpperCase();

    return OtpAuthUri(
      secret: secret,
      issuer: issuer,
      label: label,
      digits: digits,
      period: period,
      algorithm: algorithm,
    );
  }

  /// Convert back to an otpauth:// URI string.
  String toUriString() {
    final params = <String, String>{
      'secret': secret,
      if (issuer != null) 'issuer': issuer!,
      'digits': digits.toString(),
      'period': period.toString(),
      'algorithm': algorithm,
    };

    final path = label != null ? '/${Uri.encodeComponent(label!)}' : '/';

    return Uri(
      scheme: 'otpauth',
      host: 'totp',
      path: path,
      queryParameters: params,
    ).toString();
  }

  @override
  String toString() =>
      'OtpAuthUri(issuer: $issuer, label: $label, digits: $digits, period: $period, algorithm: $algorithm)';
}
