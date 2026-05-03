// состояния авторизации
part of 'auth_bloc.dart';

@immutable
abstract class AuthState {}

// начальное состояние (ничего не происходит)
class AuthInitial extends AuthState {}

// загрузка (выполняется вход или проверка)
class AuthLoading extends AuthState {}

// успешная авторизация
class AuthAuthenticated extends AuthState {
  final User user;

  AuthAuthenticated(this.user);
}

// неавторизован (пользователь вышел или не входил)
class AuthUnauthenticated extends AuthState {}

// ошибка авторизации
class AuthError extends AuthState {
  final String message;

  AuthError(this.message);
}