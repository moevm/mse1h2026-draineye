import 'package:drain_eye/presentation/screens/auth/login_screen.dart';
import 'package:flutter/material.dart';

const _teal = Color(0xFF0D9488);
const _tealDark = Color(0xFF0F766E);
const _gray400 = Color(0xFF94A3B8);
const _gray500 = Color(0xFF64748B);
const _green = Color(0xFF22C55E);

/// Экран профиля инспектора — мокап по UC-4 (адаптирован для мобильного).
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // аватар + имя
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2)),
              ],
            ),
            child: Column(
              children: [
                // аватар
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: _teal.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(32),
                  ),
                  child: const Center(
                    child: Text('АИ', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: _tealDark)),
                  ),
                ),
                const SizedBox(height: 12),
                const Text('Иванов Алексей', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF0F172A))),
                const SizedBox(height: 4),
                const Text('ivanov@mail.com', style: TextStyle(fontSize: 13, color: _gray500)),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: _green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text('Активен', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _green)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // информация
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2)),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Информация', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF0F172A))),
                const SizedBox(height: 12),
                _infoRow('Роль', 'Инспектор'),
                _infoRow('Дата регистрации', '15.01.2026'),
                _infoRow('Всего инспекций', '124'),
                _infoRow('Последняя активность', '23.02.2026'),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // кнопка Выйти
          SizedBox(
            width: double.infinity,
            height: 44,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFEF4444),
                side: const BorderSide(color: Color(0xFFFECACA)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              },
              child: const Text('Выйти', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, color: _gray500)),
          Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF0F172A))),
        ],
      ),
    );
  }
}
