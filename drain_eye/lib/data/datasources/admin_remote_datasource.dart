import 'dart:convert';
import 'package:drain_eye/core/api_config.dart';
import 'package:drain_eye/core/token_storage.dart';
import 'package:drain_eye/domain/entities/admin_inspection.dart';
import 'package:drain_eye/domain/entities/admin_user.dart';
import 'package:http/http.dart' as http;

class AdminRemoteDataSource {
  final http.Client _client;

  AdminRemoteDataSource({http.Client? client}) : _client = client ?? http.Client();

  Future<PaginatedResponse<AdminUser>> getUsers({
    String role = 'inspector',
    int limit = 50,
    String? nextCursor,
    bool activeOnly = true,
  }) async {
    final query = <String, String>{
      'role': role,
      'limit': '$limit',
      'active_only': '$activeOnly',
    };
    if (nextCursor != null) query['next_cursor'] = nextCursor;

    final uri = Uri.parse('${ApiConfig.baseUrl}/admin/users/by-role').replace(queryParameters: query);
    final response = await _client.get(uri, headers: await _headers());
    _checkStatus(response);

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final users = (body['users'] as List)
        .map((e) => AdminUser.fromJson(e as Map<String, dynamic>))
        .toList();

    return PaginatedResponse<AdminUser>(
      items: users,
      nextCursor: body['next_cursor'] as String?,
      hasMore: body['has_more'] as bool? ?? false,
      totalReturned: (body['total_returned'] as num?)?.toInt() ?? users.length,
    );
  }

  Future<PaginatedResponse<AdminInspection>> getInspections({
    int limit = 50,
    String? nextCursor,
  }) async {
    final query = <String, String>{'limit': '$limit'};
    if (nextCursor != null) query['next_cursor'] = nextCursor;

    final uri = Uri.parse('${ApiConfig.baseUrl}/admin/inspections').replace(queryParameters: query);
    final response = await _client.get(uri, headers: await _headers());
    _checkStatus(response);

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final inspections = (body['inspections'] as List)
        .map((e) => AdminInspection.fromJson(e as Map<String, dynamic>))
        .toList();

    return PaginatedResponse<AdminInspection>(
      items: inspections,
      nextCursor: body['next_cursor'] as String?,
      hasMore: body['has_more'] as bool? ?? false,
      totalReturned: (body['total_returned'] as num?)?.toInt() ?? inspections.length,
    );
  }

  Future<DashboardMetrics> getDashboardMetrics() async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/admin/metrics/dashboard');
    final response = await _client.get(uri, headers: await _headers());
    _checkStatus(response);
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    return DashboardMetrics.fromJson(body);
  }

  Future<Map<String, String>> _headers() async {
    final token = await TokenStorage.getToken();
    return {
      'Accept': 'application/json',
      'tuna-skip-browser-warning': 'true',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  void _checkStatus(http.Response response) {
    if (response.statusCode == 401 || response.statusCode == 403) {
      throw AdminException('Нет доступа: войдите как администратор');
    }
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw AdminException('Ошибка сервера: ${response.statusCode}');
    }
  }
}

class AdminException implements Exception {
  final String message;
  const AdminException(this.message);

  @override
  String toString() => message;
}
