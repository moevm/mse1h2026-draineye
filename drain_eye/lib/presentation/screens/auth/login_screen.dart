import 'package:drain_eye/presentation/screens/auth/auth_widgets.dart';
import 'package:drain_eye/presentation/screens/auth/forgot_password_screen.dart';
import 'package:drain_eye/presentation/screens/auth/register_screen.dart';
import 'package:drain_eye/presentation/screens/admin/admin_main_screen.dart';
import 'package:drain_eye/presentation/screens/user/main_screen.dart';
import 'package:flutter/material.dart';

/// Экран входа (UC-1) — мокап без реальной авторизации.
/// Переключатель ролей: Инспектор / Администратор.
/// Кнопка «Войти» переходит на MainScreen или AdminMainScreen.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // 0 = Инспектор, 1 = Администратор
  int _selectedRole = 0;

  @override
  Widget build(BuildContext context) {
    return AuthBackground(
      child: AuthCard(
        children: [
          // логотип
          const AuthLogo(
            icon: Icons.visibility,
            title: 'DrainEye',
            subtitle: 'Вход в систему',
          ),

          // переключатель роли
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.all(3),
            child: Row(
              children: [
                _roleTab('Инспектор', 0),
                _roleTab('Администратор', 1),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // поле Email
          const AuthLabel(label: 'Email'),
          const SizedBox(height: 4),
          authInputField(placeholder: 'user@example.com', keyboardType: TextInputType.emailAddress),
          const SizedBox(height: 16),

          // поле Пароль
          const AuthLabel(label: 'Пароль'),
          const SizedBox(height: 4),
          authInputField(placeholder: 'Введите пароль', obscure: true),
          const SizedBox(height: 6),

          // ссылка «Забыли пароль?» → UC-3
          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()),
                );
              },
              child: const Text(
                'Забыли пароль?',
                style: TextStyle(fontSize: 13, color: teal, fontWeight: FontWeight.w500),
              ),
            ),
          ),
          const SizedBox(height: 18),

          // кнопка Войти → MainScreen или AdminMainScreen
          authPrimaryButton(
            label: 'Войти',
            onPressed: () {
              final destination = _selectedRole == 0
                  ? const MainScreen()
                  : const AdminMainScreen();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => destination),
              );
            },
          ),
          const SizedBox(height: 16),

          // разделитель «или»
          Row(
            children: [
              const Expanded(child: Divider(color: gray400)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text('или', style: TextStyle(fontSize: 12, color: gray400)),
              ),
              const Expanded(child: Divider(color: gray400)),
            ],
          ),
          const SizedBox(height: 16),

          // кнопка Google
          SizedBox(
            width: double.infinity,
            height: 44,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: gray500,
                side: const BorderSide(color: borderColor),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () {
                // TODO: Google OAuth
              },
              icon: const Text('G', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF4285F4))),
              label: const Text('Войти через Google', style: TextStyle(fontSize: 14)),
            ),
          ),
          const SizedBox(height: 20),

          // ссылка «Нет аккаунта? Зарегистрироваться» → UC-2
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Нет аккаунта? ', style: TextStyle(fontSize: 13, color: gray500)),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const RegisterScreen()),
                  );
                },
                child: const Text(
                  'Зарегистрироваться',
                  style: TextStyle(fontSize: 13, color: teal, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Таб переключателя роли.
  Widget _roleTab(String label, int index) {
    final isSelected = _selectedRole == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedRole = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 36,
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            boxShadow: isSelected
                ? [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 4, offset: const Offset(0, 1))]
                : null,
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              color: isSelected ? teal : gray500,
            ),
          ),
        ),
      ),
    );
  }
}
