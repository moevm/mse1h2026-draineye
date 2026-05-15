import 'package:drain_eye/domain/repositories/inspection_repository.dart';

class SyncPendingInspections {
  final InspectionRepository repository;

  SyncPendingInspections(this.repository);

  Future<void> call() => repository.syncPendingInspections();
}
