import 'package:drain_eye/domain/entities/model_inference_result.dart';
import 'package:drain_eye/domain/repositories/inspection_repository.dart';

class CacheInspectionOffline {
  final InspectionRepository repository;

  CacheInspectionOffline(this.repository);

  Future<void> call({
    required String engineerId,
    required String address,
    required List<String> photoPaths,
    required ModelInferenceResult modelResult,
  }) {
    return repository.cacheInspection(
      engineerId: engineerId,
      address: address,
      photoPaths: photoPaths,
      modelResult: modelResult,
    );
  }
}
