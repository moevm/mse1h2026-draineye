import 'package:drain_eye/presentation/screens/auth/auth_widgets.dart';
import 'package:flutter/material.dart';

/// Экран восстановления пароля (UC-3) — мокап, два шага:
/// 1. Ввод email → показ сообщения «Письмо отправлено»
/// 2. Ввод нового пароля → возврат на экран входа
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  // false = шаг 1 (ввод email), true = шаг 2 (новый пароль)
  bool _step2 = false;
  bool _emailSent = false;

  @override
  Widget build(BuildContext context) {
    return AuthBackground(
      child: _step2 ? _buildStep2() : _buildStep1(),
    );
  }

  // --- Шаг 1: запрос ссылки ---
  Widget _buildStep1() {
    return AuthCard(
      children: [
        const AuthLogo(
          icon: Icons.lock_outline,
          title: 'Восстановление пароля',
          subtitle: 'Введите email для получения ссылки',
        ),

        // поле Email
        const AuthLabel(label: 'Email'),
        const SizedBox(height: 4),
        authInputField(placeholder: 'user@example.com', keyboardType: TextInputType.emailAddress),
        const SizedBox(height: 14),

        // сообщение «Письмо отправлено» (показывается после нажатия)
        if (_emailSent)
          const AuthSuccessMessage(text: 'Письмо отправлено. Проверьте почту и папку «Спам»'),

        // кнопка Отправить ссылку
        authPrimaryButton(
          label: 'Отправить ссылку',
          onPressed: () {
            setState(() {
              if (_emailSent) {
                // второе нажатие → переход к шагу 2
                _step2 = true;
              } else {
                // первое нажатие → показ сообщения
                _emailSent = true;
              }
            });
          },
        ),
        const SizedBox(height: 10),

        // кнопка Назад ко входу
        authOutlineButton(
          label: '\u2190 Назад ко входу',
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }

  // --- Шаг 2: новый пароль ---
  Widget _buildStep2() {
    return AuthCard(
      children: [
        const AuthLogo(
          icon: Icons.lock_outline,
          title: 'Новый пароль',
          subtitle: 'Придумайте новый пароль',
        ),

        // поле Новый пароль
        const AuthLabel(label: 'Новый пароль', hint: '(мин. 8 символов)'),
        const SizedBox(height: 4),
        authInputField(placeholder: 'Введите новый пароль', obscure: true),
        const SizedBox(height: 16),

        // поле Повтор пароля
        const AuthLabel(label: 'Повтор пароля'),
        const SizedBox(height: 4),
        authInputField(placeholder: 'Повторите пароль', obscure: true),
        const SizedBox(height: 20),

        // кнопка Сохранить пароль → возврат на экран входа
        authPrimaryButton(
          label: 'Сохранить пароль',
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }
}
