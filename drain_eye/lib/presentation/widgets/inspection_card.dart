import 'package:drain_eye/domain/entities/inspection_sync_status.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:drain_eye/core/cloudinary_image_url.dart';
import '../../domain/entities/inspection.dart';

const _teal = Color(0xFF0D9488);
const _gray400 = Color(0xFF94A3B8);
const _gray500 = Color(0xFF64748B);

class InspectionCard extends StatelessWidget {
  final Inspection inspection;
  final VoidCallback onTap;

  const InspectionCard({
    super.key,
    required this.inspection,
    required this.onTap,
  });

  InspectionSyncStatus get _syncStatus =>
      inspection.syncStatus ??
      (inspection.synchronized
          ? InspectionSyncStatus.synced
          : InspectionSyncStatus.pending);

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd.MM.yyyy, HH:mm');
    final dateTimeStr = dateFormat.format(inspection.timestamp);
    final confidencePercent = (inspection.confidence * 100).round();
    final thumbnailUrl = cloudinaryImageUrl(inspection.photoUrl);
    final status = _syncStatus;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: SizedBox(
                      width: 56,
                      height: 56,
                      child: thumbnailUrl == null
                          ? _photoPlaceholder()
                          : Image.network(
                              thumbnailUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (_, error, __) {
                                if (kDebugMode) {
                                  debugPrint(
                                    'Inspection thumbnail failed: $thumbnailUrl error=$error',
                                  );
                                }
                                return _photoPlaceholder();
                              },
                              loadingBuilder: (context, child, progress) {
                                if (progress == null) return child;
                                return _photoPlaceholder();
                              },
                            ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            dateTimeStr,
                            style: const TextStyle(
                              fontSize: 12,
                              color: _gray400,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            inspection.address.trim().isEmpty
                                ? 'Адрес не указан'
                                : inspection.address,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: inspection.address.trim().isEmpty
                                  ? _gray400
                                  : const Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  inspection.material,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: _gray500,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const Text(
                                ' \u2022 ',
                                style: TextStyle(
                                  color: _gray400,
                                  fontSize: 12,
                                ),
                              ),
                              const Text(
                                'Состояние: ',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: _gray500,
                                ),
                              ),
                              Text(
                                '${inspection.condition}/5',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: _teal,
                                ),
                              ),
                              const Text(
                                ' \u2022 ',
                                style: TextStyle(
                                  color: _gray400,
                                  fontSize: 12,
                                ),
                              ),
                              Text(
                                '$confidencePercent%',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: _gray500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: _gray400, size: 20),
                ],
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: _SyncStatusBadge(status: status),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _photoPlaceholder() {
    return Container(
      color: const Color(0xFFF1F5F9),
      child: const Icon(Icons.camera_alt, color: _gray400, size: 24),
    );
  }
}

class _SyncStatusBadge extends StatelessWidget {
  final InspectionSyncStatus status;

  const _SyncStatusBadge({required this.status});

  (Color background, Color textColor) get _colors {
    switch (status) {
      case InspectionSyncStatus.synced:
        return (const Color(0xFFD1FAE5), const Color(0xFF166534));
      case InspectionSyncStatus.outdated:
        return (const Color(0xFFFECACA), const Color(0xFF991B1B));
      case InspectionSyncStatus.pending:
      case InspectionSyncStatus.cached:
        return (const Color(0xFFFEF3C7), const Color(0xFF92400E));
    }
  }

  @override
  Widget build(BuildContext context) {
    final (background, textColor) = _colors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        status.cardBadgeLabel,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: textColor,
          height: 1.2,
        ),
      ),
    );
  }
}
