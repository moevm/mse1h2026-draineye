import 'dart:convert';
import 'dart:io';

import 'package:drain_eye/data/datasources/local_damage_model_datasource.dart';
import 'package:drain_eye/data/models/inspection_model.dart';
import 'package:drain_eye/domain/entities/inspection.dart';
import 'package:drain_eye/domain/entities/model_inference_result.dart';
import 'package:drain_eye/domain/repositories/inspection_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

// реализация репозитория: GET инспекций с сервера, tflite, POST новой инспекции
class InspectionRepositoryImpl implements InspectionRepository {
  InspectionRepositoryImpl({
    http.Client? httpClient,
    LocalDamageModelDataSource? damageModelDataSource,
  })  : _httpClient = httpClient ?? http.Client(),
        _damageModel = damageModelDataSource ?? LocalDamageModelDataSource();

  final http.Client _httpClient;
  final LocalDamageModelDataSource _damageModel;

  // ссылка будет меняться
  final String baseUrl = 'https://5ou3ck-95-161-61-238.ru.tuna.am';

  @override
  Stream<List<Inspection>> getUserInspections(int userId) {
    return Stream.fromFuture(_fetchInspectionsForUser(userId));
  }

  /// GET `/inspections_by_user/{id}` — список инспекций инженера (как в server-backend).
  Future<List<Inspection>> _fetchInspectionsForUser(int userId) async {
    final uri = Uri.parse(
      '$baseUrl/inspections_by_user/${Uri.encodeComponent(userId.toString())}',
    );
    final response = await _httpClient.get(
      uri,
      headers: {'Accept': 'application/json'},
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        'get_inspections: ${response.statusCode} ${response.body}',
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
      out.add(dto.toDomain(userId: userId, index: i));
    }
    if (kDebugMode) {
      print('>>> getUserInspections($userId): ${out.length} записей');
    }
    return out;
  }

  @override
  Future<ModelInferenceResult> runDamageModel(List<String> photoPaths) {
    return _damageModel.runAverageProbabilities(photoPaths);
  }

  @override
  Future<void> createInspection({
    required int userId,
    required List<String> photoPaths,
    required ModelInferenceResult modelResult,
  }) async {
    final uri = Uri.parse('$baseUrl/add_inspection');

    // FastAPI: inspection_json: str = Form(...), files: List[UploadFile] = File(None)
    // ModelVerdictSchema — все поля обязательны; null из приложения заменяем заглушками.
    final inspectionPayload = <String, dynamic>{
      'engineer_id': userId.toString(),
      'timestamp': DateTime.now().toIso8601String(),
      'model_verdict': <String, dynamic>{
        'material': modelResult.material ?? 'unknown',
        'state': modelResult.state ?? 0,
        'damage_type': modelResult.damageType,
        'damage_degree': modelResult.damageDegree ?? 0.0,
        'accuracy_model': modelResult.accuracyModel,
        'comments': modelResult.comments ?? '',
      },
      'address': '',
      'name': 'Инспекция',
      'photos': <String>[],
      'status_sync': 'save',
    };

    final request = http.MultipartRequest('POST', uri)
      ..fields['inspection_json'] = jsonEncode(inspectionPayload);

    for (final p in photoPaths) {
      final f = File(p);
      if (!await f.exists()) {
        throw StateError('Файл снимка не найден: $p');
      }
      request.files.add(
        await http.MultipartFile.fromPath(
          'files',
          p,
          filename: _basename(p),
          contentType: MediaType('image', 'jpeg'),
        ),
      );
    }

    final streamed = await _httpClient.send(request);
    final response = await http.Response.fromStream(streamed);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        'add_inspection: ${response.statusCode} ${response.body}',
      );
    }
  }

  static String _basename(String path) {
    final i = path.lastIndexOf('/');
    final j = path.lastIndexOf(r'\');
    final k = i > j ? i : j;
    return k < 0 ? path : path.substring(k + 1);
  }
}
