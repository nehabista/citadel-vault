import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;

import 'api_exception.dart';

abstract class BaseHttpService {
  final _client = http.Client();
  String baseUrl = "";

  /// Security headers applied to every outbound request.
  static const _securityHeaders = {
    'X-Content-Type-Options': 'nosniff',
    'Cache-Control': 'no-store',
  };

  set setBaseUrl(String url) {
    baseUrl = url;
  }

  Future<ProcessResponseModel> get(String endpoint) async {
    log('[HTTP] GET $endpoint');
    try {
      final uri = Uri.parse('$baseUrl/$endpoint');
      final response = await _client.get(uri, headers: _securityHeaders);
      return _processResponse(response: response);
    } catch (e) {
      throw ApiException(message: e.toString(), code: 500);
    }
  }

  Future<ProcessResponseModel> post(
      {required String endpoint,
      required Map<String, dynamic>? body,
      Map<String, String>? headers}) async {
    try {
      final uri = Uri.parse('$baseUrl/$endpoint');
      final mergedHeaders = {..._securityHeaders, ...?headers};
      final response =
          await _client.post(uri, headers: mergedHeaders, body: jsonEncode(body));
      log('[HTTP] POST $endpoint -> ${response.statusCode}');
      return _processResponse(response: response);
    } catch (e) {
      log('[HTTP] POST $endpoint failed: ${e.runtimeType}');
      throw ApiException(message: e.toString(), code: 500);
    }
  }

  ProcessResponseModel _processResponse(
      {required http.Response response, bool? logsEnabled}) {
    if (response.statusCode == 200) {
      return ProcessResponseModel(
        data: utf8.decode(response.bodyBytes),
        statusCode: response.statusCode,
      );
    } else {
      throw ApiException(
        message:
            'Failed to process request with status code: ${response.statusCode}',
        code: response.statusCode,
        logs: logsEnabled ?? false ? response.body : null,
      );
    }
  }
}

class ProcessResponseModel {
  final String data;
  final int statusCode;

  ProcessResponseModel({required this.data, required this.statusCode});

  @override
  String toString() => 'ProcessResponseModel: $data (Status code: $statusCode)';

  ProcessResponseModel processResponseModelFromMap(Map<String, dynamic> json) =>
      ProcessResponseModel(
        data: json["data"],
        statusCode: json["statusCode"],
      );

  Map<String, dynamic> processResponseModelToMap(ProcessResponseModel data) => {
        "data": data.data,
        "statusCode": data.statusCode,
      };
}
