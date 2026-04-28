import 'package:drain_eye/domain/entities/model_inference_result.dart';

// Заглушка для веб-платформы — tflite_flutter не поддерживает web.
class LocalDamageModelDataSource {
  Future<ModelInferenceResult> runAverageProbabilities(List<String> photoPaths) async {
    throw UnsupportedError('TFLite недоступен в веб-версии');
  }

  void dispose() {}
}
