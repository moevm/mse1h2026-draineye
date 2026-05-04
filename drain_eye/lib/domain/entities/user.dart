// сущность пользователя (инспектора)
class User {
  final String id;
  final String email;
  final String name;
  final String? avatarUrl;
  final String role; // 'inspector' или 'admin'
  final int? countInspections;
  final DateTime? lastActivity;
  final DateTime? createdAt;

  const User({
    required this.id,
    required this.email,
    required this.name,
    this.avatarUrl,
    required this.role,
    this.countInspections,
    this.lastActivity,
    this.createdAt,
  });

  // создание пользователя из JSON (например, ответа сервера)
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: (json['user_id'] ?? json['id']).toString(),
      email: json['email'] as String,
      name: (json['full_name'] ?? json['name']) as String,
      avatarUrl: json['avatarUrl'] as String?,
      role: json['role'] as String,
      countInspections: _parseInt(json['count'] ?? json['count_inspections']),
      lastActivity: _parseDate(json['last_activity']),
      createdAt: _parseDate(json['created_at']),
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
      'count': countInspections,
      'last_activity': lastActivity?.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
    };
  }

  // удобный метод для проверки, является ли пользователь инспектором
  bool get isInspector => role == 'inspector';

  // удобный метод для проверки, является ли пользователь админом
  bool get isAdmin => role == 'admin';

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString());
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    return DateTime.tryParse(value.toString());
  }
}
