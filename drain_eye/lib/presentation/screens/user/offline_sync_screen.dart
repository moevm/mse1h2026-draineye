import 'package:flutter/material.dart';

const _teal = Color(0xFF0D9488);
const _gray400 = Color(0xFF94A3B8);
const _gray500 = Color(0xFF64748B);
const _orange = Color(0xFFF59E0B);

/// Экран офлайн-синхронизации (UC-10) — нет соединения, сохранение в кэш.
class OfflineSyncScreen extends StatelessWidget {
  const OfflineSyncScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0FDFA),
      appBar: AppBar(
        title: Row(
          children: [
            const Text('DrainEye'),
            const Spacer(),
            Text('Офлайн', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w400, color: Colors.white70)),
          ],
        ),
        titleTextStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
        backgroundColor: _gray500,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // предупреждение «Нет Интернет-соединения»
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFFECACA)),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Нет Интернет-соединения', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFFEF4444))),
                  SizedBox(height: 4),
                  Text(
                    'Результат будет сохранён в кэш и автоматически выгружен при появлении соединения.',
                    style: TextStyle(fontSize: 13, color: _gray500),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // карточка «Ожидает отправки»
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: const Border(left: BorderSide(color: _gray400, width: 4)),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Ожидает отправки', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF0F172A))),
                  const SizedBox(height: 10),
                  _row('Материал', 'Бетон'),
                  _rowBadge('Состояние', '3 / 5', const Color(0xFF94A3B8)),
                  _row('Уверенность', '75%'),
                  _rowBadge('Статус', 'В кэше', _orange),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // кнопки OK / Отмена
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 44,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _teal,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        elevation: 0,
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text('OK — В кэш', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: SizedBox(
                    height: 44,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _gray500,
                        side: const BorderSide(color: Color(0xFFE2E8F0)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Отмена', style: TextStyle(fontSize: 14)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // счётчик «Ожидают синхронизации»
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Column(
                children: [
                  Text('Ожидают синхронизации', style: TextStyle(fontSize: 11, color: _gray500)),
                  SizedBox(height: 4),
                  Text('3', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: _orange)),
                  Text('инспекции', style: TextStyle(fontSize: 10, color: _gray400)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, color: _gray500)),
          Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF0F172A))),
        ],
      ),
    );
  }

  static Widget _rowBadge(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, color: _gray500)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
            child: Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: color)),
          ),
        ],
      ),
    );
  }
}
