import 'dart:convert';

import 'package:drain_eye/core/api_config.dart';
import 'package:drain_eye/domain/entities/user.dart';
import 'package:drain_eye/domain/repositories/auth_repository.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// реализация репозитория авторизации через FirebaseAuth и FastAPI backend
class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    http.Client? httpClient,
    SharedPreferences? prefs,
    firebase_auth.FirebaseAuth? firebaseAuth,
  })  : _httpClient = httpClient ?? http.Client(),
        _prefs = prefs,
        _firebaseAuth = firebaseAuth;

  final http.Client _httpClient;
  final SharedPreferences? _prefs;
  final firebase_auth.FirebaseAuth? _firebaseAuth;
  Future<void>? _googleSignInInitialized;

  static const _userPrefsKey = 'user';
  static const _authTokenPrefsKey = 'auth_token';

  @override
  Future<void> register({
    required String email,
    required String password,
    required String fullName,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();
    _validateCredentials(normalizedEmail, password);
    final normalizedFullName = fullName.trim();
    if (normalizedFullName.isEmpty) {
      throw Exception('введите имя');
    }

    final uri = Uri.parse(ApiConfig.register);
    if (kDebugMode) {
      print('Register backend request: $uri email=$normalizedEmail');
    }
    final response = await _httpClient.post(
      uri,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'tuna-skip-browser-warning': 'true',
      },
      body: jsonEncode({
        'email': normalizedEmail,
        'password': password,
        'full_name': normalizedFullName,
      }),
    );
    if (kDebugMode) {
      print(
        'Register backend response: ${response.statusCode} ${response.body}',
      );
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(_extractErrorMessage(response));
    }

    final auth = _requireFirebaseAuth();
    try {
      if (kDebugMode) {
        print('Firebase register: signing in $normalizedEmail');
      }
      final credential = await auth.signInWithEmailAndPassword(
        email: normalizedEmail,
        password: password,
      );
      if (kDebugMode) {
        print('Firebase register: signed in $normalizedEmail');
      }

      final firebaseUser = credential.user;
      if (firebaseUser == null) {
        throw Exception('не удалось получить пользователя Firebase');
      }

      if (kDebugMode) {
        print('Firebase register: updating display name');
      }
      await firebaseUser.updateDisplayName(normalizedFullName);
      if (kDebugMode) {
        print('Firebase register: sending verification email');
      }
      await firebaseUser.sendEmailVerification();
      if (kDebugMode) {
        print('Firebase register: verification email sent');
      }
    } on firebase_auth.FirebaseAuthException catch (e) {
      if (kDebugMode) {
        print('Firebase register error: ${e.code} ${e.message}');
      }
      throw Exception(_firebaseAuthMessage(e));
    } finally {
      await auth.signOut();
    }
  }

  @override
  Future<User?> login(String email, String password) async {
    final normalizedEmail = email.trim().toLowerCase();
    _validateCredentials(normalizedEmail, password);

    final auth = _requireFirebaseAuth();
    late final firebase_auth.UserCredential credential;
    try {
      credential = await auth.signInWithEmailAndPassword(
        email: normalizedEmail,
        password: password,
      );
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw Exception(_firebaseAuthMessage(e));
    }
    final firebaseUser = credential.user;
    if (firebaseUser == null) {
      throw Exception('не удалось получить пользователя Firebase');
    }
    if (!firebaseUser.emailVerified) {
      await firebaseUser.sendEmailVerification();
      await auth.signOut();
      throw Exception('подтвердите email по ссылке из письма');
    }

    final token = await firebaseUser.getIdToken();
    if (token == null || token.isEmpty) {
      throw Exception('не удалось получить токен Firebase');
    }
    return _loginBackendWithFirebaseToken(token, signOutOnBackendError: true);
  }

  @override
  Future<User?> loginWithGoogle() async {
    final auth = _requireFirebaseAuth();
    try {
      _googleSignInInitialized ??= GoogleSignIn.instance.initialize();
      await _googleSignInInitialized;

      if (!GoogleSignIn.instance.supportsAuthenticate()) {
        throw Exception('Google вход не поддерживается на этой платформе');
      }

      final googleAccount = await GoogleSignIn.instance.authenticate();
      final googleAuth = googleAccount.authentication;
      final idToken = googleAuth.idToken;
      if (idToken == null || idToken.isEmpty) {
        throw Exception('не удалось получить Google ID token');
      }

      final credential = firebase_auth.GoogleAuthProvider.credential(
        idToken: idToken,
      );
      final userCredential = await auth.signInWithCredential(credential);
      final firebaseUser = userCredential.user;
      if (firebaseUser == null) {
        throw Exception('не удалось получить пользователя Firebase');
      }

      final token = await firebaseUser.getIdToken();
      if (token == null || token.isEmpty) {
        throw Exception('не удалось получить токен Firebase');
      }
      return _loginBackendWithFirebaseToken(token, signOutOnBackendError: true);
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) {
        throw Exception('вход через Google отменен');
      }
      throw Exception(e.description ?? 'ошибка входа через Google');
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw Exception(_firebaseAuthMessage(e));
    }
  }

  @override
  Future<void> logout() async {
    final prefs = await _prefsInstance();
    await prefs.remove(_userPrefsKey);
    await prefs.remove(_authTokenPrefsKey);
    if (Firebase.apps.isNotEmpty) {
      await _requireFirebaseAuth().signOut();
    }
    try {
      _googleSignInInitialized ??= GoogleSignIn.instance.initialize();
      await _googleSignInInitialized;
      await GoogleSignIn.instance.signOut();
    } catch (_) {
      // Google Sign-In мог не использоваться в текущей сессии.
    }
  }

  @override
  Future<bool> isAuthenticated() async {
    final prefs = await _prefsInstance();
    return prefs.containsKey(_userPrefsKey) &&
        prefs.containsKey(_authTokenPrefsKey);
  }

  @override
  Future<User?> getCurrentUser() async {
    final prefs = await _prefsInstance();
    final userJson = prefs.getString(_userPrefsKey);
    if (userJson == null) return null;
    try {
      final map = jsonDecode(userJson) as Map<String, dynamic>;
      return User.fromJson(map);
    } catch (e) {
      return null;
    }
  }

  // вспомогательные методы

  firebase_auth.FirebaseAuth _requireFirebaseAuth() {
    final auth = _firebaseAuth;
    if (auth != null) return auth;
    if (Firebase.apps.isNotEmpty) return firebase_auth.FirebaseAuth.instance;
    throw StateError(
      'Firebase не настроен. Добавьте firebase_options.dart или native Firebase config.',
    );
  }

  Future<SharedPreferences> _prefsInstance() async {
    final prefs = _prefs;
    if (prefs != null) return prefs;
    return SharedPreferences.getInstance();
  }

  void _validateCredentials(String email, String password) {
    if (email.isEmpty || password.isEmpty) {
      throw Exception('email и пароль обязательны');
    }
    if (!_isValidEmail(email)) {
      throw Exception('неверный формат email');
    }
    if (password.length < 8) {
      throw Exception('пароль должен содержать не менее 8 символов');
    }
    if (!RegExp(r'[a-z]').hasMatch(password)) {
      throw Exception('пароль должен содержать хотя бы одну строчную букву');
    }
    if (!RegExp(r'[A-Z]').hasMatch(password)) {
      throw Exception('пароль должен содержать хотя бы одну заглавную букву');
    }
  }

  bool _isValidEmail(String email) {
    final regex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    return regex.hasMatch(email);
  }

  String _extractErrorMessage(http.Response response) {
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) {
        final detail = decoded['detail'];
        if (detail is String && detail.isNotEmpty) return detail;
      }
    } catch (_) {
      // Если ответ не JSON, ниже вернем тело ответа или общий текст ошибки.
    }
    if (response.body.isNotEmpty) return response.body;
    return 'ошибка сервера: ${response.statusCode}';
  }

  String _firebaseAuthMessage(firebase_auth.FirebaseAuthException error) {
    switch (error.code) {
      case 'email-already-in-use':
        return 'этот email уже зарегистрирован в Firebase';
      case 'operation-not-allowed':
        return 'в Firebase Console не включен вход Email/Password';
      case 'invalid-email':
        return 'неверный формат email';
      case 'weak-password':
        return 'пароль слишком простой для Firebase';
      case 'network-request-failed':
        return 'не удалось подключиться к Firebase, проверьте интернет';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'неверный email или пароль';
      case 'too-many-requests':
        return 'слишком много попыток, попробуйте позже';
      default:
        return error.message ?? 'ошибка Firebase: ${error.code}';
    }
  }

  Future<User?> _loginBackendWithFirebaseToken(
    String token, {
    required bool signOutOnBackendError,
  }) async {
    final response = await _httpClient.post(
      Uri.parse(ApiConfig.login),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
        'tuna-skip-browser-warning': 'true',
      },
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      if (signOutOnBackendError) {
        await _requireFirebaseAuth().signOut();
      }
      throw Exception(_extractErrorMessage(response));
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    final user = User.fromJson(decoded);
    await _saveAuthData(user: user, token: token);
    return user;
  }

  Future<void> _saveAuthData({
    required User user,
    required String token,
  }) async {
    final prefs = await _prefsInstance();
    await prefs.setString(_userPrefsKey, jsonEncode(user.toJson()));
    await prefs.setString(_authTokenPrefsKey, token);
  }
}
