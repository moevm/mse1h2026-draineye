import 'dart:convert';
import 'dart:io';

import 'package:drain_eye/core/api_config.dart';
import 'package:drain_eye/core/network_connectivity.dart';
import 'package:drain_eye/core/offline_inspection_exception.dart';
import 'package:drain_eye/data/datasources/local_damage_model_datasource.dart';
import 'package:drain_eye/data/datasources/offline_inspection_cache.dart';
import 'package:drain_eye/data/models/inspection_model.dart';
import 'package:drain_eye/data/models/pending_inspection_model.dart';
import 'package:drain_eye/domain/entities/inspection.dart';
import 'package:drain_eye/domain/entities/inspection_submit_result.dart';
import 'package:drain_eye/domain/entities/inspection_sync_status.dart';
import 'package:drain_eye/domain/entities/model_inference_result.dart';
import 'package:drain_eye/domain/repositories/inspection_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';

class InspectionRepositoryImpl implements InspectionRepository {
  InspectionRepositoryImpl({
    http.Client? httpClient,
    LocalDamageModelDataSource? damageModelDataSource,
    SharedPreferences? prefs,
    OfflineInspectionCache? offlineCache,
    NetworkConnectivity? networkConnectivity,
  })  : _httpClient = httpClient ?? http.Client(),
        _damageModel = damageModelDataSource ?? LocalDamageModelDataSource(),
        _prefs = prefs,
        _offlineCache = offlineCache ?? OfflineInspectionCache(prefs: prefs),
        _network = networkConnectivity ?? NetworkConnectivity(httpClient: httpClient);

  final http.Client _httpClient;
  final LocalDamageModelDataSource _damageModel;
  final SharedPreferences? _prefs;
  final OfflineInspectionCache _offlineCache;
  final NetworkConnectivity _network;

  static const _authTokenPrefsKey = 'auth_token';

  @override
  Stream<List<Inspection>> getUserInspections() {
    return Stream.fromFuture(_loadInspections());
  }

  Future<List<Inspection>> _loadInspections() async {
    List<Inspection> server = [];
    try {
      if (await _network.canReachApi()) {
        server = await _fetchMyInspections();
      }
    } catch (e) {
      if (kDebugMode) {
        print('my_inspections failed: $e');
      }
    }

    final pending = await _offlineCache.loadAll();
    final local = pending
        .asMap()
        .entries
        .map((e) => _pendingToDomain(e.value, e.key))
        .toList();

    return [...local, ...server];
  }

  Future<List<Inspection>> _fetchMyInspections() async {
    final token = await _authToken();
    final uri = Uri.parse(ApiConfig.myInspections);
    final response = await _httpClient.get(
      uri,
      headers: {
        ...ApiConfig.defaultHeaders,
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        'my_inspections: ${response.statusCode} ${response.body}',
      );
    }

    if (kDebugMode) {
      final preview = response.body.length > 2000
          ? '${response.body.substring(0, 2000)}...'
          : response.body;
      debugPrint('[my_inspections] ${response.statusCode} body: $preview');
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! List) {
      throw FormatException('Ожидался JSON-массив инспекций');
    }

    if (kDebugMode) {
      debugPrint('[my_inspections] записей: ${decoded.length}');
    }

    final out = <Inspection>[];
    for (var i = 0; i < decoded.length; i++) {
      final raw = decoded[i];
      if (raw is! Map) {
        throw FormatException('Элемент списка инспекций не объект');
      }
      final map = Map<String, dynamic>.from(raw);
      if (kDebugMode) {
        final id = map['inspection_id'] ?? map['id'];
        debugPrint(
          '[my_inspections][$i] id=$id '
          'status_sync=${map['status_sync']} status=${map['status']}',
        );
      }
      final dto = InspectionModel.fromJson(map);
      out.add(dto.toDomain(index: i));
    }

    if (kDebugMode) {
      debugPrint('[my_inspections] загружено в UI: ${out.length}');
    }

    return out;
  }

