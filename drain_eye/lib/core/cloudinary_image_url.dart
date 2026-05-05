const cloudinaryCloudName = 'dbifnmrch';

String? cloudinaryImageUrl(
  String url, {
  String transformations = 'w_120,h_120,c_fill,q_auto,f_auto',
}) {
  final trimmed = url.trim();
  if (trimmed.isEmpty) return null;

  const uploadMarker = '/upload/';
  final uploadIndex = trimmed.indexOf(uploadMarker);
  if (uploadIndex < 0) {
    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return _withCloudinaryTransformations(trimmed, transformations);
    }
    final publicId = trimmed.startsWith('/') ? trimmed.substring(1) : trimmed;
    final deliveryPath = _cloudinaryDeliveryPath(publicId);
    return 'https://res.cloudinary.com/$cloudinaryCloudName/image/upload/$transformations/$deliveryPath';
  }

  return _withCloudinaryTransformations(trimmed, transformations);
}

String _withCloudinaryTransformations(String url, String transformations) {
  const uploadMarker = '/upload/';
  final uploadIndex = url.indexOf(uploadMarker);
  if (uploadIndex < 0) return url;
  final insertIndex = uploadIndex + uploadMarker.length;
  return '${url.substring(0, insertIndex)}$transformations/${url.substring(insertIndex)}';
}

String _cloudinaryDeliveryPath(String publicId) {
  final lower = publicId.toLowerCase();
  const extensions = ['.jpg', '.jpeg', '.png', '.webp'];
  for (final extension in extensions) {
    if (lower.endsWith(extension)) {
      return '$publicId$extension';
    }
  }
  return publicId;
}
