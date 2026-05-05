import 'package:shared_preferences/shared_preferences.dart';

// Чтение JWT-токена из SharedPreferences.
// Ключ совпадает с тем, что использует AuthRepositoryImpl при сохранении.
class TokenStorage {
  static const _keyToken = 'auth_token';

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyToken);
  }
}
