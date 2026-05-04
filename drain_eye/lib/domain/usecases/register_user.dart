import 'package:drain_eye/domain/repositories/auth_repository.dart';

// usecase для регистрации инспектора
class RegisterUser {
  final AuthRepository repository;

  RegisterUser(this.repository);

  Future<void> call({
    required String email,
    required String password,
    required String fullName,
  }) {
    return repository.register(
      email: email,
      password: password,
      fullName: fullName,
    );
  }
}
