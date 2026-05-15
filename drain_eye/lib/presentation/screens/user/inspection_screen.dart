import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:drain_eye/presentation/widgets/inspection_photo_image.dart';
import 'package:drain_eye/core/confidence_accent_color.dart';
import 'package:drain_eye/core/damage_type_labels.dart';
import 'package:drain_eye/domain/entities/inspection.dart';

const _teal = Color(0xFF0D9488);
const _gray400 = Color(0xFF94A3B8);
const _gray500 = Color(0xFF64748B);

/// Экран просмотра инспекции (UC-7) — фото, информация, вердикт модели
/// (те же поля, что на экране результата модели).
class InspectionScreen extends StatefulWidget {
  final Inspection inspection;

  const InspectionScreen({super.key, required this.inspection});

  @override
  State<InspectionScreen> createState() => _InspectionScreenState();
}

class _InspectionScreenState extends State<InspectionScreen> {
  int _photoPage = 0;

  Inspection get inspection => widget.inspection;

  String _materialUi(Inspection i) {
    final m = i.material.trim();
    if (m.isEmpty || m == 'unknown') return '?';
    return m;
  }

  String _damageDegreeUi(Inspection i) {
    if (i.damageDegree == null) return '?';
    return i.damageDegree!.toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd.MM.yyyy, HH:mm');
    final dateTimeStr = dateFormat.format(inspection.timestamp);
    final accentColor =
        confidenceAccentColorFromPercent((inspection.confidence * 100).round());

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
            _photoCarousel(),
            const SizedBox(height: 16),

            _detailCard(
              title: 'Информация',
              rows: [
                _DetailRow('Дата', dateTimeStr),
                _DetailRow(
                  'Место',
                  inspection.address.trim().isEmpty
                      ? 'Адрес не указан'
                      : inspection.address,
                ),
              ],
            ),
            const SizedBox(height: 12),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border(left: BorderSide(color: accentColor, width: 4)),
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
                  Text(
                    'Вердикт модели',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: accentColor,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _verdictRow('Материал', _materialUi(inspection)),
                  _verdictRow('Состояние', inspection.condition.toString()),
                  _verdictRow('Тип повреждения', damageTypeLabelRu(inspection.damageTypeCode)),
                  _verdictRow('Степень повреждения', _damageDegreeUi(inspection)),
                  _verdictRow(
                    'Уверенность модели',
                    '${(inspection.confidence * 100).toStringAsFixed(1)}%',
                    valueColor: accentColor,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

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

  Widget _photoCarousel() {
    final photoUrls = inspection.photoUrls;
    if (photoUrls.isEmpty) {
      return _photoPlaceholder('Фото не найдено');
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: SizedBox(
        width: double.infinity,
        height: 220,
        child: Stack(
          fit: StackFit.expand,
          children: [
            PageView.builder(
              itemCount: photoUrls.length,
              onPageChanged: (page) => setState(() => _photoPage = page),
              itemBuilder: (context, index) {
                return InspectionPhotoImage(
                  source: photoUrls[index],
                  width: double.infinity,
                  height: 220,
                  fit: BoxFit.cover,
                  cloudinaryTransformations: 'w_900,h_500,c_fit,q_auto,f_auto',
                  placeholder: _photoPlaceholder('Не удалось загрузить фото'),
                );
              },
            ),
            Positioned(
              right: 12,
              bottom: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.55),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  'Фото ${_photoPage + 1} из ${photoUrls.length}',
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _photoPlaceholder(String label) {
    return Container(
      width: double.infinity,
      height: 220,
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.camera_alt, color: _gray400, size: 40),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 11, color: _gray400)),
        ],
      ),
    );
  }

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
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 10),
          ...rows.map((r) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(r.label, style: const TextStyle(fontSize: 13, color: _gray500)),
                    Text(
                      r.value,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _verdictRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(label, style: const TextStyle(fontSize: 13, color: _gray500)),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: valueColor ?? const Color(0xFF0F172A),
              ),
            ),
          ),
        ],
      ),
    );
  }

}

class _DetailRow {
  final String label;
  final String value;
  _DetailRow(this.label, this.value);
}
