/// Различает локальный файл на устройстве и ссылку Cloudinary / HTTP.
bool isLocalDevicePhotoPath(String path) {
  final trimmed = path.trim();
  if (trimmed.isEmpty) return false;
  if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
    return false;
  }

  // Файлы офлайн-кэша (см. OfflineInspectionCache).
  if (trimmed.contains('drain_eye_pending')) return true;

  // Типичные абсолютные пути на Android / iOS / desktop.
  if (trimmed.startsWith('/data/') ||
      trimmed.startsWith('/storage/') ||
      trimmed.startsWith('/var/mobile/') ||
      trimmed.startsWith('/private/') ||
      trimmed.startsWith('/tmp/')) {
    return true;
  }

  if (RegExp(r'^[A-Za-z]:\\').hasMatch(trimmed)) return true;

  // Иначе — public_id или относительный путь Cloudinary, не локальный файл.
  return false;
}
