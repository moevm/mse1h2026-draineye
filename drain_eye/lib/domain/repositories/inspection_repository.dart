import 'package:drain_eye/domain/entities/inspection.dart';
import 'package:drain_eye/domain/entities/inspection_submit_result.dart';
import 'package:drain_eye/domain/entities/model_inference_result.dart';

abstract class InspectionRepository {
  Stream<List<Inspection>> getUserInspections();

  Future<ModelInferenceResult> runDamageModel(List<String> photoPaths);

  Future<InspectionSubmitResult> submitInspection({
    required String engineerId,
    required String address,
    required List<String> photoPaths,
    required ModelInferenceResult modelResult,
  });

  Future<void> cacheInspection({
    required String engineerId,
    required String address,
    required List<String> photoPaths,
    required ModelInferenceResult modelResult,
  });

  Future<int> pendingInspectionsCount();

  Future<void> syncPendingInspections();
}
