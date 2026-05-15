import 'package:drain_eye/domain/entities/inspection_sync_status.dart';

class InspectionSubmitResult {
  final String? inspectionId;
  final InspectionSyncStatus status;
  final bool savedLocally;

  const InspectionSubmitResult({
    this.inspectionId,
    required this.status,
    this.savedLocally = false,
  });
}
