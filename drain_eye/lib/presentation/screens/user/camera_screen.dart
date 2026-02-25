import 'package:drain_eye/presentation/screens/user/model_result_screen.dart';
import 'package:flutter/material.dart';

const _teal = Color(0xFF0D9488);
const _gray400 = Color(0xFF94A3B8);
const _gray500 = Color(0xFF64748B);

/// Экран камеры для новой инспекции (UC-8) — мокап.
/// Показывает область видоискателя, кнопку съёмки и выбор из галереи.
class CameraScreen extends StatelessWidget {
  const CameraScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // область видоискателя
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // перекрестие
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(width: 1, height: 30, color: Colors.white38),
                      const SizedBox(height: 6),
                      Container(height: 1, width: 30, color: Colors.white38),
                      const SizedBox(height: 6),
                      Container(width: 1, height: 30, color: Colors.white38),
                    ],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(height: 1, width: 30, color: Colors.white38),
                      const SizedBox(width: 6),
                      const SizedBox(width: 1, height: 1),
                      const SizedBox(width: 6),
                      Container(height: 1, width: 30, color: Colors.white38),
                    ],
                  ),
                  // подсказка
                  Positioned(
                    bottom: 24,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Наведите на дренажную систему',
                        style: TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // ряд кнопок камеры
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // галерея
              _circleButton(Icons.photo_library_outlined, 44),
              // затвор
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _teal,
                  border: Border.all(color: Colors.white, width: 3),
                  boxShadow: [
                    BoxShadow(color: _teal.withOpacity(0.3), blurRadius: 12, spreadRadius: 2),
                  ],
                ),
                child: const Icon(Icons.camera_alt, color: Colors.white, size: 28),
              ),
              // переключить камеру
              _circleButton(Icons.flip_camera_android, 44),
            ],
          ),
          const SizedBox(height: 16),

          // кнопки «Сделать фото» и «Из галереи»
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 44,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _teal,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      elevation: 0,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ModelResultScreen()),
                      );
                    },
                    icon: const Icon(Icons.camera_alt, size: 18),
                    label: const Text('Сделать фото', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: SizedBox(
                  height: 44,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _gray500,
                      side: const BorderSide(color: Color(0xFFE2E8F0)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ModelResultScreen()),
                      );
                    },
                    icon: const Icon(Icons.photo_library, size: 18),
                    label: const Text('Из галереи', style: TextStyle(fontSize: 14)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static Widget _circleButton(IconData icon, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFFF1F5F9),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Icon(icon, color: _gray500, size: 22),
    );
  }
}
