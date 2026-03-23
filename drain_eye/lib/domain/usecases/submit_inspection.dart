import 'package:drain_eye/domain/entities/model_inference_result.dart';
import 'package:drain_eye/domain/repositories/inspection_repository.dart';

// отправка новой инспекции на сервер
class SubmitInspection {
  final InspectionRepository repository;

  SubmitInspection(this.repository);

  Future<void> call({
    required int userId,
    required List<String> photoPaths,
    required ModelInferenceResult modelResult,
  }) {
    return repository.createInspection(
      userId: userId,
      photoPaths: photoPaths,
      modelResult: modelResult,
    );
  }
}