  Inspection _pendingToDomain(PendingInspectionModel p, int index) {
    final mv = p.modelResult;
    final defects =
        mv.damageType.isEmpty ? <String>[] : <String>[mv.damageType];
    final confidence = mv.accuracyModel.clamp(0.0, 1.0);

    return Inspection(
      id: p.localId.hashCode.abs() % 1000000000,
      userId: int.tryParse(p.engineerId) ?? 0,
      timestamp: p.createdAt,
      photoUrl: p.photoPaths.isNotEmpty ? p.photoPaths.first : '',
      photoUrls: p.photoPaths,
      material: mv.material ?? 'unknown',
      confidence: confidence,
      condition: (mv.state ?? 0).clamp(0, 5),
      defects: defects,
      synchronized: false,
      address: p.address,
      damageTypeCode: mv.damageType,
      damageDegree: mv.damageDegree,
      syncStatus: InspectionSyncStatus.cached,
    );
  }

  @override
  Future<ModelInferenceResult> runDamageModel(List<String> photoPaths) {
    return _damageModel.runAverageProbabilities(photoPaths);
  }

  @override
  Future<InspectionSubmitResult> submitInspection({
    required String engineerId,
    required String address,
    required List<String> photoPaths,
    required ModelInferenceResult modelResult,
  }) async {
    if (photoPaths.isEmpty) {
      throw ArgumentError('Нет фотографий для сохранения инспекции');
    }
    if (!await _network.canReachApi()) {
      throw const OfflineInspectionException();
    }
    return _uploadInspection(
      engineerId: engineerId,
      address: address.trim(),
      photoPaths: photoPaths,
      modelResult: modelResult,
    );
  }

  @override
  Future<void> cacheInspection({
    required String engineerId,
    required String address,
    required List<String> photoPaths,
    required ModelInferenceResult modelResult,
  }) async {
    if (photoPaths.isEmpty) {
      throw ArgumentError('Нет фотографий для сохранения в кэш');
    }
    await _offlineCache.save(
      engineerId: engineerId,
      address: address.trim(),
      photoPaths: photoPaths,
      modelResult: modelResult,
    );
  }

  @override
  Future<int> pendingInspectionsCount() => _offlineCache.count();

  @override
  Future<void> syncPendingInspections() async {
    if (!await _network.canReachApi()) return;

    final pending = await _offlineCache.loadAll();
    for (final item in pending) {
      try {
        await _uploadInspection(
          engineerId: item.engineerId,
          photoPaths: item.photoPaths,
          modelResult: item.modelResult,
          address: item.address,
          name: item.name,
        );
        await _offlineCache.remove(item.localId);
      } catch (e) {
        if (kDebugMode) {
          print('sync pending ${item.localId} failed: $e');
        }
      }
    }
  }

  Future<InspectionSubmitResult> _uploadInspection({
    required String engineerId,
    required List<String> photoPaths,
    required ModelInferenceResult modelResult,
    String address = '',
    String name = 'Инспекция',
  }) async {
    final token = await _authToken();
    final uri = Uri.parse(ApiConfig.addInspection);

    final inspectionPayload = <String, dynamic>{
      'engineer_id': engineerId,
      'timestamp': DateTime.now().toIso8601String(),
      'model_verdict': <String, dynamic>{
        'material': modelResult.material ?? 'unknown',
        'state': modelResult.state ?? 0,
        'damage_type': modelResult.damageType,
        'damage_degree': modelResult.damageDegree ?? 0.0,
        'accuracy_model': modelResult.accuracyModel,
        'comments': modelResult.comments ?? '',
      },
      'address': address,
      'name': name,
      'photos': <String>[],
      'status_sync': 'pending',
    };

    final request = http.MultipartRequest('POST', uri)
      ..headers.addAll(ApiConfig.defaultHeaders)
      ..headers['Authorization'] = 'Bearer $token'
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

    return _parseSubmitResponse(response.body);
  }

  InspectionSubmitResult _parseSubmitResponse(String body) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) {
        final statusRaw =
            decoded['status'] ?? decoded['status_sync'];
        return InspectionSubmitResult(
          inspectionId: decoded['inspection_id']?.toString(),
          status: InspectionSyncStatus.fromApi(statusRaw?.toString()),
        );
      }
    } catch (_) {
      // Ответ без JSON — считаем успешной отправкой.
    }
    return const InspectionSubmitResult(status: InspectionSyncStatus.synced);
  }

  static String _basename(String path) {
    final i = path.lastIndexOf('/');
    final j = path.lastIndexOf(r'\');
    final k = i > j ? i : j;
    return k < 0 ? path : path.substring(k + 1);
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
