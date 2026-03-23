import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:drain_eye/domain/entities/inspection.dart';

const _teal = Color(0xFF0D9488);
const _gray400 = Color(0xFF94A3B8);
const _gray500 = Color(0xFF64748B);
const _green = Color(0xFF22C55E);

/// Экран просмотра инспекции (UC-7) — фото, информация, вердикт модели.
class InspectionScreen extends StatelessWidget {
  final Inspection inspection;

  const InspectionScreen({super.key, required this.inspection});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd.MM.yyyy, HH:mm');
    final dateTimeStr = dateFormat.format(inspection.timestamp);
    final confidencePercent = (inspection.confidence * 100).round();

    return Scaffold(
      backgroundColor: const Color(0xFFF0FDFA),
      appBar: AppBar(
        title: Text('Инспекция #${inspection.id}'),
        titleTextStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 18,
          color: Colors.white,
        ),
        backgroundColor: _teal,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // область фото
            Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.camera_alt, color: _gray400, size: 40),
                  const SizedBox(height: 8),
                  Text('Фото 1 из 3', style: TextStyle(fontSize: 11, color: _gray400)),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // карточка «Информация»
            _detailCard(
              title: 'Информация',
              rows: [
                _DetailRow('Дата', dateTimeStr),
                _DetailRow('Место', inspection.address),
              ],
            ),
            const SizedBox(height: 12),

            // карточка «Вердикт модели»
            _detailCard(
              title: 'Вердикт модели',
              rows: [
                _DetailRow('Материал', inspection.material),
                _DetailRow('Состояние', '${inspection.condition} / 5', badge: true),
                _DetailRow('Уверенность', '$confidencePercent%'),
              ],
            ),
            const SizedBox(height: 16),

            // круглые индикаторы
            Row(
              children: [
                Expanded(child: _gauge('${inspection.condition}', 'Состояние', inspection.condition)),
                const SizedBox(width: 12),
                Expanded(child: _gauge('$confidencePercent%', 'Уверенность', inspection.condition)),
              ],
            ),
            const SizedBox(height: 20),

            // кнопка Закрыть
            SizedBox(
              width: double.infinity,
              height: 44,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: _gray500,
                  side: const BorderSide(color: Color(0xFFE2E8F0)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text('Закрыть', style: TextStyle(fontSize: 14)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // карточка с деталями
  Widget _detailCard({required String title, required List<_DetailRow> rows}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF0F172A))),
          const SizedBox(height: 10),
          ...rows.map((r) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(r.label, style: const TextStyle(fontSize: 13, color: _gray500)),
                r.badge
                    ? Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: _green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(r.value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: _green)),
                      )
                    : Text(r.value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF0F172A))),
              ],
            ),
          )),
        ],
      ),
    );
  }

  // круглый индикатор
  Widget _gauge(String value, String label, int condition) {
    final color = condition >= 4 ? _green : (condition >= 3 ? const Color(0xFFF59E0B) : const Color(0xFFEF4444));
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        children: [
          Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: color)),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 11, color: _gray400)),
        ],
      ),
    );
  }
}

class _DetailRow {
  final String label;
  final String value;
  final bool badge;
  _DetailRow(this.label, this.value, {this.badge = false});
}
