import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:drain_eye/main.dart' as app;
import 'package:drain_eye/presentation/screens/auth/login_screen.dart';
import 'package:drain_eye/presentation/screens/auth/forgot_password_screen.dart';
import '../../../pages/login_page.dart';
import '../../../pages/forgot_password_page.dart';

/// Тесты навигации между LoginScreen и ForgotPasswordScreen
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Тесты: LoginScreen и ForgotPasswordScreen', () {
    testWidgets(
      'LoginScreen - "Забыли пароль?" - ForgotPasswordScreen',
      (WidgetTester tester) async {
        app.main();
        await tester.pumpAndSettle();

        final loginPage = LoginPage(tester);
        final forgotPasswordPage = ForgotPasswordPage(tester);

        expect(find.byType(LoginScreen), findsOneWidget);

        // Нажатие "Забыли пароль?"
        await loginPage.tapForgotPassword();
        await tester.pumpAndSettle(const Duration(seconds: 1));

        // Открытие ForgotPasswordScreen
        expect(find.byType(ForgotPasswordScreen), findsOneWidget);
        await forgotPasswordPage.expectStep1Visible();
      },
    );

    testWidgets(
      'ForgotPasswordScreen - "Назад ко входу" - LoginScreen',
      (WidgetTester tester) async {
        app.main();
        await tester.pumpAndSettle();

        final loginPage = LoginPage(tester);
        final forgotPasswordPage = ForgotPasswordPage(tester);

        // Переход на ForgotPasswordScreen
        await loginPage.tapForgotPassword();
        await tester.pumpAndSettle();
        expect(find.byType(ForgotPasswordScreen), findsOneWidget);

        // Нажатие "Назад ко входу"
        await forgotPasswordPage.tapBackToLogin();
        await tester.pumpAndSettle();

        // Возвращение на LoginScreen
        expect(find.byType(LoginScreen), findsOneWidget);
        await loginPage.expectAllElementsVisible();
      },
    );
  });
}
