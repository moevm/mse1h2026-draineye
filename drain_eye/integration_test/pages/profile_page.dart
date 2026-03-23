import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../utils/constants.dart';
import 'base_page.dart';

/// PageObject для страницы профиля (ProfilePage)
class ProfilePage extends BasePage {
  ProfilePage(WidgetTester tester) : super(tester);

  // Поиск
  /// Заголовок страницы
  Finder get pageTitle => find.text(TestConstants.profilePageTitle);

  /// Кнопка назад
  Finder get backButton => find.byIcon(Icons.arrow_back);

  /// Имя пользователя
  Finder get userName => find.text(TestConstants.testName);

  /// Email пользователя
  Finder get userEmail => find.text(TestConstants.testEmail);

  /// Статус пользователя
  Finder get userStatus => find.text(TestConstants.userStatusText);

  /// Кнопка выхода
  Finder get logoutButton => find.text(TestConstants.logoutButtonText);

  /// Раздел с информацией о пользователе
  Finder get infoSection => find.text(TestConstants.userInfoLabel);

  /// Роль пользователя
  Finder get userRole => find.text(TestConstants.roleText);

  // Действия
  /// Нажатие кнопки назад
  Future<void> tapBack() async {
    await tap(backButton);
  }

  /// Нажатие кнопки "Выйти"
  Future<void> tapLogout() async {
    await tapText(TestConstants.logoutButtonText);
  }

  // Ожидаемое состояние
  /// Проверяет видимость заголовка
  Future<void> expectTitleVisible() async {
    await expectVisible(pageTitle);
  }

  /// Проверяет видимость информации профиля
  Future<void> expectUserInfoVisible() async {
    await expectVisible(userName);
    await expectVisible(userEmail);
    await expectVisible(userStatus);
  }


  /// Проверяет видимость кнопки выхода
  Future<void> expectLogoutButtonVisible() async {
    await expectVisible(logoutButton);
  }

  /// Проверяет видимость всех элементов профиля
  Future<void> expectAllElementsVisible() async {
    await expectTitleVisible();
    await expectUserInfoVisible();
  }
}
