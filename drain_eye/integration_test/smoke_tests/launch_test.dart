import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:drain_eye/main.dart' as app;
import '../utils/constants.dart';
import '../pages/login_page.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Smoke тесты запуска приложения:', () {
    testWidgets('Приложение запускается без ошибок', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      expect(find.byType(app.MyApp), findsOneWidget);
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('Страница входа отображается', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      final page = LoginPage(tester);
      await page.expectHeadersVisible();
    });

    testWidgets('Страница входа содержит все элементы', (
      WidgetTester tester,
    ) async {
      app.main();
      await tester.pumpAndSettle();

      final page = LoginPage(tester);
      await page.expectAllElementsVisible();
    });
  });
}
