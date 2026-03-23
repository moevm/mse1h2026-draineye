import 'package:drain_eye/presentation/screens/auth/auth_widgets.dart';
import 'package:drain_eye/presentation/screens/auth/forgot_password_screen.dart';
import 'package:drain_eye/presentation/screens/auth/register_screen.dart';
import 'package:drain_eye/presentation/screens/user/main_screen.dart';
import 'package:flutter/material.dart';

/// Экран входа (UC-1) — мокап без реальной авторизации.
/// Кнопка «Войти» переходит на MainScreen.
/// Ссылки ведут на UC-2 (регистрация) и UC-3 (восстановление пароля).
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

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

          // кнопка Войти → MainScreen
          authPrimaryButton(
            label: 'Войти',
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const MainScreen()),
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
}
