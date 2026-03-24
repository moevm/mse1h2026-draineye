import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../utils/constants.dart';
import 'base_page.dart';

/// PageObject для экрана регистрации (RegisterScreen)
class RegisterPage extends BasePage {
  RegisterPage(WidgetTester tester) : super(tester);

  // Поиск
  /// Поле ввода Имя
  Finder get nameField => find.byType(TextField).at(0);

  /// Поле ввода Email
  Finder get emailField => find.byType(TextField).at(1);

  /// Поле ввода Пароль
  Finder get passwordField => find.byType(TextField).at(2);

  /// Поле ввода Повтор пароля
  Finder get repeatPasswordField => find.byType(TextField).at(3);

  /// Кнопка "Создать аккаунт"
  Finder get createAccountButton =>
      find.text(TestConstants.createAccountButtonText);

  /// Ссылка "Войти"
  Finder get loginLink => find.text(TestConstants.loginLinkText);

  /// Заголовок экрана
  Finder get title => find.text(TestConstants.registrationTitle);

  /// Подзаголовок экрана
  Finder get subtitle => find.text(TestConstants.registrationSubtitle);

  // Действия
  /// Ввод имени
  Future<void> enterName(String name) async {
    await enterText(nameField, name);
  }

  /// Ввод email
  Future<void> enterEmail(String email) async {
    await enterText(emailField, email);
  }

  /// Ввод пароля
  Future<void> enterPassword(String password) async {
    await enterText(passwordField, password);
  }

  /// Ввод повтор пароля
  Future<void> repeatPassword(String password) async {
    await enterText(repeatPasswordField, password);
  }

  /// Нажатие кнопки "Создать аккаунт"
  Future<void> tapCreateAccount() async {
    await tapText(TestConstants.createAccountButtonText);
  }

  /// Нажатие ссылки "Войти"
  Future<void> tapLoginLink() async {
    await tapText(TestConstants.loginLinkText);
  }

  /// Заполнение формы регистрации и создание аккаунта
  Future<void> completeRegistration(
    String name,
    String email,
    String password,
  ) async {
    await enterName(name);
    await enterEmail(email);
    await enterPassword(password);
    await repeatPassword(password);
    await tapCreateAccount();
  }

  /// Заполнение формы без отправки
  Future<void> fillRegistrationForm(
    String name,
    String email,
    String password,
  ) async {
    await enterName(name);
    await enterEmail(email);
    await enterPassword(password);
    await repeatPassword(password);
  }

  // Ожидаемое состояние
  /// Проверяет видимость всех полей формы
  Future<void> expectAllFieldsVisible() async {
    await expectVisible(nameField);
    await expectVisible(emailField);
    await expectVisible(passwordField);
    await expectVisible(repeatPasswordField);
  }

  /// Проверяет видимость заголовков
  Future<void> expectHeadersVisible() async {
    await expectVisible(title);
    await expectVisible(subtitle);
  }

  /// Проверяет видимость всех элементов
  Future<void> expectAllElementsVisible() async {
    await expectHeadersVisible();
    await expectAllFieldsVisible();
    await expectVisible(createAccountButton);
    await expectVisible(loginLink);
  }
}
