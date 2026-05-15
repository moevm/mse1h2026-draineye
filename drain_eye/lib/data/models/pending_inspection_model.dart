import 'package:drain_eye/domain/entities/model_inference_result.dart';

/// Инспекция, сохранённая в локальный кэш до появления сети.
class PendingInspectionModel {
  PendingInspectionModel({
    required this.localId,
    required this.engineerId,
    required this.photoPaths,
    required this.modelResult,
    required this.createdAt,
    this.address = '',
    this.name = 'Инспекция',
  });

  final String localId;
  final String engineerId;
  final List<String> photoPaths;
  final ModelInferenceResult modelResult;
  final DateTime createdAt;
  final String address;
  final String name;

  Map<String, dynamic> toJson() => {
        'local_id': localId,
        'engineer_id': engineerId,
        'photo_paths': photoPaths,
        'model_result': _modelResultToJson(modelResult),
        'created_at': createdAt.toIso8601String(),
        'address': address,
        'name': name,
      };

  factory PendingInspectionModel.fromJson(Map<String, dynamic> json) {
    return PendingInspectionModel(
      localId: json['local_id'] as String,
      engineerId: json['engineer_id'] as String,
      photoPaths: (json['photo_paths'] as List<dynamic>)
          .map((e) => e.toString())
          .toList(),
      modelResult: _modelResultFromJson(
        Map<String, dynamic>.from(json['model_result'] as Map),
      ),
      createdAt: DateTime.parse(json['created_at'] as String),
      address: json['address'] as String? ?? '',
      name: json['name'] as String? ?? 'Инспекция',
    );
  }

  static Map<String, dynamic> _modelResultToJson(ModelInferenceResult r) {
    return {
      'material': r.material,
      'state': r.state,
      'damage_type': r.damageType,
      'damage_degree': r.damageDegree,
      'accuracy_model': r.accuracyModel,
      'comments': r.comments,
    };
  }

  static ModelInferenceResult _modelResultFromJson(Map<String, dynamic> json) {
    return ModelInferenceResult(
      material: json['material'] as String?,
      state: (json['state'] as num?)?.toInt(),
      damageType: json['damage_type'] as String? ?? 'unknown',
      damageDegree: (json['damage_degree'] as num?)?.toDouble(),
      accuracyModel: (json['accuracy_model'] as num?)?.toDouble() ?? 0,
      comments: json['comments'] as String?,
    );
  }
}
