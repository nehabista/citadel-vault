import 'dart:convert';

import 'package:http/http.dart' as http;

/// Result from the logo.dev search API.
class LogoResult {
  final String name;
  final String domain;
  final String logoUrl;

  const LogoResult({
    required this.name,
    required this.domain,
    required this.logoUrl,
  });

  factory LogoResult.fromJson(Map<String, dynamic> json) => LogoResult(
        name: json['name'] as String? ?? '',
        domain: json['domain'] as String? ?? '',
        logoUrl: json['logo_url'] as String? ?? '',
      );
}

/// Service that searches logo.dev for brand logos by query string.
class LogoSearchService {
  static const _baseUrl = 'https://www.logo.dev/api/search';
  static const _token = 'pk_live_6a1a28fd-6420-4492-aeb0-b297461d9de2';

  final http.Client _client;

  LogoSearchService({http.Client? client}) : _client = client ?? http.Client();

  /// Search for logos matching [query].
  ///
  /// Returns an empty list if [query] is shorter than 2 characters,
  /// the request fails, or the response cannot be parsed.
  Future<List<LogoResult>> search(String query) async {
    if (query.length < 2) return [];

    try {
      final uri = Uri.parse('$_baseUrl?q=${Uri.encodeComponent(query)}');
      final response = await _client.get(
        uri,
        headers: {
          'Authorization': 'Bearer $_token',
        },
      );

      if (response.statusCode != 200) return [];

      final List<dynamic> data = jsonDecode(response.body);
      return data
          .map((e) => LogoResult.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  /// Dispose the underlying HTTP client.
  void dispose() {
    _client.close();
  }
}
