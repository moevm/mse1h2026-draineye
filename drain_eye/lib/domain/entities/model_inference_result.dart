// результат локального инференса (поля модели; часть пока null до дообучения)
class ModelInferenceResult {
  final String? material;
  final int? state;
  final String damageType;
  final double? damageDegree;
  final double accuracyModel;
  final String? comments;
  final List<ModelDetection> detections;

  const ModelInferenceResult({
    this.material,
    this.state,
    required this.damageType,
    this.damageDegree,
    required this.accuracyModel,
    this.comments,
    this.detections = const [],
  });
}

class ModelDetection {
  static const int inputSize = 640;

  final double x1;
  final double y1;
  final double x2;
  final double y2;
  final double confidence;
  final int classId;

  const ModelDetection({
    required this.x1,
    required this.y1,
    required this.x2,
    required this.y2,
    required this.confidence,
    required this.classId,
  });

  String get damageType {
    switch (classId) {
      case 0:
        return 'corrosion';
      case 1:
        return 'crack';
      default:
        return 'unknown';
    }
  }

  double get width => (x2 - x1).clamp(0.0, 1.0);
  double get height => (y2 - y1).clamp(0.0, 1.0);
  double get areaFraction => width * height;

  double get x1Px => x1 * inputSize;
  double get y1Px => y1 * inputSize;
  double get x2Px => x2 * inputSize;
  double get y2Px => y2 * inputSize;
}
