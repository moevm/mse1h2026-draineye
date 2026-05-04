import 'package:drain_eye/presentation/blocs/auth/auth_bloc.dart';
import 'package:drain_eye/presentation/screens/auth/auth_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Экран регистрации (UC-2) — регистрация инспектора через backend + FirebaseAuth.
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _repeatPasswordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _repeatPasswordController.dispose();
    super.dispose();
  }

  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'введите имя';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'введите email';
    }
    final regex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!regex.hasMatch(value.trim())) {
      return 'неверный формат email';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'введите пароль';
    }
    if (value.length < 8) {
      return 'пароль должен содержать не менее 8 символов';
    }
    if (!RegExp(r'[a-z]').hasMatch(value)) {
      return 'пароль должен содержать хотя бы одну строчную букву';
    }
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'пароль должен содержать хотя бы одну заглавную букву';
    }
    return null;
  }

  String? _validateRepeatPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'повторите пароль';
    }
    if (value != _passwordController.text) {
      return 'пароли не совпадают';
    }
    return null;
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    context.read<AuthBloc>().add(
          RegisterEvent(
            fullName: _nameController.text.trim(),
            email: _emailController.text.trim(),
            password: _passwordController.text,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthRegistrationSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Письмо подтверждения отправлено на ${state.email}. Подтвердите почту и войдите.',
              ),
              backgroundColor: teal,
            ),
          );
          Navigator.pop(context);
        }
        if (state is AuthError) {
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
              title: 'Регистрация',
              subtitle: 'Создайте аккаунт DrainEye',
            ),

            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // поле Имя
                  const AuthLabel(label: 'Имя'),
                  const SizedBox(height: 4),
                  _formField(
                    controller: _nameController,
                    placeholder: 'Иван Петров',
                    validator: _validateName,
                  ),
                  const SizedBox(height: 16),

                  // поле Email
                  const AuthLabel(label: 'Email'),
                  const SizedBox(height: 4),
                  _formField(
                    controller: _emailController,
                    placeholder: 'user@example.com',
                    keyboardType: TextInputType.emailAddress,
                    validator: _validateEmail,
                  ),
                  const SizedBox(height: 16),

                  // поле Пароль
                  const AuthLabel(label: 'Пароль', hint: '(мин. 8 символов)'),
                  const SizedBox(height: 4),
                  _formField(
                    controller: _passwordController,
                    placeholder: 'Придумайте пароль',
                    obscure: true,
                    validator: _validatePassword,
                    errorMaxLines: 3,
                  ),
                  const SizedBox(height: 16),

                  // поле Повтор пароля
                  const AuthLabel(label: 'Повтор пароля'),
                  const SizedBox(height: 4),
                  _formField(
                    controller: _repeatPasswordController,
                    placeholder: 'Повторите пароль',
                    obscure: true,
                    validator: _validateRepeatPassword,
                  ),
                  const SizedBox(height: 20),

                  // кнопка Создать аккаунт
                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      final isLoading = state is AuthLoading;
                      return authPrimaryButton(
                        label: isLoading ? 'Регистрация...' : 'Создать аккаунт',
                        onPressed: isLoading ? null : _submit,
                      );
                    },
                  ),
                ],
              ),
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
      ),
    );
  }

  Widget _formField({
    required TextEditingController controller,
    required String placeholder,
    required String? Function(String?) validator,
    bool obscure = false,
    TextInputType keyboardType = TextInputType.text,
    int errorMaxLines = 2,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      style: const TextStyle(fontSize: 14),
      decoration: InputDecoration(
        hintText: placeholder,
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
        errorMaxLines: errorMaxLines,
        errorStyle: const TextStyle(fontSize: 12, color: Colors.red),
      ),
      validator: validator,
    );
  }
}
