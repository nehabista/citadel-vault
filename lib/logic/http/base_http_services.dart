import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;

import 'api_exception.dart';

abstract class BaseHttpService {
  final _client = http.Client();
  String baseUrl = "";

  set setBaseUrl(String url) {
    baseUrl = url;
  }

  Future<ProcessResponseModel> get(String endpoint) async {
    log('GET request to $baseUrl/$endpoint');
    try {
      final uri = Uri.parse('$baseUrl/$endpoint');
      final response = await _client.get(uri);
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
      final response =
          await _client.post(uri, headers: headers, body: jsonEncode(body));
      log("""{
        'endpoint': endpoint,
        "headers": headers ?? _headers(token!),
        "uri": '$baseUrl/$endpoint',
        "response": response.body,
        "responseCode": response.statusCode,
        'body': jsonEncode(body),
      }""");
      return _processResponse(response: response);
    } catch (e) {
      log("""{
        'message': e.toString(),
        'endpoint': endpoint,
        "headers": headers ?? _headers(token!),
        "uri": '$baseUrl/$endpoint',
        'body': jsonEncode(body),
      }""");

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
