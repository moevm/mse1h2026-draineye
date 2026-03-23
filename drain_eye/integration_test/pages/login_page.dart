import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../utils/constants.dart';
import 'base_page.dart';

/// Страница входа (LoginScreen)
class LoginPage extends BasePage {
  LoginPage(WidgetTester tester) : super(tester);

  // Поиск
  Finder get emailField => find.byType(TextField).at(0);
  Finder get passwordField => find.byType(TextField).at(1);
  Finder get loginButton => find.text(TestConstants.loginButtonText);
  Finder get forgotPasswordLink => find.text(TestConstants.forgotPasswordText);
  Finder get googleButton => find.text(TestConstants.googleAuthButtonText);
  Finder get registerLink => find.text(TestConstants.registerLinkText);
  Finder get logo => find.text(TestConstants.appName);
  Finder get subtitle => find.text(TestConstants.loginTitle);

  // Действия
  /// Ввод email
  Future<void> enterEmail(String email) async {
    await enterText(emailField, email);
  }

  /// Ввод пароля
  Future<void> enterPassword(String password) async {
    await enterText(passwordField, password);
  }

  /// Нажатие кнопки 'Войти'
  Future<void> tapLogin() async {
    await tapText(TestConstants.loginButtonText);
  }

  /// Нажатие ссылки 'Забыли пароль'
  Future<void> tapForgotPassword() async {
    await tapText(TestConstants.forgotPasswordText);
  }

  /// Нажатие кнопки 'Google'
  Future<void> tapGoogle() async {
    await tapText(TestConstants.googleAuthButtonText);
  }

  /// Нажатие ссылки 'Зарегистрироваться'
  Future<void> tapRegister() async {
    await tapText(TestConstants.registerLinkText);
  }

  /// Заполнение формы и вход
  Future<void> login(String email, String password) async {
    await enterEmail(email);
    await enterPassword(password);
    await tapLogin();
  }

  /// Заполнение формы без отправки
  Future<void> fillForm(String email, String password) async {
    await enterEmail(email);
    await enterPassword(password);
  }

  // Ожидаемое состояние
  /// Проверяет видимость всех элементов
  Future<void> expectAllElementsVisible() async {
    await expectVisible(emailField);
    await expectVisible(passwordField);
    await expectVisible(loginButton);
    await expectVisible(forgotPasswordLink);
    await expectVisible(googleButton);
    await expectVisible(registerLink);
  }

  /// Проверяет видимость формы
  Future<void> expectFormVisible() async {
    await expectVisible(emailField);
    await expectVisible(passwordField);
    await expectVisible(loginButton);
  }

  /// Проверяет видимость заголовков
  Future<void> expectHeadersVisible() async {
    await expectVisibleAtLeastOne(logo);
    await expectVisible(subtitle);
  }

  /// Проверяет видимость всех ссылок
  Future<void> expectLinksVisible() async {
    await expectVisible(forgotPasswordLink);
    await expectVisible(registerLink);
    await expectVisible(googleButton);
  }
}
