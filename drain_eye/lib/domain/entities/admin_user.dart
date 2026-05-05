// Сущность пользователя для админ-панели (UserResponse с бэкенда).
class AdminUser {
  final String userId;
  final String email;
  final String fullName;
  final String role;
  final bool isActive;
  final int countInspections;
  final DateTime? lastActivity;
  final DateTime? createdAt;

  const AdminUser({
    required this.userId,
    required this.email,
    required this.fullName,
    required this.role,
    required this.isActive,
    required this.countInspections,
    this.lastActivity,
    this.createdAt,
  });

  factory AdminUser.fromJson(Map<String, dynamic> json) {
    return AdminUser(
      userId: json['user_id'] as String,
      email: json['email'] as String,
      fullName: json['full_name'] as String,
      role: json['role'] as String,
      isActive: json['is_active'] as bool,
      countInspections: (json['count_inspections'] as num?)?.toInt() ?? 0,
      lastActivity: json['last_activity'] != null
          ? DateTime.tryParse(json['last_activity'] as String)
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
    );
  }
}

// Краткие данные инженера, прикреплённые к инспекции.
class EngineerBrief {
  final String userId;
  final String fullName;
  final String email;

  const EngineerBrief({
    required this.userId,
    required this.fullName,
    required this.email,
  });

  factory EngineerBrief.fromJson(Map<String, dynamic> json) {
    return EngineerBrief(
      userId: json['user_id'] as String,
      fullName: json['full_name'] as String,
      email: json['email'] as String,
    );
  }
}
