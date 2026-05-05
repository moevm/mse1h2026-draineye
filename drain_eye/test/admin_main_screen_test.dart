import 'package:drain_eye/presentation/screens/admin/admin_main_screen.dart';
import 'package:drain_eye/presentation/screens/auth/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrap(Widget child) => MaterialApp(home: child);

void main() {
  group('AdminMainScreen', () {
    testWidgets('Отображает панель управления при запуске по умолчанию', (tester) async {
      await tester.pumpWidget(_wrap(const AdminMainScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Панель управления'), findsOneWidget);

      expect(find.text('Обзор системы'), findsOneWidget);
      expect(find.text('Последние действия'), findsOneWidget);

      expect(find.text('Главная'), findsOneWidget);
      expect(find.text('Пользователи'), findsOneWidget);
      expect(find.text('Инспекции'), findsOneWidget);
      expect(find.text('Настройки'), findsOneWidget);
    });

    testWidgets('Переключает вкладки и обновляет заголовок AppBar', (tester) async {
      await tester.pumpWidget(_wrap(const AdminMainScreen()));
      await tester.pumpAndSettle();

      // Вкладка "Пользователи"
      await tester.tap(find.text('Пользователи'));
      await tester.pumpAndSettle();
      expect(find.text('Пользователи'), findsOneWidget);
      expect(find.text('Все пользователи'), findsOneWidget);

      // Вкладка "Инспекции"
      await tester.tap(find.text('Инспекции'));
      await tester.pumpAndSettle();
      expect(find.text('Инспекции'), findsOneWidget);
      expect(find.text('Все инспекции'), findsOneWidget);
      expect(find.textContaining('записей'), findsOneWidget); // Например, "5 записей"

      // Вкладка "Настройки"
      await tester.tap(find.text('Настройки'));
      await tester.pumpAndSettle();
      expect(find.text('Настройки'), findsOneWidget);
      expect(find.text('Система'), findsOneWidget);
      expect(find.text('Уведомления'), findsOneWidget);
      expect(find.text('Безопасность'), findsOneWidget);
      expect(find.text('Выйти из аккаунта'), findsOneWidget);
    });

    testWidgets('Выход из системы через иконку в AppBar перенаправляет на экран входа', (tester) async {
      await tester.pumpWidget(_wrap(const AdminMainScreen()));
      await tester.pumpAndSettle();

      // Нажатие на иконку выхода в AppBar
      await tester.tap(find.byIcon(Icons.logout));
      await tester.pumpAndSettle();

      expect(find.byType(LoginScreen), findsOneWidget);
    });

    testWidgets('Выход из системы через кнопку в настройках перенаправляет на экран входа', (tester) async {
      await tester.pumpWidget(_wrap(const AdminMainScreen()));
      await tester.pumpAndSettle();

      // Открытие вкладки "Настройки"
      await tester.tap(find.text('Настройки'));
      await tester.pumpAndSettle();

      // Нажатие на кнопку "Выйти из аккаунта"
      await tester.tap(find.text('Выйти из аккаунта'));
      await tester.pumpAndSettle();

      expect(find.byType(LoginScreen), findsOneWidget);
    });
  });
}