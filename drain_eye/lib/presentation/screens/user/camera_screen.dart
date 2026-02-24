import 'package:flutter/material.dart';

// экран камеры для новой инспекции
class CameraScreen extends StatelessWidget {
  const CameraScreen({super.key});

  // создает экран с камерой (заглушка)
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Экран камеры (заглушка)',
        style: TextStyle(fontSize: 18),
      ),
    );
  }
}