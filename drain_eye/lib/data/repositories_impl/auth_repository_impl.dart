import 'dart:convert';
import 'package:drain_eye/domain/entities/user.dart';
import 'package:drain_eye/domain/repositories/auth_repository.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// реализация репозитория авторизации с заглушкой, пока бэкенд не готов
class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    http.Client? httpClient,
    SharedPreferences? prefs,
  })  : _httpClient = httpClient ?? http.Client(),
        _prefs = prefs;

  final http.Client _httpClient;
  final SharedPreferences? _prefs;

  // базовый URL бэкенда (можно позже заменить на реальный)
  final String baseUrl = 'https://5ou3ck-95-161-61-238.ru.tuna.am';

  @override
  Future<User?> login(String email, String password) async {
    // TODO: заменить на реальный запрос, когда бэкенд будет готов
    // сейчас используем заглушку, которая имитирует успешный вход для инспектора
    await Future.delayed(const Duration(seconds: 1)); // имитация сетевой задержки

    // простая валидация на фронте
    if (email.isEmpty || password.isEmpty) {
      throw Exception('email и пароль обязательны');
    }
    if (!_isValidEmail(email)) {
      throw Exception('неверный формат email');
    }
    if (password.length < 6) {
      throw Exception('пароль должен содержать не менее 6 символов');
    }
    // проверка на наличие строчной буквы
    if (!RegExp(r'[a-z]').hasMatch(password)) {
      throw Exception('пароль должен содержать хотя бы одну строчную букву');
    }
    // проверка на наличие заглавной буквы
    if (!RegExp(r'[A-Z]').hasMatch(password)) {
      throw Exception('пароль должен содержать хотя бы одну заглавную букву');
    }
    // проверка на наличие специального символа (не буква, не цифра)
    if (!RegExp(r'[^a-zA-Z0-9]').hasMatch(password)) {
      throw Exception('пароль должен содержать хотя бы один специальный символ');
    }

    // заглушка: пока бэкенд не готов, любой корректный email/пароль считается неверным
    // симулируем ошибку авторизации
    throw Exception('неверный email или пароль');
  }

  @override
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user');
  }

  @override
  Future<bool> isAuthenticated() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('user');
  }

  @override
  Future<User?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('user');
    if (userJson == null) return null;
    try {
      final map = jsonDecode(userJson) as Map<String, dynamic>;
      return User.fromJson(map);
    } catch (e) {
      return null;
    }
  }

  // вспомогательные методы

  bool _isValidEmail(String email) {
    final regex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    return regex.hasMatch(email);
  }

  Future<void> _saveUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user', jsonEncode(user.toJson()));
  }
}