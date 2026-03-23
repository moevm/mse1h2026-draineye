import 'package:flutter/material.dart';

const _teal = Color(0xFF0D9488);
const _gray400 = Color(0xFF94A3B8);
const _gray500 = Color(0xFF64748B);
const _orange = Color(0xFFF59E0B);

/// Экран низкой уверенности модели (UC-9) — предупреждение + выбор действия.
class LowConfidenceScreen extends StatefulWidget {
  final String material;
  final int condition;
  final int confidencePercent;

  const LowConfidenceScreen({
    super.key,
    this.material = 'Металл',
    this.condition = 2,
    this.confidencePercent = 38,
  });

  @override
  State<LowConfidenceScreen> createState() => _LowConfidenceScreenState();
}

class _LowConfidenceScreenState extends State<LowConfidenceScreen> {
  int _selectedOption = 0;

  final _options = [
    'Переснять фото',
    'Уточнить материал',
    'Проверить вручную',
  ];

  @override
  Widget build(BuildContext context) {
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
            Container(
              width: double.infinity,
              height: 120,
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.camera_alt, color: _gray400, size: 32),
            ),
            const SizedBox(height: 14),

            // карточка результата (оранжевая граница)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: const Border(left: BorderSide(color: _orange, width: 4)),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Результат анализа', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: _orange)),
                  const SizedBox(height: 10),
                  _row('Материал', widget.material),
                  _row('Состояние', '${widget.condition} / 5', badge: true),
                  _row('Уверенность', '${widget.confidencePercent}%', valueColor: _orange),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // предупреждение
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFBEB),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFFDE68A)),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('! Низкая уверенность', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: _orange)),
                  SizedBox(height: 4),
                  Text('Выберите действие:', style: TextStyle(fontSize: 13, color: _gray500)),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // варианты действий (radio)
            ...List.generate(_options.length, (i) {
              final selected = _selectedOption == i;
              return GestureDetector(
                onTap: () => setState(() => _selectedOption = i),
                child: Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 6),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: selected ? _teal.withOpacity(0.05) : Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: selected ? _teal : const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 18,
                        height: 18,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: selected ? _teal : _gray400, width: 2),
                        ),
                        child: selected
                            ? Center(child: Container(width: 8, height: 8, decoration: const BoxDecoration(shape: BoxShape.circle, color: _teal)))
                            : null,
                      ),
                      const SizedBox(width: 10),
                      Text(_options[i], style: TextStyle(fontSize: 14, color: selected ? _teal : const Color(0xFF0F172A))),
                    ],
                  ),
                ),
              );
            }),
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
                      child: const Text('OK', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
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
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value, {bool badge = false, Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, color: _gray500)),
          badge
              ? Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(color: _orange.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                  child: Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: _orange)),
                )
              : Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: valueColor ?? const Color(0xFF0F172A))),
        ],
      ),
    );
  }
}
