class ApiException implements Exception {
  final String message;
  final int code;
  final dynamic logs;

  ApiException({
    required this.message,
    required this.code,
    this.logs,
  });
  @override
  String toString() => 'ApiException: $message (Status code: $code)';
}
