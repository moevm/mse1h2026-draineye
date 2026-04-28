import 'package:flutter/material.dart';

/// Заглушка экрана камеры для веб-платформы.
/// Камера и TFLite недоступны в браузере.
class CameraScreen extends StatelessWidget {
  const CameraScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Icon(Icons.camera_alt_outlined, color: Color(0xFF94A3B8), size: 36),
            ),
            const SizedBox(height: 20),
            const Text(
              'Камера недоступна\nв браузере',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF334155)),
            ),
            const SizedBox(height: 8),
            const Text(
              'Для съёмки инспекций используйте\nмобильное приложение.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
            ),
          ],
        ),
      ),
    );
  }
}
