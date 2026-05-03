import 'package:drain_eye/domain/entities/user.dart';

// абстрактный класс репозитория для авторизации
// определяет контракт для входа и выхода
abstract class AuthRepository {
  // регистрация инспектора с email, паролем и ФИО
  Future<void> register({
    required String email,
    required String password,
    required String fullName,
  });

  // вход с email и паролем, возвращает пользователя (или null при ошибке)
  Future<User?> login(String email, String password);

  // выход (очистка токена)
  Future<void> logout();

  // проверка, авторизован ли пользователь
  Future<bool> isAuthenticated();

  // получение текущего пользователя (из локального хранилища)
  Future<User?> getCurrentUser();
}