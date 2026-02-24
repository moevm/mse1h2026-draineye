import 'package:flutter/material.dart';

// экран с профилем
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  // создает экран с профилем (заглушка)
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Экран профиля (заглушка)',
        style: TextStyle(fontSize: 18),
      ),
    );
  }
}