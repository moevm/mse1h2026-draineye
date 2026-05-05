import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'base_page.dart';

/// PageObject для административной панели (AdminMainScreen)
class AdminPage extends BasePage {
  AdminPage(WidgetTester tester) : super(tester);

  // Вкладки нижней навигации (BottomNavigationBar)
  Finder get tabDashboard => find.text('Главная');
  Finder get tabUsers => find.text('Пользователи');
  Finder get tabInspections => find.text('Инспекции');
  Finder get tabSettings => find.text('Настройки');

  // Заголовки AppBar для каждой вкладки
  Finder get appBarTitleDashboard => find.text('Панель управления');
  Finder get appBarTitleUsers => find.text('Пользователи');
  Finder get appBarTitleInspections => find.text('Инспекции');
  Finder get appBarTitleSettings => find.text('Настройки');

  // Кнопка выхода в AppBar
  Finder get logoutAppBarButton => find.byIcon(Icons.logout);
  Finder get logoutAppBarTooltip => find.byTooltip('Выйти');

  // Якоря для вкладки "Главная"
  Finder get dashboardSystemOverviewTitle => find.text('Обзор системы');
  Finder get dashboardLastActionsTitle => find.text('Последние действия');

  // Якоря для вкладки "Пользователи"
  Finder get usersAllUsersTitle => find.text('Все пользователи');
  Finder get adminRoleChip => find.text('Администратор');
  Finder get adminEmailText => find.text('admin@draineye.com');

  // Якоря для вкладки "Инспекции"
  Finder get inspectionsAllTitle => find.text('Все инспекции');
  Finder get inspectionsCountText => find.textContaining('записей'); // Например, "5 записей"
  Finder get inspectionStatusOnReview => find.text('На проверке');
  Finder get inspectionStatusDone => find.text('Завершена');
  Finder get inspectionStatusRejected => find.text('Отклонена');

  // Якоря для вкладки "Настройки"
  Finder get settingsSectionSystem => find.text('Система');
  Finder get settingsSectionNotifications => find.text('Уведомления');
  Finder get settingsSectionSecurity => find.text('Безопасность');
  Finder get logoutSettingsButton => find.text('Выйти из аккаунта');

  // Действия
  /// Переключение на "Главная"
  Future<void> tapDashboardTab() async => tap(tabDashboard);

  /// Переключение на "Пользователи"
  Future<void> tapUsersTab() async => tap(tabUsers);

  /// Переключение на "Инспекции"
  Future<void> tapInspectionsTab() async => tap(tabInspections);

  /// Переключение на "Настройки"
  Future<void> tapSettingsTab() async => tap(tabSettings);

  /// Выход из системы через кнопку в AppBar (Icons.logout)
  Future<void> tapLogoutAppBar() async => tap(logoutAppBarButton);

  /// Выход из системы через кнопку в настройках: "Выйти из аккаунта"
  Future<void> tapLogoutSettings() async => tap(logoutSettingsButton);

  /// Прокрутка вниp
  Future<void> scrollDown({double offset = 400}) async {
    await tester.fling(
      find.byType(Scaffold),
      Offset(0, -offset),
      1200,
    );
    await tester.pumpAndSettle();
  }

  /// Прокрутка вверх
  Future<void> scrollUp({double offset = 400}) async {
    await tester.fling(
      find.byType(Scaffold),
      Offset(0, offset),
      1200,
    );
    await tester.pumpAndSettle();
  }

  // Проверки видимости
  /// Проверяет видимость всех элементов нижней навигации
  Future<void> expectBottomNavVisible() async {
    await expectVisible(tabDashboard);
    await expectVisible(tabUsers);
    await expectVisible(tabInspections);
    await expectVisible(tabSettings);
  }

  /// Проверяет видимость "Главная"
  Future<void> expectDashboardVisible() async {
    await expectVisible(appBarTitleDashboard);
    await expectVisible(dashboardSystemOverviewTitle);
    await expectVisible(dashboardLastActionsTitle);
  }

  /// Проверяет видимость "Пользователи"
  Future<void> expectUsersVisible() async {
    await expectVisible(appBarTitleUsers);
    await expectVisible(usersAllUsersTitle);
  }

  /// Проверяет видимость "Инспекции"
  Future<void> expectInspectionsVisible() async {
    await expectVisible(appBarTitleInspections);
    await expectVisible(inspectionsAllTitle);
    await expectVisible(inspectionsCountText);
  }

  /// Проверяет видимость "Настройки"
  Future<void> expectSettingsVisible() async {
    await expectVisible(appBarTitleSettings);
    await expectVisible(settingsSectionSystem);
    await expectVisible(settingsSectionNotifications);
    await expectVisible(settingsSectionSecurity);
    await expectVisible(logoutSettingsButton);
  }

  /// Проверяет видимость кнопки выхода в AppBar
  Future<void> expectLogoutAppBarVisible() async {
    await expectVisible(logoutAppBarButton);
    await expectVisible(logoutAppBarTooltip);
  }
}