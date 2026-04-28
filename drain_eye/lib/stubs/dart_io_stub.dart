// Заглушка dart:io для веб-платформы.
// Предоставляет минимальный API чтобы код компилировался на web.

class File {
  final String path;
  const File(this.path);
  Future<File> copy(String newPath) async => File(newPath);
}

class Directory {
  final String path;
  const Directory(this.path);
  static Directory get systemTemp => const Directory('/tmp');
}

class Platform {
  static String get pathSeparator => '/';
}
