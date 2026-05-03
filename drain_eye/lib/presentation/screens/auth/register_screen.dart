import 'package:drain_eye/presentation/screens/auth/auth_widgets.dart';
import 'package:drain_eye/presentation/screens/admin/admin_main_screen.dart';
import 'package:drain_eye/presentation/screens/user/main_screen.dart';
import 'package:flutter/material.dart';

/// Экран регистрации (UC-2) — мокап.
/// Выбор роли: Инспектор / Администратор.
/// Кнопка «Создать аккаунт» переходит на MainScreen или AdminMainScreen.
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  String _selectedRole = 'inspector';

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
          const AuthLabel(label: 'ФИО'),
          const SizedBox(height: 4),
          authInputField(placeholder: 'Иванов Иван Иванович'),
          const SizedBox(height: 16),

          // поле Email
          const AuthLabel(label: 'Email'),
          const SizedBox(height: 4),
          authInputField(placeholder: 'user@example.com', keyboardType: TextInputType.emailAddress),
          const SizedBox(height: 16),

          // выбор роли
          const AuthLabel(label: 'Роль'),
          const SizedBox(height: 4),
          Container(
            width: double.infinity,
            height: 44,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: borderColor),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedRole,
                isExpanded: true,
                icon: const Icon(Icons.keyboard_arrow_down, color: gray400),
                style: const TextStyle(fontSize: 14, color: gray700),
                items: const [
                  DropdownMenuItem(value: 'inspector', child: Text('Инспектор')),
                  DropdownMenuItem(value: 'admin', child: Text('Администратор')),
                ],
                onChanged: (value) {
                  if (value != null) setState(() => _selectedRole = value);
                },
              ),
            ),
          ),
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
              final destination = _selectedRole == 'inspector'
                  ? const MainScreen()
                  : const AdminMainScreen();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => destination),
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
