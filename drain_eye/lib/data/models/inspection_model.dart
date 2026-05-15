import 'package:drain_eye/core/inspection_time.dart';
import 'package:drain_eye/domain/entities/inspection.dart';
import 'package:drain_eye/domain/entities/inspection_sync_status.dart';
import 'package:flutter/foundation.dart';

/// DTO ответа API (Firestore / FastAPI) → [Inspection] домена.
class ModelVerdictModel {
  ModelVerdictModel({
    required this.material,
    required this.state,
    required this.damageType,
    this.damageDegree,
    required this.accuracy,
    required this.comments,
  });

  final String material;
  final int state;
  final String damageType;
  final double? damageDegree;
  final double accuracy;
  final String comments;

  factory ModelVerdictModel.fromJson(Map<String, dynamic> json) {
    final acc = json['accuracy_model'] ?? json['accuracy'];
    final accNum = acc is num ? acc.toDouble() : double.tryParse('$acc') ?? 0.0;
    final rawDeg = json['damage_degree'];
    return ModelVerdictModel(
      material: json['material'] as String? ?? 'unknown',
      state: (json['state'] as num?)?.toInt() ?? 0,
      damageType: json['damage_type'] as String? ?? '',
      damageDegree: rawDeg == null ? null : (rawDeg as num).toDouble(),
      accuracy: accNum,
      comments: json['comments'] as String? ?? '',
    );
  }
}

class InspectionModel {
  InspectionModel({
    this.inspectionId,
    required this.engineerId,
    required this.timestamp,
    required this.modelVerdict,
    required this.address,
    required this.name,
    required this.photos,
    required this.statusSync,
  });

  final String? inspectionId;
  final String engineerId;
  final DateTime timestamp;
  final ModelVerdictModel modelVerdict;
  final String address;
  final String name;
  final List<String> photos;
  final String statusSync;

  factory InspectionModel.fromJson(Map<String, dynamic> json) {
    final rawMv = json['model_verdict'];
    if (rawMv is! Map) {
      throw FormatException('model_verdict отсутствует или не объект');
    }
    final mvMap = Map<String, dynamic>.from(rawMv);
    final photos = _parsePhotos(json);
    if (kDebugMode) {
      debugPrint(
        '[InspectionModel] id=${json['inspection_id'] ?? json['id']} photos=$photos rawPhotos=${json['photos']}',
      );
    }
    final timestamp = InspectionTime.parseFromServer(json['timestamp']);

    return InspectionModel(
      inspectionId: json['inspection_id'] as String? ?? json['id']?.toString(),
      engineerId: json['engineer_id']?.toString() ?? '',
      timestamp: timestamp,
      modelVerdict: ModelVerdictModel.fromJson(mvMap),
      address: json['address'] as String? ?? '',
      name: json['name'] as String? ?? '',
      photos: photos,
      statusSync: json['status_sync'] as String? ?? 'pending',
    );
  }

  Inspection toDomain({required int index}) {
    final uid = int.tryParse(engineerId) ?? 0;
    final defects = <String>[];
    if (modelVerdict.damageType.isNotEmpty) {
      defects.add(modelVerdict.damageType);
    }
    final c = modelVerdict.accuracy;
    final confidence = c > 1.0 ? (c / 100.0).clamp(0.0, 1.0) : c.clamp(0.0, 1.0);

    return Inspection(
      id: _domainId(inspectionId, index),
      userId: uid,
      timestamp: timestamp,
      photoUrl: photos.isNotEmpty ? photos.first : '',
      photoUrls: photos,
      material: modelVerdict.material,
      confidence: confidence,
      condition: modelVerdict.state.clamp(0, 5),
      defects: defects,
      synchronized: _isSynchronized(statusSync),
      syncStatus: InspectionSyncStatus.fromApi(statusSync),
      address: address,
      damageTypeCode:
          modelVerdict.damageType.isEmpty ? null : modelVerdict.damageType,
      damageDegree: modelVerdict.damageDegree,
    );
  }

  static bool _isSynchronized(String statusSync) {
    final s = statusSync.toLowerCase();
    return s == 'synced' || s == 'outdated';
  }

  static int _domainId(String? inspectionId, int index) {
    if (inspectionId != null && inspectionId.isNotEmpty) {
      final parsed = int.tryParse(inspectionId);
      if (parsed != null) return parsed;
      return inspectionId.hashCode.abs() % 1000000000;
    }
    return index + 1;
  }

  static List<String> _parsePhotos(Map<String, dynamic> json) {
    final raw = json['photos'] ??
        json['photo_urls'] ??
        json['photoUrls'] ??
        json['images'];
    final photos = <String>[];
    if (raw is List) {
      for (final item in raw) {
        final url = _photoUrlFromRaw(item);
        if (url != null && url.isNotEmpty) photos.add(url);
      }
    } else {
      final url = _photoUrlFromRaw(raw);
      if (url != null && url.isNotEmpty) photos.add(url);
    }
    return photos;
  }

  static String? _photoUrlFromRaw(dynamic raw) {
    if (raw == null) return null;
    if (raw is String) return raw.trim();
    if (raw is Map) {
      final map = Map<String, dynamic>.from(raw);
      return (map['url'] ??
              map['secure_url'] ??
              map['photo_url'] ??
              map['photoUrl'])
          ?.toString()
          .trim();
    }
    return raw.toString().trim();
  }
}
