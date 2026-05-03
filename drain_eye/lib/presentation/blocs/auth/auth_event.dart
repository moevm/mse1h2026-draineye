// события авторизации
part of 'auth_bloc.dart';

@immutable
abstract class AuthEvent {}

// событие входа с email и паролем
class LoginEvent extends AuthEvent {
  final String email;
  final String password;

  LoginEvent({required this.email, required this.password});
}

// событие выхода
class LogoutEvent extends AuthEvent {}

// событие проверки авторизации (при запуске приложения)
class CheckAuthEvent extends AuthEvent {}