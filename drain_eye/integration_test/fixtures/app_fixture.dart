import 'package:drain_eye/data/repositories_impl/inspection_repository_impl.dart';
import 'package:drain_eye/domain/repositories/inspection_repository.dart';
import 'package:drain_eye/domain/usecases/get_user_inspections.dart';
import 'package:drain_eye/presentation/blocs/user_inspection/user_inspection_bloc.dart';

/// Вспомогательные функции и mock-данные для тестирования
class TestFixtures {
  // mock данные
  static const Map<String, dynamic> validUser = {
    'email': 'test@example.com',
    'password': 'Test123!@#',
    'name': 'Test User',
  };

  static const Map<String, dynamic> invalidUser = {
    'email': 'invalid@',
    'password': '123',
  };

  // mock инспекции
  static const List<Map<String, dynamic>> mockInspections = [];

  static UserInspectionBloc createTestBloc() {
    final InspectionRepository repository = InspectionRepositoryImpl();
    final GetUserInspections getUserInspections = GetUserInspections(
      repository,
    );
    return UserInspectionBloc(getUserInspections: getUserInspections);
  }

  // конфигурация
  static Map<String, dynamic> getTestConfig() {
    return {
      'testMode': true,
      'apiTimeout': const Duration(seconds: 5),
      'debugMode': false,
    };
  }
}
