import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../utils/constants.dart';
import 'base_page.dart';

/// PageObject для экрана съёмки (CameraScreen)
class CameraScreen extends BasePage {
  CameraScreen(WidgetTester tester) : super(tester);

  // Поиск
  /// Заголовок страницы
  Finder get pageTitle => find.text(TestConstants.cameraScreenTitle);

  /// Кнопка назад
  Finder get backButton => find.byIcon(Icons.arrow_back);

  // Действия
  /// Нажатие кнопки назад
  Future<void> tapBack() async {
    await tap(backButton);
  }

  // Ожидаемое состояние
  /// Проверяет видимость заголовка
  Future<void> expectTitleVisible() async {
    await expectVisible(pageTitle);
  }

}
