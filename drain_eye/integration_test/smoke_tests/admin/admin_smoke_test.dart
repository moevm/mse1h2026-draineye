import 'package:drain_eye/presentation/screens/admin/admin_main_screen.dart';
import 'package:drain_eye/presentation/screens/auth/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import '../../pages/admin_page.dart';

/// Интеграционные дымовые тесты административной панели
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Smoke тесты для AdminMainScreen', () {
    Future<void> pumpAdminApp(WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          debugShowCheckedModeBanner: false,
          home: AdminMainScreen(),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('Smoke: отображается панель управления и нижняя навигация', (tester) async {
      await pumpAdminApp(tester);

      final adminPage = AdminPage(tester);

      await adminPage.expectBottomNavVisible();
      await adminPage.expectLogoutAppBarVisible();
      await adminPage.expectDashboardVisible();
    });

    testWidgets('Навигация: переключение вкладок и проверка якорей', (tester) async {
      await pumpAdminApp(tester);

      final adminPage = AdminPage(tester);

      // Пользователи
      await adminPage.tapUsersTab();
      await adminPage.expectUsersVisible();

      // Инспекции
      await adminPage.tapInspectionsTab();
      await adminPage.expectInspectionsVisible();

      // Настройки
      await adminPage.tapSettingsTab();
      await adminPage.expectSettingsVisible();

      // Панель управления
      await adminPage.tapDashboardTab();
      await adminPage.expectDashboardVisible();
    });

    testWidgets('Прокрутка: просмотр панели управления', (tester) async {
      await pumpAdminApp(tester);

      final adminPage = AdminPage(tester);

      await adminPage.expectDashboardVisible();
      await adminPage.scrollDown();
      await adminPage.scrollUp();

      expect(adminPage.dashboardSystemOverviewTitle, findsOneWidget);
    });

    testWidgets('Выход: кнопка выхода в AppBar перенаправляет на LoginScreen', (tester) async {
      await pumpAdminApp(tester);

      final adminPage = AdminPage(tester);

      await adminPage.expectLogoutAppBarVisible();
      await adminPage.tapLogoutAppBar();

      expect(find.byType(LoginScreen), findsOneWidget);

      await tester.pageBack();
      await tester.pumpAndSettle();

      expect(find.byType(LoginScreen), findsOneWidget);
      expect(find.byType(AdminMainScreen), findsNothing);
    });

    testWidgets('Выход: кнопка выхода в настройках перенаправляет на LoginScreen', (tester) async {
      await pumpAdminApp(tester);

      final adminPage = AdminPage(tester);

      await adminPage.tapSettingsTab();
      await adminPage.expectSettingsVisible();

      await adminPage.tapLogoutSettings();

      expect(find.byType(LoginScreen), findsOneWidget);

      await tester.pageBack();
      await tester.pumpAndSettle();

      expect(find.byType(LoginScreen), findsOneWidget);
      expect(find.byType(AdminMainScreen), findsNothing);
    });
  });
}