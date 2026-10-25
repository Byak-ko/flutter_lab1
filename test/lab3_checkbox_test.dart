import 'package:flutter/material.dart';
import 'package:flutter_lab1/widgets/tristate_checkbox.dart';
import 'package:flutter_test/flutter_test.dart';

CheckboxNode _group({List<bool> checked = const [false, false, false]}) =>
    CheckboxNode(
      'All',
      children: [
        for (var i = 0; i < checked.length; i++)
          CheckboxNode('Item $i', checked: checked[i]),
      ],
    );

void main() {
  group('CheckboxNode', () {
    test('group state follows children: false / null / true', () {
      expect(_group().value, isFalse);
      expect(_group(checked: [true, false, true]).value, isNull);
      expect(_group(checked: [true, true, true]).value, isTrue);
    });

    test('toggling a partial group checks all children', () {
      final root = _group(checked: [true, false, false]);
      root.toggle();
      expect(root.value, isTrue);
      expect(root.children.every((c) => c.value == true), isTrue);
    });

    test('toggling a checked group unchecks all children', () {
      final root = _group(checked: [true, true, true]);
      root.toggle();
      expect(root.value, isFalse);
      expect(root.checkedLeaves, isEmpty);
    });

    test('changing a child updates parent and notifies it', () {
      final root = _group();
      var notified = 0;
      root.addListener(() => notified++);
      root.children[1].setValue(true);
      expect(root.value, isNull);
      expect(notified, 1);
    });

    test('nested groups propagate state through several levels', () {
      final a = CheckboxNode(
        'A',
        children: [CheckboxNode('a1'), CheckboxNode('a2')],
      );
      final b = CheckboxNode('B', children: [CheckboxNode('b1')]);
      final root = CheckboxNode('Root', children: [a, b]);

      a.children.first.setValue(true);
      expect(a.value, isNull);
      expect(root.value, isNull);

      a.toggle();
      b.toggle();
      expect(root.value, isTrue);

      root.toggle();
      expect(root.leaves.every((l) => l.value == false), isTrue);
    });
  });

  testWidgets('tapping children drives the parent checkbox through 3 states', (
    tester,
  ) async {
    final root = _group(checked: [false, false]);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: TriStateCheckboxTree(root: root)),
      ),
    );

    Checkbox parentBox() =>
        tester.widgetList<Checkbox>(find.byType(Checkbox)).first;

    expect(parentBox().value, isFalse);

    await tester.tap(find.text('Item 0'));
    await tester.pump();
    expect(parentBox().value, isNull);

    await tester.tap(find.text('Item 1'));
    await tester.pump();
    expect(parentBox().value, isTrue);

    await tester.tap(find.text('All'));
    await tester.pump();
    expect(parentBox().value, isFalse);
    expect(
      tester.widgetList<Checkbox>(find.byType(Checkbox)).map((c) => c.value),
      everyElement(isFalse),
    );
  });
}
