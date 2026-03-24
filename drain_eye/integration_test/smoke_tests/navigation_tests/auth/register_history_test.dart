import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:drain_eye/main.dart' as app;
import 'package:drain_eye/presentation/screens/auth/register_screen.dart';
import 'package:drain_eye/presentation/screens/user/history_screen.dart';
import 'package:drain_eye/presentation/screens/auth/login_screen.dart';
import 'package:drain_eye/presentation/screens/user/main_screen.dart';
import '../../../pages/login_page.dart';
import '../../../pages/register_page.dart';
import '../../../pages/history_page.dart';

/// Тесты навигации между RegisterScreen и HistoryScreen
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Тесты: RegisterScreen и HistoryScreen', () {
    testWidgets('RegisterScreen - "Создать аккаунт" - HistoryScreen', skip: true, (
      WidgetTester tester,
    ) async {
      app.main();
      await tester.pumpAndSettle();

      final loginPage = LoginPage(tester);
      final registerPage = RegisterPage(tester);
      final historyPage = HistoryPage(tester);

      // Переход на RegisterScreen
      await loginPage.tapRegister();
      await tester.pumpAndSettle();
      expect(find.byType(RegisterScreen), findsOneWidget);

      await registerPage.completeRegistration(
        'Test User',
        'test@example.com',
        'Password123',
      );
      await tester.pumpAndSettle();

      // Открытие HistoryScreen
      expect(find.byType(MainScreen), findsOneWidget);
      await historyPage.expectTitleVisible();
    });
  });
}
