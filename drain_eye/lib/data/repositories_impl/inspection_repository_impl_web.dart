import 'package:drain_eye/domain/entities/inspection.dart';
import 'package:drain_eye/domain/entities/model_inference_result.dart';
import 'package:drain_eye/domain/repositories/inspection_repository.dart';

// Заглушка репозитория для веб-платформы (dart:io недоступен на web).
class InspectionRepositoryImpl implements InspectionRepository {
  InspectionRepositoryImpl();

  @override
  Stream<List<Inspection>> getUserInspections(int userId) {
    return Stream.value([]);
  }

  @override
  Future<ModelInferenceResult> runDamageModel(List<String> photoPaths) async {
    throw UnsupportedError('Модель недоступна в веб-версии');
  }

  @override
  Future<void> createInspection({
    required int userId,
    required List<String> photoPaths,
    required ModelInferenceResult modelResult,
  }) async {}
}
