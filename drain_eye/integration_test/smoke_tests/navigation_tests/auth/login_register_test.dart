import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:drain_eye/main.dart' as app;
import 'package:drain_eye/presentation/screens/auth/login_screen.dart';
import 'package:drain_eye/presentation/screens/auth/register_screen.dart';
import '../../../utils/constants.dart';
import '../../../pages/login_page.dart';
import '../../../pages/register_page.dart';

/// Тесты навигации между LoginScreen и RegisterScreen
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Тесты: LoginScreen и RegisterScreen', () {
    testWidgets(
      'LoginScreen - "Зарегистрироваться" - RegisterScreen',
      (WidgetTester tester) async {
        app.main();
        await tester.pumpAndSettle();

        final loginPage = LoginPage(tester);
        final registerPage = RegisterPage(tester);

        expect(find.byType(LoginScreen), findsOneWidget);

        // Нажатие "Зарегистрироваться"
        await loginPage.tapRegister();
        await tester.pumpAndSettle();

        // Открытие RegisterScreen
        expect(find.byType(RegisterScreen), findsOneWidget);
        await registerPage.expectHeadersVisible();
      },
    );

    testWidgets('RegisterScreen - "Войти" - LoginScreen', (
      WidgetTester tester,
    ) async {
      app.main();
      await tester.pumpAndSettle();

      final loginPage = LoginPage(tester);
      final registerPage = RegisterPage(tester);

      // Переход на RegisterScreen
      await loginPage.tapRegister();
      await tester.pumpAndSettle();
      expect(find.byType(RegisterScreen), findsOneWidget);

      // Нажиматие "Войти"
      await registerPage.tapLoginLink();
      await tester.pumpAndSettle();

      // Возврат на LoginScreen
      expect(find.byType(LoginScreen), findsOneWidget);
      await loginPage.expectFormVisible();
    });
  });
}
