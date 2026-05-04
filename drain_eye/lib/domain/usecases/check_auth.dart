import 'package:drain_eye/domain/entities/user.dart';
import 'package:drain_eye/domain/repositories/auth_repository.dart';

// usecase для проверки, авторизован ли пользователь
class CheckAuth {
  final AuthRepository repository;

  CheckAuth(this.repository);

  Future<User?> call() async {
    final isAuthenticated = await repository.isAuthenticated();
    if (!isAuthenticated) return null;
    return repository.getCurrentUser();
  }
}