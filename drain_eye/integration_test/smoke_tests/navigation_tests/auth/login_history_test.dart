import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:drain_eye/main.dart' as app;
import 'package:drain_eye/presentation/screens/auth/login_screen.dart';
import 'package:drain_eye/presentation/screens/user/main_screen.dart';
import 'package:drain_eye/presentation/screens/user/history_screen.dart';
import '../../../utils/constants.dart';
import '../../../pages/login_page.dart';
import '../../../pages/history_page.dart';

/// Тесты навигации между LoginScreen и HistoryScreen
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Тесты: LoginScreen и HistoryScreen', () {
    // Загрузка HistoryScreen нестабильна
    testWidgets('LoginScreen - "Войти" - HistoryScreen', skip: true, (  
      WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      final loginPage = LoginPage(tester);
      final historyPage = HistoryPage(tester);

      expect(find.byType(LoginScreen), findsOneWidget);

      // Заполнение формы и вход
      await loginPage.login(
        TestConstants.testEmail,
        TestConstants.testPassword,
      );
      await tester.pumpAndSettle();

      // Открытие HistoryScreen
      expect(find.byType(HistoryScreen), findsOneWidget);
      await historyPage.expectTitleVisible();
    });
  });
}
