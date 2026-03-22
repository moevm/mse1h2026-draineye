import 'dart:io' show File;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

const _teal = Color(0xFF0D9488);
const _gray400 = Color(0xFF94A3B8);
const _gray500 = Color(0xFF64748B);
const _green = Color(0xFF22C55E);
const _orange = Color(0xFFF59E0B);

/// Экран результата модели (UC-8) — высокая уверенность.
/// Показывает результат AI-анализа после съёмки.
/// [photoPath] — локальный путь к JPEG после съёмки; для заглушек (например «Из галереи») может быть null.
class ModelResultScreen extends StatelessWidget {
  /// Путь к файлу снимка на устройстве (для передачи в модель / сохранение в БД).
  final String? photoPath;
  final String material;
  final int condition;
  final int confidencePercent;

  const ModelResultScreen({
    super.key,
    this.photoPath,
    this.material = 'Бетон',
    this.condition = 4,
    this.confidencePercent = 92,
  });

  @override
  Widget build(BuildContext context) {
    final isHighConfidence = confidencePercent >= 60;
    final accentColor = isHighConfidence ? _green : _orange;

    return Scaffold(
      backgroundColor: const Color(0xFFF0FDFA),
      appBar: AppBar(
        title: const Text('Результат'),
        titleTextStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
        backgroundColor: _teal,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // фото
            _buildPhotoPreview(),
            const SizedBox(height: 16),

            // карточка результата
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border(left: BorderSide(color: accentColor, width: 4)),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Результат анализа', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: accentColor)),
                  const SizedBox(height: 12),
                  _row('Материал', material),
                  _row('Состояние', '$condition / 5', badge: true, badgeColor: accentColor),
                  _row('Уверенность модели', '$confidencePercent%', valueColor: accentColor),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // индикаторы
            Row(
              children: [
                Expanded(child: _gauge('$condition', 'Состояние', accentColor)),
                const SizedBox(width: 12),
                Expanded(child: _gauge('$confidencePercent%', 'Уверенность', accentColor)),
              ],
            ),
            const SizedBox(height: 24),

            // кнопка OK — Сохранить
            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _teal,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  elevation: 0,
                ),
                onPressed: () {
                  // возврат на главный экран (история)
                  Navigator.popUntil(context, (route) => route.isFirst);
                },
                child: const Text('OK — Сохранить', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoPreview() {
    final path = photoPath;
    if (path != null && path.isNotEmpty && !kIsWeb) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: SizedBox(
          width: double.infinity,
          height: 160,
          child: Image.file(
            File(path),
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _photoPlaceholder(),
          ),
        ),
      );
    }
    return _photoPlaceholder();
  }

  Widget _photoPlaceholder() {
    return Container(
      width: double.infinity,
      height: 160,
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Icon(Icons.camera_alt, color: _gray400, size: 40),
    );
  }

  Widget _row(String label, String value, {bool badge = false, Color? badgeColor, Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, color: _gray500)),
          badge
              ? Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: (badgeColor ?? _green).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: badgeColor ?? _green)),
                )
              : Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: valueColor ?? const Color(0xFF0F172A))),
        ],
      ),
    );
  }

  Widget _gauge(String value, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
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
