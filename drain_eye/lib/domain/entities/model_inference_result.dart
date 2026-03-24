// результат локального инференса (поля модели; часть пока null до дообучения)
class ModelInferenceResult {
  final String? material;
  final int? state;
  final String damageType;
  final double? damageDegree;
  final double accuracyModel;
  final String? comments;

  const ModelInferenceResult({
    this.material,
    this.state,
    required this.damageType,
    this.damageDegree,
    required this.accuracyModel,
    this.comments,
  });
}
