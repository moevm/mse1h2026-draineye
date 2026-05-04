import 'dart:convert';

import 'package:drain_eye/data/models/inspection_model.dart';
import 'package:drain_eye/domain/entities/inspection.dart';
import 'package:drain_eye/domain/entities/model_inference_result.dart';
import 'package:drain_eye/domain/repositories/inspection_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// Web-реализация без dart:io и локального tflite.
class InspectionRepositoryImpl implements InspectionRepository {
  InspectionRepositoryImpl({
    http.Client? httpClient,
    SharedPreferences? prefs,
  })  : _httpClient = httpClient ?? http.Client(),
        _prefs = prefs;

  final http.Client _httpClient;
  final SharedPreferences? _prefs;

  // ссылка будет меняться
  final String baseUrl = 'https://3yxoyp-95-161-60-178.ru.tuna.am';
  static const _authTokenPrefsKey = 'auth_token';

  @override
  Stream<List<Inspection>> getUserInspections() {
    return Stream.fromFuture(_fetchMyInspections());
  }

  Future<List<Inspection>> _fetchMyInspections() async {
    final token = await _authToken();
    final uri = Uri.parse('$baseUrl/inspector/my_inspections');
    final response = await _httpClient.get(
      uri,
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        'my_inspections: ${response.statusCode} ${response.body}',
      );
    }
    final decoded = jsonDecode(response.body);
    if (decoded is! List) {
      throw FormatException('Ожидался JSON-массив инспекций');
    }
    final out = <Inspection>[];
    for (var i = 0; i < decoded.length; i++) {
      final raw = decoded[i];
      if (raw is! Map) {
        throw FormatException('Элемент списка инспекций не объект');
      }
      final dto = InspectionModel.fromJson(Map<String, dynamic>.from(raw));
      out.add(dto.toDomain(index: i));
    }
    if (kDebugMode) {
      print('>>> my_inspections: ${out.length} записей');
    }
    return out;
  }

  @override
  Future<ModelInferenceResult> runDamageModel(List<String> photoPaths) {
    throw UnsupportedError('Локальная TFLite-модель на web не поддержана');
  }

  @override
  Future<void> createInspection({
    required int userId,
    required List<String> photoPaths,
    required ModelInferenceResult modelResult,
  }) {
    throw UnsupportedError('Отправка инспекций с файлами на web не поддержана');
  }

  Future<String> _authToken() async {
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    final token = prefs.getString(_authTokenPrefsKey);
    if (token == null || token.isEmpty) {
      throw StateError('токен авторизации не найден');
    }
    return token;
  }
}
