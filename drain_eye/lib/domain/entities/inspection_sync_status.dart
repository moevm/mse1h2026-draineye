/// Статус синхронизации инспекции (ответ API или локальный кэш).
enum InspectionSyncStatus {
  pending,
  outdated,
  synced,
  cached;

  static InspectionSyncStatus fromApi(String? raw) {
    switch (raw?.toLowerCase()) {
      case 'synced':
        return InspectionSyncStatus.synced;
      case 'outdated':
        return InspectionSyncStatus.outdated;
      case 'pending':
        return InspectionSyncStatus.pending;
      default:
        return InspectionSyncStatus.pending;
    }
  }

  bool get isSynchronized =>
      this == InspectionSyncStatus.synced || this == InspectionSyncStatus.outdated;

  String get labelRu {
    switch (this) {
      case InspectionSyncStatus.synced:
        return 'Синхронизировано';
      case InspectionSyncStatus.outdated:
        return 'Устарело';
      case InspectionSyncStatus.pending:
        return 'Ожидает отправки';
      case InspectionSyncStatus.cached:
        return 'В кэше';
    }
  }
}
