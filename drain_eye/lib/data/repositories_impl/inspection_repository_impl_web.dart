import 'package:drain_eye/domain/entities/inspection.dart';
import 'package:drain_eye/domain/entities/inspection_submit_result.dart';
import 'package:drain_eye/domain/entities/inspection_sync_status.dart';
import 'package:drain_eye/domain/entities/model_inference_result.dart';
import 'package:drain_eye/domain/repositories/inspection_repository.dart';

class InspectionRepositoryImpl implements InspectionRepository {
  InspectionRepositoryImpl();

  @override
  Stream<List<Inspection>> getUserInspections() {
    return Stream.value([]);
  }

  @override
  Future<ModelInferenceResult> runDamageModel(List<String> photoPaths) async {
    throw UnsupportedError('Модель недоступна в веб-версии');
  }

  @override
  Future<InspectionSubmitResult> submitInspection({
    required String engineerId,
    required List<String> photoPaths,
    required ModelInferenceResult modelResult,
  }) async {
    return const InspectionSubmitResult(status: InspectionSyncStatus.synced);
  }

  @override
  Future<void> cacheInspection({
    required String engineerId,
    required List<String> photoPaths,
    required ModelInferenceResult modelResult,
  }) async {}

  @override
  Future<int> pendingInspectionsCount() async => 0;

  @override
  Future<void> syncPendingInspections() async {}
}
