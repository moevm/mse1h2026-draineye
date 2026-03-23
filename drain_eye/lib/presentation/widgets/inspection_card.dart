import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/inspection.dart';

const _teal = Color(0xFF0D9488);
const _gray400 = Color(0xFF94A3B8);
const _gray500 = Color(0xFF64748B);

// виджет карточки инспекции — по макету UC-7
class InspectionCard extends StatelessWidget {
  final Inspection inspection;
  final VoidCallback onTap;

  const InspectionCard({
    super.key,
    required this.inspection,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd.MM.yyyy, HH:mm');
    final dateTimeStr = dateFormat.format(inspection.timestamp);
    final confidencePercent = (inspection.confidence * 100).round();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 12),
        padding: const EdgeInsets.all(12),
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
        child: Row(
          children: [
            // миниатюра фото
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.camera_alt, color: _gray400, size: 24),
            ),
            const SizedBox(width: 12),
            // информация
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // дата
                  Text(
                    dateTimeStr,
                    style: const TextStyle(fontSize: 12, color: _gray400),
                  ),
                  const SizedBox(height: 3),
                  // адрес
                  Text(
                    inspection.address,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 4),
                  // материал · состояние · уверенность
                  Row(
                    children: [
                      Text(
                        inspection.material,
                        style: const TextStyle(fontSize: 12, color: _gray500),
                      ),
                      const Text(' \u2022 ', style: TextStyle(color: _gray400, fontSize: 12)),
                      const Text('Состояние: ', style: TextStyle(fontSize: 12, color: _gray500)),
                      Text(
                        '${inspection.condition}/5',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: _teal),
                      ),
                      const Text(' \u2022 ', style: TextStyle(color: _gray400, fontSize: 12)),
                      Text(
                        '$confidencePercent%',
                        style: const TextStyle(fontSize: 12, color: _gray500),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // стрелка
            const Icon(Icons.chevron_right, color: _gray400, size: 20),
          ],
        ),
      ),
    );
  }
}
