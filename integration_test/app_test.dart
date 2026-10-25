import 'package:flutter/material.dart';
import 'package:flutter_lab1/main.dart';
import 'package:flutter_lab1/pages/lists_page.dart';
import 'package:flutter_lab1/widgets/painted_button/painted_button.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

Future<void> _waitFor(WidgetTester tester, Finder finder) async {
  for (var i = 0; i < 150 && finder.evaluate().isEmpty; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
  expect(finder, findsWidgets);
}

Finder _painted(String label) =>
    find.byWidgetPredicate((w) => w is PaintedButton && w.label == label);

Future<void> _openLab(WidgetTester tester, String title) async {
  await tester.tap(find.byTooltip('Open navigation menu'));
  await tester.pumpAndSettle();
  await tester.tap(find.text(title));
  await tester.pumpAndSettle();
}

Future<void> _back(WidgetTester tester) async {
  await tester.pageBack();
  await tester.pumpAndSettle();
  expect(find.byType(MyHomePage), findsOneWidget);
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('all labs work end-to-end', (tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    expect(find.byType(SecondPage), findsOneWidget);
    await tester.tap(find.text('Back'));
    await tester.pumpAndSettle();
    expect(find.byType(MyHomePage), findsOneWidget);

    await _openLab(tester, 'Списки');
    await _waitFor(tester, find.byType(PostTile));
    expect(find.byType(UserHeaderTile), findsWidgets);
    final firstStar = find.descendant(
      of: find.byType(PostTile).first,
      matching: find.byType(IconButton),
    );
    await tester.tap(firstStar);
    await tester.pumpAndSettle();
    final favoriteBefore = tester
        .widget<PostTile>(find.byType(PostTile).first)
        .post
        .isFavorite;
    await _back(tester);

    await _openLab(tester, 'Списки');
    await _waitFor(tester, find.byType(PostTile));
    expect(
      tester.widget<PostTile>(find.byType(PostTile).first).post.isFavorite,
      favoriteBefore,
      reason: 'позначка має прочитатись з локальної БД',
    );
    await tester.tap(firstStar);
    await tester.pumpAndSettle();
    await _back(tester);

    await _openLab(tester, 'Чекбокси');
    Checkbox box(String label) => tester.widget<Checkbox>(
      find.descendant(
        of: find.widgetWithText(CheckboxListTile, label),
        matching: find.byType(Checkbox),
      ),
    );
    expect(box('Усі інгредієнти').value, isNull);
    await tester.tap(find.text('Усі інгредієнти'));
    await tester.pumpAndSettle();
    expect(box('Усі інгредієнти').value, isTrue);
    expect(box('Гриби').value, isTrue);
    await _back(tester);

    await _openLab(tester, 'Кнопки');
    await tester.tap(_painted('Надіслати'));
    await tester.tap(_painted('Зберегти'));
    await tester.tap(_painted('Недоступно'), warnIfMissed: false);
    await tester.pumpAndSettle();
    expect(find.text('Натискань: 2'), findsOneWidget);
  });
}
