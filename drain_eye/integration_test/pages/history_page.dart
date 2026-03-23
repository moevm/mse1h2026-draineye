import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../utils/constants.dart';
import 'base_page.dart';

/// PageObject для страницы истории инспекций (HistoryPage)
class HistoryPage extends BasePage {
  HistoryPage(WidgetTester tester) : super(tester);

  // Поиск
  /// Заголовок страницы
  Finder get pageTitle => find.text(TestConstants.historyPageTitle);

  /// Кнопка назад
  Finder get backButton => find.byIcon(Icons.arrow_back);

  /// Сообщение об пустой истории
  Finder get emptyHistoryMessage =>
      find.text(TestConstants.emptyHistoryMessage);

  /// Элементы списка инспекций
  Finder get inspectionItems => find.byType(ListTile);

  /// Контейнер страницы
  Finder get pageContent => find.byType(SingleChildScrollView);

  // Действия
  /// Нажиматие кнопку назад
  Future<void> tapBack() async {
    await tap(backButton);
  }

  // Ожидаемое состояние
  /// Проверяет видимость заголовка
  Future<void> expectTitleVisible() async {
    await expectVisible(pageTitle);
  }

  /// Проверяет видимость содержимого
  Future<void> expectContentVisible() async {
    await expectVisible(pageContent);
  }

  /// Проверяет видимость пустого состояния
  Future<void> expectEmptyState() async {
    await expectVisible(emptyHistoryMessage);
  }
}
