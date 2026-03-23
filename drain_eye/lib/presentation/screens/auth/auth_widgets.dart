import 'package:flutter/material.dart';

// === цвета из макета ui-mockups.html ===
const teal = Color(0xFF0D9488);
const tealDark = Color(0xFF0F766E);
const tealBg = Color(0xFFF0FDFA);
const gray400 = Color(0xFF94A3B8);
const gray500 = Color(0xFF64748B);
const gray700 = Color(0xFF334155);
const borderColor = Color(0xFFE2E8F0);

/// Фон авторизации — градиент + декоративные круги.
class AuthBackground extends StatelessWidget {
  final Widget child;
  const AuthBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [tealBg, Color(0xFFCCFBF1)],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: -60,
              right: -60,
              child: _circle(200, teal.withOpacity(0.07)),
            ),
            Positioned(
              bottom: -40,
              left: -40,
              child: _circle(160, teal.withOpacity(0.05)),
            ),
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 40),
                child: child,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _circle(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }
}

/// Белая карточка формы авторизации.
class AuthCard extends StatelessWidget {
  final List<Widget> children;
  const AuthCard({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 380),
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: children),
    );
  }
}

/// Логотип-иконка + заголовок + подпись.
class AuthLogo extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  const AuthLogo({super.key, required this.icon, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: teal.withOpacity(0.1),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: teal, size: 30),
        ),
        const SizedBox(height: 12),
        Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: tealDark)),
        const SizedBox(height: 4),
        Text(subtitle, style: const TextStyle(fontSize: 13, color: gray500)),
        const SizedBox(height: 24),
      ],
    );
  }
}

/// Подпись поля ввода.
class AuthLabel extends StatelessWidget {
  final String label;
  final String? hint;
  const AuthLabel({super.key, required this.label, this.hint});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: hint == null
          ? Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: gray700))
          : RichText(
              text: TextSpan(
                text: '$label ',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: gray700),
                children: [TextSpan(text: hint, style: const TextStyle(fontWeight: FontWeight.w400, color: gray400))],
              ),
            ),
    );
  }
}

/// Текстовое поле ввода в стиле макета.
Widget authInputField({
  required String placeholder,
  bool obscure = false,
  TextInputType keyboardType = TextInputType.text,
}) {
  return TextField(
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

/// Основная кнопка (teal).
Widget authPrimaryButton({required String label, required VoidCallback onPressed}) {
  return SizedBox(
    width: double.infinity,
    height: 44,
    child: ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: teal,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 0,
      ),
      onPressed: onPressed,
      child: Text(label, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
    ),
  );
}

/// Контурная кнопка (outline).
Widget authOutlineButton({required String label, required VoidCallback onPressed}) {
  return SizedBox(
    width: double.infinity,
    height: 44,
    child: OutlinedButton(
      style: OutlinedButton.styleFrom(
        foregroundColor: gray500,
        side: const BorderSide(color: borderColor),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      onPressed: onPressed,
      child: Text(label, style: const TextStyle(fontSize: 14)),
    ),
  );
}

/// Сообщение об успехе (зелёная плашка).
class AuthSuccessMessage extends StatelessWidget {
  final String text;
  const AuthSuccessMessage({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDF4),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFBBF7D0)),
      ),
      child: Text(text, style: const TextStyle(fontSize: 13, color: Color(0xFF166534))),
    );
  }
}
