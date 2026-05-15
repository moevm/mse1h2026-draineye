import 'package:intl/intl.dart';

/// Время инспекций: бэкенд хранит UTC, в UI — локальный пояс устройства (МСК и т.д.).
class InspectionTime {
  InspectionTime._();

  static final _displayFormat = DateFormat('dd.MM.yyyy, HH:mm');

  /// ISO 8601 в UTC для отправки на сервер.
  static String nowUtcIso8601() => DateTime.now().toUtc().toIso8601String();

  static String utcIso8601(DateTime value) => value.toUtc().toIso8601String();

  /// Разбор `timestamp` из API (если без пояса — считаем UTC).
  static DateTime parseFromServer(dynamic value) {
    if (value is DateTime) {
      return value.isUtc ? value.toLocal() : value;
    }
    if (value is String) {
      final trimmed = value.trim();
      if (trimmed.isEmpty) {
        return DateTime.now();
      }
      final hasTimezone = trimmed.endsWith('Z') ||
          _timezoneOffsetPattern.hasMatch(trimmed);
      final parsed = DateTime.parse(
        hasTimezone ? trimmed : '${trimmed}Z',
      );
      return parsed.toLocal();
    }
    return DateTime.now();
  }

  static final _timezoneOffsetPattern = RegExp(
    r'[+-]\d{2}:\d{2}$|[+-]\d{4}$',
  );

  /// Отображение в локальном времени телефона.
  static String formatForDisplay(DateTime value) {
    final local = value.isUtc ? value.toLocal() : value;
    return _displayFormat.format(local);
  }
}
