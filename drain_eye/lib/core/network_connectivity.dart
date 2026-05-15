import 'dart:async';
import 'dart:io';

import 'package:drain_eye/core/api_config.dart';
import 'package:http/http.dart' as http;

/// Проверка доступности сети и API (для UC-10).
class NetworkConnectivity {
  NetworkConnectivity({http.Client? httpClient})
      : _httpClient = httpClient ?? http.Client();

  final http.Client _httpClient;

  Future<bool> hasInternet() async {
    try {
      final result = await InternetAddress.lookup('google.com')
          .timeout(const Duration(seconds: 3));
      return result.isNotEmpty && result.first.rawAddress.isNotEmpty;
    } on SocketException {
      return false;
    } on TimeoutException {
      return false;
    }
  }

  Future<bool> canReachApi() async {
    if (!await hasInternet()) return false;
    try {
      final uri = Uri.parse(ApiConfig.baseUrl);
      final response = await _httpClient
          .head(uri, headers: ApiConfig.defaultHeaders)
          .timeout(const Duration(seconds: 5));
      return response.statusCode < 500;
    } catch (_) {
      return false;
    }
  }
}
