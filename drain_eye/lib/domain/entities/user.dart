// сущность пользователя (инспектора)
class User {
  final int id;
  final String email;
  final String name;
  final String? avatarUrl;
  final String role; // 'inspector' или 'admin'

  const User({
    required this.id,
    required this.email,
    required this.name,
    this.avatarUrl,
    required this.role,
  });

  // создание пользователя из JSON (например, ответа сервера)
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int,
      email: json['email'] as String,
      name: json['name'] as String,
      avatarUrl: json['avatarUrl'] as String?,
      role: json['role'] as String,
    );
  }

  // преобразование в JSON (для отправки или хранения)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'avatarUrl': avatarUrl,
      'role': role,
    };
  }

  // удобный метод для проверки, является ли пользователь инспектором
  bool get isInspector => role == 'inspector';

  // удобный метод для проверки, является ли пользователь админом
  bool get isAdmin => role == 'admin';
}