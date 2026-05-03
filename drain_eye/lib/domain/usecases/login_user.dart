import 'package:drain_eye/domain/entities/user.dart';
import 'package:drain_eye/domain/repositories/auth_repository.dart';

// usecase для входа пользователя
class LoginUser {
  final AuthRepository repository;

  LoginUser(this.repository);

  Future<User?> call(String email, String password) {
    return repository.login(email, password);
  }
}