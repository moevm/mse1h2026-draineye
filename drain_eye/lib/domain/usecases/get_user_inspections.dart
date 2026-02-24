import 'package:drain_eye/domain/repositories/inspection_repository.dart';
import 'package:drain_eye/domain/entities/inspection.dart';

// класс, реаоизующий получение инспекций пользователя
class GetUserInspections {
  // репозиторий - абстракция источника данных
  final InspectionRepository repository;

  GetUserInspections(this.repository);

  // получает данные об инспекциях от репозитория
  Stream<List<Inspection>> call(int userId) {
    return repository.getUserInspections(userId);
  }
}