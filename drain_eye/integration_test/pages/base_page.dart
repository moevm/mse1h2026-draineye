import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Базовый класс для всех PageObjects
abstract class BasePage {
  final WidgetTester tester;

  BasePage(this.tester);

  Future<void> waitForPageLoad() async {
    await tester.pumpAndSettle();
  }

  Finder byKey(String key) => find.byKey(Key(key));

  // Действия
  Future<void> tap(Finder finder) async {
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }

  Future<void> tapText(String text) async {
    await tester.tap(find.text(text));
    await tester.pumpAndSettle();
  }

  Future<void> longPress(Finder finder) async {
    await tester.longPress(finder);
    await tester.pumpAndSettle();
  }

  Future<void> enterText(Finder finder, String text) async {
    await tester.enterText(finder, text);
    await tester.pumpAndSettle();
  }

  /// Очищает текстовое поле
  Future<void> clearText(Finder finder) async {
    await tester.tap(finder);
    await tester.pump();
    await tester.enterText(finder, '');
    await tester.pumpAndSettle();
  }

  // Ожидаемое состояниие
  Future<void> expectVisible(Finder finder) async {
    await tester.pumpAndSettle();
    expect(finder, findsOneWidget);
  }

  Future<void> expectNotVisible(Finder finder) async {
    await tester.pumpAndSettle();
    expect(finder, findsNothing);
  }

  Future<void> expectVisibleAtLeastOne(Finder finder) async {
    await tester.pumpAndSettle();
    expect(finder, findsWidgets);
  }

  Future<void> expectText(String text) async {
    await tester.pumpAndSettle();
    expect(find.text(text), findsOneWidget);
  }

  Future<void> waitFor(
    Finder finder, {
    Duration timeout = const Duration(seconds: 5),
  }) async {
    final end = DateTime.now().add(timeout);

    while (DateTime.now().isBefore(end)) {
      if (finder.evaluate().isNotEmpty) return;
      await tester.pump(const Duration(milliseconds: 100));
    }

    throw Exception("'Элемент не найден': $finder");
  }

  Future<void> waitAndExpect(
    Finder finder, {
    Duration timeout = const Duration(seconds: 5),
  }) async {
    await waitFor(finder, timeout: timeout);
    await expectVisible(finder);
  }

  // Прокрутка
  Future<void> scrollDown({int times = 5}) async {
    for (int i = 0; i < times; i++) {
      await tester.drag(
        find.byType(SingleChildScrollView),
        const Offset(0, -300),
      );
      await tester.pumpAndSettle();
    }
  }

  Future<void> scrollUp({int times = 5}) async {
    for (int i = 0; i < times; i++) {
      await tester.drag(
        find.byType(SingleChildScrollView),
        const Offset(0, 300),
      );
      await tester.pumpAndSettle();
    }
  }
}
