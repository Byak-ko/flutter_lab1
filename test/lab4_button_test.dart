import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_lab1/widgets/painted_button/painted_button.dart';
import 'package:flutter_lab1/widgets/painted_button/painted_button_painter.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrap(Widget child) => MaterialApp(
  home: Scaffold(body: Center(child: child)),
);

PaintedButtonPainter _painterOf(WidgetTester tester) => tester
    .widgetList<CustomPaint>(
      find.descendant(
        of: find.byType(PaintedButton),
        matching: find.byType(CustomPaint),
      ),
    )
    .map((p) => p.painter)
    .whereType<PaintedButtonPainter>()
    .single;

void main() {
  testWidgets('tap calls onPressed', (tester) async {
    var taps = 0;
    await tester.pumpWidget(
      _wrap(PaintedButton(label: 'OK', onPressed: () => taps++)),
    );
    await tester.tap(find.byType(PaintedButton));
    await tester.pumpAndSettle();
    expect(taps, 1);
  });

  testWidgets('disabled button ignores taps and paints disabled', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(const PaintedButton(label: 'Off', onPressed: null)),
    );
    await tester.tap(find.byType(PaintedButton), warnIfMissed: false);
    await tester.pump();
    expect(_painterOf(tester).status.enabled, isFalse);
  });

  testWidgets('pressed state is shown while finger is down', (tester) async {
    await tester.pumpWidget(
      _wrap(PaintedButton(label: 'Hold', onPressed: () {})),
    );
    final gesture = await tester.startGesture(
      tester.getCenter(find.byType(PaintedButton)),
    );
    await tester.pump(const Duration(milliseconds: 150));
    await tester.pump(const Duration(milliseconds: 50));
    expect(_painterOf(tester).status.pressed, isTrue);
    expect(_painterOf(tester).rippleProgress, greaterThan(0));
    await gesture.up();
    await tester.pumpAndSettle();
    expect(_painterOf(tester).status.pressed, isFalse);
  });

  testWidgets('Enter and Space activate a focused button', (tester) async {
    var taps = 0;
    await tester.pumpWidget(
      _wrap(
        PaintedButton(label: 'Key', autofocus: true, onPressed: () => taps++),
      ),
    );
    await tester.pump();

    await tester.tap(find.byType(PaintedButton));
    await tester.pumpAndSettle();
    expect(_painterOf(tester).status.focused, isFalse);

    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.sendKeyEvent(LogicalKeyboardKey.space);
    await tester.pumpAndSettle();
    expect(_painterOf(tester).status.focused, isTrue);
    expect(taps, 3);
  });

  testWidgets('size grows with label and exposes button semantics', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(
      _wrap(
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            PaintedButton(label: 'A', onPressed: () {}),
            PaintedButton(label: 'A much longer label', onPressed: () {}),
          ],
        ),
      ),
    );
    final sizes = tester
        .widgetList<CustomPaint>(find.byType(CustomPaint))
        .where((p) => p.painter is PaintedButtonPainter)
        .map((p) => p.size.width)
        .toList();
    expect(sizes.last, greaterThan(sizes.first));
    expect(sizes.first, greaterThanOrEqualTo(64));

    expect(
      tester.getSemantics(find.byType(PaintedButton).first),
      matchesSemantics(
        label: 'A',
        isButton: true,
        hasEnabledState: true,
        isEnabled: true,
        hasTapAction: true,
        isFocusable: true,
      ),
    );
    handle.dispose();
  });

  test('style darkens on press and lifts on hover', () {
    final style = PaintedButtonStyle.filled(const Color(0xFF6750A4));
    const idle = PaintedButtonStatus();
    const pressed = PaintedButtonStatus(pressed: true);
    const hovered = PaintedButtonStatus(hovered: true);
    expect(
      style.backgroundFor(pressed).computeLuminance(),
      lessThan(style.backgroundFor(idle).computeLuminance()),
    );
    expect(style.elevationFor(hovered), greaterThan(style.elevationFor(idle)));
    expect(style.elevationFor(pressed), lessThan(style.elevationFor(idle)));
    expect(style.foreground, const Color(0xFFFFFFFF));
  });
}
