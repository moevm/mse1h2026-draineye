import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../utils/constants.dart';
import 'base_page.dart';

/// PageObject для страницы восстановления пароля (forgot_password_screen)
class ForgotPasswordPage extends BasePage {
  ForgotPasswordPage(WidgetTester tester) : super(tester);

  // Поиск
  /// Email поле ввода
  Finder get emailField => find.byType(TextField).at(0);

  /// Кнопка "Отправить ссылку"
  Finder get sendLinkButton => find.text(TestConstants.sendLinkButtonText);

  /// Кнопка "Назад ко входу"
  Finder get backToLoginButton =>
      find.text(TestConstants.backToLoginButtonText);

  // Заголовок экрана
  Finder get title => find.text(TestConstants.forgotPasswordTitle);

  /// Подзаголовок экрана
  Finder get subtitle => find.text(TestConstants.forgotPasswordSubtitle);

  /// Поле 'Новый пароль'  (шаг 2)
  Finder get newPasswordField => find.byType(TextField).at(0);

  /// Поле 'Повтор пароля' (шаг 2)
  Finder get repeatPasswordField => find.byType(TextField).at(1);

  /// Заголовок 'Новый пароль' (шаг 2)
  Finder get step2Title => find.text(TestConstants.newPasswordTitle);

  /// Сообщение "Письмо отправлено"
  Finder get emailSentMessage => find.text(TestConstants.emailSentMessage);

  // Действия
  /// Ввод email
  Future<void> enterEmail(String email) async {
    await enterText(emailField, email);
  }

  /// Нажатие кнопки "Отправить ссылку"
  Future<void> tapSendLink() async {
    await tapText(TestConstants.sendLinkButtonText);
  }

  /// Нажатие кнопки "Назад ко входу"
  Future<void> tapBackToLogin() async {
    await tapText(TestConstants.backToLoginButtonText);
  }

  /// Нажатие кнопки "Отправить ссылку" второй раз (переход на шаг 2)
  Future<void> proceedToStep2() async {
    await tapSendLink();
  }

  /// Ввод нового пароля на шаге 2
  Future<void> enterNewPassword(String password) async {
    await enterText(newPasswordField, password);
  }

  /// Повторный ввод пароля на шаге 2
  Future<void> repeatPassword(String password) async {
    await enterText(repeatPasswordField, password);
  }

  // Ожидаемое состояние
  /// Проверяет видимость заголовка шага 1
  Future<void> expectStep1Visible() async {
    await expectVisible(title);
    await expectVisible(emailField);
    await expectVisible(sendLinkButton);
    await expectVisible(backToLoginButton);
  }

  /// Проверяет видимость сообщения об отправке
  Future<void> expectEmailSentMessageVisible() async {
    await expectVisible(emailSentMessage);
  }

  /// Проверяет видимость заголовка шага 2
  Future<void> expectStep2Visible() async {
    await expectVisible(step2Title);
  }
}
