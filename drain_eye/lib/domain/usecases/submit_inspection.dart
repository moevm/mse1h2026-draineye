import 'package:drain_eye/domain/entities/inspection_submit_result.dart';
import 'package:drain_eye/domain/entities/model_inference_result.dart';
import 'package:drain_eye/domain/repositories/inspection_repository.dart';

class SubmitInspection {
  final InspectionRepository repository;

  SubmitInspection(this.repository);

  Future<InspectionSubmitResult> call({
    required String engineerId,
    required String address,
    required List<String> photoPaths,
    required ModelInferenceResult modelResult,
  }) {
    return repository.submitInspection(
      engineerId: engineerId,
      address: address,
      photoPaths: photoPaths,
      modelResult: modelResult,
    );
  }
}
