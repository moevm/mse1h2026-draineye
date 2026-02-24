import 'package:drain_eye/domain/entities/inspection.dart';

// абстрактный класс репозитория для работы с инспекциями
// определяет контракт, который должны реализовать конкретные источники данных
abstract class InspectionRepository {
  Stream<List<Inspection>> getUserInspections(int userId);
}