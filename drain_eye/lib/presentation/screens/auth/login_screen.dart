import 'package:drain_eye/data/datasources/auth_remote_datasource.dart';
import 'package:drain_eye/presentation/screens/auth/auth_widgets.dart';
import 'package:drain_eye/presentation/screens/auth/forgot_password_screen.dart';
import 'package:drain_eye/presentation/screens/auth/register_screen.dart';
import 'package:drain_eye/presentation/screens/admin/admin_main_screen.dart';
import 'package:drain_eye/presentation/screens/user/main_screen.dart';
import 'package:flutter/material.dart';

/// Экран входа (UC-1).
/// Переключатель ролей: Инспектор / Администратор.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _loading = false;
  String? _error;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _ds = AuthRemoteDataSource();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    if (email.isEmpty || password.isEmpty) {
      setState(() => _error = 'Заполните все поля');
      return;
    }
    setState(() { _loading = true; _error = null; });
    try {
      final result = await _ds.login(email: email, password: password);
      if (!mounted) return;
      final destination = result.role == 'admin'
          ? const AdminMainScreen()
          : const MainScreen();
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => destination));
    } on AuthException catch (e) {
      setState(() => _error = e.message);
    } catch (_) {
      setState(() => _error = 'Нет соединения с сервером');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthBackground(
      child: AuthCard(
        children: [
          const AuthLogo(
            icon: Icons.visibility,
            title: 'DrainEye',
            subtitle: 'Вход в систему',
          ),

          // поле Email
          const AuthLabel(label: 'Email'),
          const SizedBox(height: 4),
          _inputField(controller: _emailController, placeholder: 'user@example.com', keyboardType: TextInputType.emailAddress),
          const SizedBox(height: 16),

          // поле Пароль
          const AuthLabel(label: 'Пароль'),
          const SizedBox(height: 4),
          _inputField(controller: _passwordController, placeholder: 'Введите пароль', obscure: true),
          const SizedBox(height: 6),

          // ссылка «Забыли пароль?»
          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ForgotPasswordScreen())),
              child: const Text('Забыли пароль?', style: TextStyle(fontSize: 13, color: teal, fontWeight: FontWeight.w500)),
            ),
          ),
          const SizedBox(height: 14),

          // ошибка
          if (_error != null) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFFECACA)),
              ),
              child: Text(_error!, style: const TextStyle(fontSize: 13, color: Color(0xFFB91C1C))),
            ),
            const SizedBox(height: 10),
          ],

          // кнопка Войти
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: teal,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                elevation: 0,
              ),
              onPressed: _loading ? null : _submit,
              child: _loading
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('Войти', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
            ),
          ),
          const SizedBox(height: 16),

          // разделитель
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
              onPressed: () {},
              icon: const Text('G', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF4285F4))),
              label: const Text('Войти через Google', style: TextStyle(fontSize: 14)),
            ),
          ),
          const SizedBox(height: 20),

          // ссылка «Нет аккаунта?»
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Нет аккаунта? ', style: TextStyle(fontSize: 13, color: gray500)),
              GestureDetector(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterScreen())),
                child: const Text('Зарегистрироваться', style: TextStyle(fontSize: 13, color: teal, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ],
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
