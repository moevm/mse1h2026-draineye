import 'dart:convert';
import 'dart:io';

import 'package:drain_eye/data/models/pending_inspection_model.dart';
import 'package:drain_eye/domain/entities/model_inference_result.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Локальный кэш инспекций (UC-10).
class OfflineInspectionCache {
  OfflineInspectionCache({SharedPreferences? prefs}) : _prefs = prefs;

  static const _storageKey = 'pending_inspections_v1';

  SharedPreferences? _prefs;

  Future<SharedPreferences> _preferences() async {
    return _prefs ??= await SharedPreferences.getInstance();
  }

  Future<List<PendingInspectionModel>> loadAll() async {
    final prefs = await _preferences();
    final raw = prefs.getString(_storageKey);
    if (raw == null || raw.isEmpty) return [];
    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((e) => PendingInspectionModel.fromJson(
              Map<String, dynamic>.from(e as Map),
            ))
        .toList();
  }

  Future<int> count() async {
    final items = await loadAll();
    return items.length;
  }

  Future<PendingInspectionModel> save({
    required String engineerId,
    required List<String> photoPaths,
    required ModelInferenceResult modelResult,
    String address = '',
    String name = 'Инспекция',
  }) async {
    final localId =
        'local_${DateTime.now().microsecondsSinceEpoch}';
    final persistedPhotos = await _persistPhotos(localId, photoPaths);

    final entry = PendingInspectionModel(
      localId: localId,
      engineerId: engineerId,
      photoPaths: persistedPhotos,
      modelResult: modelResult,
      createdAt: DateTime.now(),
      address: address,
      name: name,
    );

    final all = await loadAll()..add(entry);
    await _writeAll(all);
    return entry;
  }

  Future<void> remove(String localId) async {
    final all = await loadAll();
    final remaining =
        all.where((e) => e.localId != localId).toList();
    await _deletePhotoDir(localId);
    await _writeAll(remaining);
  }

  Future<List<String>> _persistPhotos(
    String localId,
    List<String> sourcePaths,
  ) async {
    if (sourcePaths.isEmpty) {
      throw ArgumentError('Нет фото для сохранения в кэш');
    }

    final baseDir = await _pendingRootDir();
    final dir = Directory('${baseDir.path}${Platform.pathSeparator}$localId');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }

    final out = <String>[];
    for (var i = 0; i < sourcePaths.length; i++) {
      final src = File(sourcePaths[i]);
      if (!await src.exists()) {
        throw StateError('Файл снимка не найден: ${sourcePaths[i]}');
      }
      final destPath =
          '${dir.path}${Platform.pathSeparator}photo_$i.jpg';
      await src.copy(destPath);
      out.add(destPath);
    }
    return out;
  }

  /// Каталог кэша в systemTemp (без path_provider / JNI).
  Future<Directory> _pendingRootDir() async {
    final dir = Directory(
      '${Directory.systemTemp.path}${Platform.pathSeparator}drain_eye_pending',
    );
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  Future<void> _deletePhotoDir(String localId) async {
    final baseDir = await _pendingRootDir();
    final dir = Directory('${baseDir.path}${Platform.pathSeparator}$localId');
    if (await dir.exists()) {
      await dir.delete(recursive: true);
    }
  }

  Future<void> _writeAll(List<PendingInspectionModel> items) async {
    final prefs = await _preferences();
    final encoded = jsonEncode(items.map((e) => e.toJson()).toList());
    await prefs.setString(_storageKey, encoded);
  }
}
