import 'package:flutter/material.dart';

import '../widgets/tristate_checkbox.dart';

class CheckboxPage extends StatefulWidget {
  const CheckboxPage({super.key});

  @override
  State<CheckboxPage> createState() => _CheckboxPageState();
}

class _CheckboxPageState extends State<CheckboxPage> {
  final _toppings = CheckboxNode(
    'Усі інгредієнти',
    children: [
      CheckboxNode('Сир', checked: true),
      CheckboxNode('Гриби'),
      CheckboxNode('Оливки'),
      CheckboxNode('Бекон', checked: true),
    ],
  );

  final _notifications = CheckboxNode(
    'Усі сповіщення',
    children: [
      CheckboxNode(
        'Email',
        children: [
          CheckboxNode('Новини', checked: true),
          CheckboxNode('Акції'),
        ],
      ),
      CheckboxNode(
        'Push',
        children: [
          CheckboxNode('Повідомлення', checked: true),
          CheckboxNode('Нагадування', checked: true),
        ],
      ),
    ],
  );

  @override
  void dispose() {
    _toppings.dispose();
    _notifications.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Чекбокси'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _Section(title: 'Піца', root: _toppings),
          const SizedBox(height: 16),
          _Section(title: 'Сповіщення', root: _notifications),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.root});

  final String title;
  final CheckboxNode root;

  String get _summary {
    final selected = root.checkedLeaves.map((n) => n.label).toList();
    return selected.isEmpty
        ? 'Нічого не обрано'
        : 'Обрано: ${selected.join(', ')}';
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(title, style: textTheme.titleMedium),
            ),
            TriStateCheckboxTree(root: root),
            ListenableBuilder(
              listenable: root,
              builder: (context, _) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(_summary, style: textTheme.bodySmall),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
