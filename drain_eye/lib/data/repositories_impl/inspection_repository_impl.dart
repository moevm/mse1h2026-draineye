import 'dart:convert';
import 'dart:io';

import 'package:drain_eye/data/datasources/local_damage_model_datasource.dart';
import 'package:drain_eye/domain/entities/inspection.dart';
import 'package:drain_eye/domain/entities/model_inference_result.dart';
import 'package:drain_eye/domain/repositories/inspection_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

// реализация репозитория: мок истории + tflite + POST новой инспекции
class InspectionRepositoryImpl implements InspectionRepository {
  InspectionRepositoryImpl({
    http.Client? httpClient,
    LocalDamageModelDataSource? damageModelDataSource,
  })  : _httpClient = httpClient ?? http.Client(),
        _damageModel = damageModelDataSource ?? LocalDamageModelDataSource();

  final http.Client _httpClient;
  final LocalDamageModelDataSource _damageModel;

  // ссылка будет меняться
  final String baseUrl = 'https://hpbk3p-95-161-61-238.ru.tuna.am';

  @override
  Stream<List<Inspection>> getUserInspections(int userId) {
    final insp = [
      Inspection(
        id: 1,
        userId: 1,
        timestamp: DateTime(2026, 2, 23, 14, 32),
        photoUrl: 'no',
        material: 'Бетон',
        confidence: 0.92,
        condition: 4,
        defects: List.empty(),
        synchronized: true,
        address: 'ул. Ленина, 15 — колодец #3',
      ),
      Inspection(
        id: 2,
        userId: 1,
        timestamp: DateTime(2026, 2, 22, 10, 15),
        photoUrl: 'no',
        material: 'Пластик',
        confidence: 0.67,
        condition: 3,
        defects: List.empty(),
        synchronized: true,
        address: 'пр. Мира, 8 — труба D500',
      ),
      Inspection(
        id: 3,
        userId: 1,
        timestamp: DateTime(2026, 2, 21, 16, 48),
        photoUrl: 'no',
        material: 'Металл',
        confidence: 0.45,
        condition: 1,
        defects: List.empty(),
        synchronized: true,
        address: 'ул. Садовая, 22 — коллектор',
      ),
      Inspection(
        id: 4,
        userId: 1,
        timestamp: DateTime(2026, 2, 20, 9, 3),
        photoUrl: 'no',
        material: 'Бетон',
        confidence: 0.98,
        condition: 5,
        defects: List.empty(),
        synchronized: true,
        address: 'ул. Пушкина, 4 — дренаж',
      ),
    ];
    final result = Stream.value(insp);
    if (kDebugMode) {
      print('>>> Returning ${insp.length} inspections from repo');
    }
    return result;
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
