import 'package:drain_eye/domain/entities/admin_user.dart';

// Сущность инспекции для админ-панели (InspectionResponse с бэкенда).
class AdminInspection {
  final String id;
  final String engineerId;
  final DateTime timestamp;
  final String address;
  final String name;
  final String statusSync;
  final EngineerBrief? engineer;

  const AdminInspection({
    required this.id,
    required this.engineerId,
    required this.timestamp,
    required this.address,
    required this.name,
    required this.statusSync,
    this.engineer,
  });

  factory AdminInspection.fromJson(Map<String, dynamic> json) {
    return AdminInspection(
      id: json['id'] as String,
      engineerId: json['engineer_id'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      address: json['address'] as String? ?? '',
      name: json['name'] as String? ?? '',
      statusSync: json['status_sync'] as String? ?? 'pending',
      engineer: json['engineer'] != null
          ? EngineerBrief.fromJson(json['engineer'] as Map<String, dynamic>)
          : null,
    );
  }
}

class DashboardMetrics {
  final int totalInspectors;
  final int totalInspections;
  final int todayCount;
  final int pendingCount;

  const DashboardMetrics({
    required this.totalInspectors,
    required this.totalInspections,
    required this.todayCount,
    required this.pendingCount,
  });

  factory DashboardMetrics.fromJson(Map<String, dynamic> json) {
    return DashboardMetrics(
      totalInspectors: (json['active_inspectors'] as num?)?.toInt() ?? 0,
      totalInspections: (json['total_inspections'] as num?)?.toInt() ?? 0,
      todayCount: (json['inspections_today'] as num?)?.toInt() ?? 0,
      pendingCount: 0,
    );
  }
}

// Ответ с пагинацией.
class PaginatedResponse<T> {
  final List<T> items;
  final String? nextCursor;
  final bool hasMore;
  final int totalReturned;

  const PaginatedResponse({
    required this.items,
    required this.nextCursor,
    required this.hasMore,
    required this.totalReturned,
  });
}
