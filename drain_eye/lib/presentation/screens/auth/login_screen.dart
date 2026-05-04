import 'package:drain_eye/presentation/blocs/auth/auth_bloc.dart';
import 'package:drain_eye/presentation/screens/auth/auth_widgets.dart';
import 'package:drain_eye/presentation/screens/auth/forgot_password_screen.dart';
import 'package:drain_eye/presentation/screens/auth/register_screen.dart';
import 'package:drain_eye/presentation/screens/admin/admin_main_screen.dart';
import 'package:drain_eye/presentation/screens/user/main_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Экран входа (UC-1) — с реальной авторизацией через BLoC.
/// Кнопка «Войти» вызывает событие LoginEvent, валидирует поля,
/// показывает загрузку и обрабатывает результат.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // валидация email
  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'введите email';
    }
    final regex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!regex.hasMatch(value)) {
      return 'неверный формат email';
    }
    return null;
  }

  // валидация пароля
  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'введите пароль';
    }
    if (value.length < 8) {
      return 'пароль должен содержать не менее 8 символов';
    }
    // проверка на наличие строчной буквы
    if (!RegExp(r'[a-z]').hasMatch(value)) {
      return 'пароль должен содержать хотя бы одну строчную букву';
    }
    // проверка на наличие заглавной буквы
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'пароль должен содержать хотя бы одну заглавную букву';
    }
    return null;
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final email = _emailController.text.trim();
      final password = _passwordController.text;
      context.read<AuthBloc>().add(LoginEvent(email: email, password: password));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          // успешный вход — переход на главный экран
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const MainScreen()),
          );
        }
        if (state is AuthError) {
          // показать ошибку
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: AuthBackground(
        child: AuthCard(
          children: [
            // логотип
            const AuthLogo(
              icon: Icons.visibility,
              title: 'DrainEye',
              subtitle: 'Вход в систему',
            ),

            // форма
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // поле Email
                  const AuthLabel(label: 'Email'),
                  const SizedBox(height: 4),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      hintText: 'user@example.com',
                      hintStyle: const TextStyle(color: gray400, fontSize: 14),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: borderColor),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: borderColor),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: teal, width: 1.5),
                      ),
                      errorMaxLines: 2,
                      errorStyle: const TextStyle(fontSize: 12, color: Colors.red),
                    ),
                    validator: _validateEmail,
                  ),
                  const SizedBox(height: 16),

                  // поле Пароль
                  const AuthLabel(label: 'Пароль'),
                  const SizedBox(height: 4),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      hintText: 'Введите пароль',
                      hintStyle: const TextStyle(color: gray400, fontSize: 14),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: borderColor),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: borderColor),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: teal, width: 1.5),
                      ),
                      errorMaxLines: 3,
                      errorStyle: const TextStyle(fontSize: 12, color: Colors.red),
                    ),
                    validator: _validatePassword,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Пароль должен содержать не менее 8 символов, включая строчную и заглавную буквы',
                    style: const TextStyle(fontSize: 12, color: gray500),
                  ),
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

                  // кнопка Войти
                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      final isLoading = state is AuthLoading;
                      return authPrimaryButton(
                        label: isLoading ? 'Вход...' : 'Войти',
                        onPressed: isLoading ? null : _submit,
                      );
                    },
                  ),
                ],
              ),
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
            BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) {
                final isLoading = state is AuthLoading;
                return SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: gray500,
                      side: const BorderSide(color: borderColor),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: isLoading
                        ? null
                        : () {
                            context.read<AuthBloc>().add(GoogleLoginEvent());
                          },
                    icon: const Text('G', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF4285F4))),
                    label: Text(isLoading ? 'Вход...' : 'Войти через Google', style: const TextStyle(fontSize: 14)),
                  ),
                );
              },
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
      ),
    );
  }

  Widget _inputField({
    required TextEditingController controller,
    required String placeholder,
    bool obscure = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      style: const TextStyle(fontSize: 14),
      decoration: InputDecoration(
        hintText: placeholder,
        hintStyle: const TextStyle(color: gray400, fontSize: 14),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: borderColor)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: borderColor)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: teal, width: 1.5)),
      ),
    );
  }
}
