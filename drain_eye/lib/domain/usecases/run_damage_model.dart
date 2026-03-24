import 'package:drain_eye/domain/entities/model_inference_result.dart';
import 'package:drain_eye/domain/repositories/inspection_repository.dart';

// запуск локальной модели по путям к снимкам
class RunDamageModel {
  final InspectionRepository repository;

  RunDamageModel(this.repository);

  Future<ModelInferenceResult> call(List<String> photoPaths) {
    return repository.runDamageModel(photoPaths);
  }
}
