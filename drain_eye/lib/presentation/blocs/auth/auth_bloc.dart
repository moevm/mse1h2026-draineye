import 'package:bloc/bloc.dart';
import 'package:drain_eye/domain/entities/user.dart';
import 'package:drain_eye/domain/repositories/auth_repository.dart';
import 'package:drain_eye/domain/usecases/check_auth.dart';
import 'package:drain_eye/domain/usecases/login_user.dart';
import 'package:drain_eye/domain/usecases/register_user.dart';
import 'package:flutter/foundation.dart';

part 'auth_event.dart';
part 'auth_state.dart';

// BLoC для управления авторизацией
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUser _loginUser;
  final RegisterUser _registerUser;
  final CheckAuth _checkAuth;
  final AuthRepository _authRepository;

  AuthBloc({
    required LoginUser loginUser,
    required RegisterUser registerUser,
    required CheckAuth checkAuth,
    required AuthRepository authRepository,
  })  : _loginUser = loginUser,
        _registerUser = registerUser,
        _checkAuth = checkAuth,
        _authRepository = authRepository,
        super(AuthInitial()) {
    on<LoginEvent>(_onLogin);
    on<GoogleLoginEvent>(_onGoogleLogin);
    on<RegisterEvent>(_onRegister);
    on<LogoutEvent>(_onLogout);
    on<CheckAuthEvent>(_onCheckAuth);
  }

  Future<void> _onLogin(
    LoginEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final user = await _loginUser(event.email, event.password);
      if (user != null) {
        emit(AuthAuthenticated(user));
      } else {
        emit(AuthError('неверный email или пароль'));
      }
    } catch (e, st) {
      if (kDebugMode) {
        print('Login error: $e\n$st');
      }
      emit(AuthError(_authErrorMessage(e)));
    }
  }

  Future<void> _onGoogleLogin(
    GoogleLoginEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final user = await _authRepository.loginWithGoogle();
      if (user != null) {
        emit(AuthAuthenticated(user));
      } else {
        emit(AuthError('не удалось выполнить вход через Google'));
      }
    } catch (e, st) {
      if (kDebugMode) {
        print('Google login error: $e\n$st');
      }
      emit(AuthError(_authErrorMessage(e)));
    }
  }

  Future<void> _onRegister(
    RegisterEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await _registerUser(
        email: event.email,
        password: event.password,
        fullName: event.fullName,
      );
      emit(AuthRegistrationSuccess(event.email));
    } catch (e, st) {
      if (kDebugMode) {
        print('Registration error: $e\n$st');
      }
      emit(AuthError(_authErrorMessage(e)));
    }
  }

  Future<void> _onLogout(
    LogoutEvent event,
    Emitter<AuthState> emit,
  ) async {
    await _authRepository.logout();
    emit(AuthUnauthenticated());
  }

  Future<void> _onCheckAuth(
    CheckAuthEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final user = await _checkAuth();
      if (user != null) {
        emit(AuthAuthenticated(user));
      } else {
        emit(AuthUnauthenticated());
      }
    } catch (e, st) {
      if (kDebugMode) {
        print('CheckAuth error: $e\n$st');
      }
      emit(AuthUnauthenticated());
    }
  }

  String _authErrorMessage(Object error) {
    final message = error.toString();
    if (message.contains('Firebase не настроен')) {
      return 'Firebase не инициализирован. Выполните полный перезапуск приложения после flutterfire configure.';
    }
    return message
        .replaceFirst('Exception: ', '')
        .replaceFirst('StateError: ', '');
  }
}