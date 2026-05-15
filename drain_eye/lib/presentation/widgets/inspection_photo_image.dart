import 'dart:io' if (dart.library.html) 'package:drain_eye/stubs/dart_io_stub.dart';

import 'package:drain_eye/core/cloudinary_image_url.dart';
import 'package:drain_eye/core/inspection_photo_source.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Превью фото инспекции: локальный файл (кэш) или Cloudinary / HTTP.
class InspectionPhotoImage extends StatelessWidget {
  final String source;
  final double? width;
  final double? height;
  final BoxFit fit;
  final String cloudinaryTransformations;
  final Widget? placeholder;

  const InspectionPhotoImage({
    super.key,
    required this.source,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.cloudinaryTransformations = 'w_120,h_120,c_fill,q_auto,f_auto',
    this.placeholder,
  });

  @override
  Widget build(BuildContext context) {
    final fallback = placeholder ?? _defaultPlaceholder();
    final trimmed = source.trim();
    if (trimmed.isEmpty) return fallback;

    if (!kIsWeb && isLocalDevicePhotoPath(trimmed)) {
      return Image.file(
        File(trimmed),
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (_, __, ___) {
          if (kDebugMode) {
            debugPrint('InspectionPhotoImage local failed: $trimmed');
          }
          return fallback;
        },
      );
    }

    final networkUrl = cloudinaryImageUrl(
      trimmed,
      transformations: cloudinaryTransformations,
    );
    if (networkUrl == null) {
      return fallback;
    }

    return Image.network(
      networkUrl,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (_, error, __) {
        if (kDebugMode) {
          debugPrint(
            'InspectionPhotoImage network failed: $networkUrl error=$error',
          );
        }
        return fallback;
      },
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return fallback;
      },
    );
  }

  Widget _defaultPlaceholder() {
    return Container(
      width: width,
      height: height,
      color: const Color(0xFFF1F5F9),
      alignment: Alignment.center,
      child: const Icon(Icons.camera_alt, color: Color(0xFF94A3B8), size: 24),
    );
  }
}
