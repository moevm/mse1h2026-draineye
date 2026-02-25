import 'package:drain_eye/presentation/screens/auth/auth_widgets.dart';
import 'package:drain_eye/presentation/screens/user/main_screen.dart';
import 'package:flutter/material.dart';

/// Экран регистрации (UC-2) — мокап.
/// Кнопка «Создать аккаунт» переходит на MainScreen.
class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthBackground(
      child: AuthCard(
        children: [
          // логотип
          const AuthLogo(
            icon: Icons.visibility,
            title: 'Регистрация',
            subtitle: 'Создайте аккаунт DrainEye',
          ),

          // поле Имя
          const AuthLabel(label: 'Имя'),
          const SizedBox(height: 4),
          authInputField(placeholder: 'Иван Петров'),
          const SizedBox(height: 16),

          // поле Email
          const AuthLabel(label: 'Email'),
          const SizedBox(height: 4),
          authInputField(placeholder: 'user@example.com', keyboardType: TextInputType.emailAddress),
          const SizedBox(height: 16),

          // поле Пароль
          const AuthLabel(label: 'Пароль', hint: '(мин. 8 символов)'),
          const SizedBox(height: 4),
          authInputField(placeholder: 'Придумайте пароль', obscure: true),
          const SizedBox(height: 16),

          // поле Повтор пароля
          const AuthLabel(label: 'Повтор пароля'),
          const SizedBox(height: 4),
          authInputField(placeholder: 'Повторите пароль', obscure: true),
          const SizedBox(height: 20),

          // кнопка Создать аккаунт
          authPrimaryButton(
            label: 'Создать аккаунт',
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const MainScreen()),
              );
            },
          ),
          const SizedBox(height: 14),

          // ссылка «Уже есть аккаунт? Войти»
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Уже есть аккаунт? ', style: TextStyle(fontSize: 13, color: gray500)),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Text(
                  'Войти',
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
