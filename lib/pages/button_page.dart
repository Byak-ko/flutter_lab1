import 'package:flutter/material.dart';

import '../widgets/painted_button/painted_button.dart';

class ButtonPage extends StatefulWidget {
  const ButtonPage({super.key});

  @override
  State<ButtonPage> createState() => _ButtonPageState();
}

class _ButtonPageState extends State<ButtonPage> {
  int _clicks = 0;
  String _last = '—';
  bool _enabled = true;

  void _press(String name) => setState(() {
    _clicks++;
    _last = name;
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Лаба 4: компонент Button'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text('Натискань: $_clicks', style: textTheme.headlineSmall),
          Text('Остання кнопка: $_last'),
          const SizedBox(height: 24),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              PaintedButton(
                label: 'Primary',
                autofocus: true,
                onPressed: _enabled ? () => _press('Primary') : null,
              ),
              PaintedButton(
                label: 'Зберегти',
                icon: Icons.save,
                style: PaintedButtonStyle.filled(const Color(0xFF2E7D32)),
                onPressed: _enabled ? () => _press('Зберегти') : null,
              ),
              PaintedButton(
                label: 'Outlined',
                style: PaintedButtonStyle.outlined(const Color(0xFF6750A4)),
                onPressed: _enabled ? () => _press('Outlined') : null,
              ),
              PaintedButton(
                label: 'Видалити',
                icon: Icons.delete_outline,
                style: PaintedButtonStyle.filled(
                  const Color(0xFFC62828),
                  radius: 4,
                ),
                onPressed: _enabled ? () => _press('Видалити') : null,
              ),
              PaintedButton(
                label: 'Велика кругла',
                style:
                    PaintedButtonStyle.filled(
                      const Color(0xFFFFB300),
                      radius: 32,
                    ).copyWith(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 22,
                      ),
                      textStyle: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                onPressed: _enabled ? () => _press('Велика кругла') : null,
              ),
              const PaintedButton(label: 'Завжди вимкнена', onPressed: null),
            ],
          ),
          const SizedBox(height: 24),
          SwitchListTile(
            title: const Text('Кнопки увімкнені'),
            value: _enabled,
            onChanged: (v) => setState(() => _enabled = v),
          ),
          const SizedBox(height: 8),
          Text(
            'Кнопки намальовані через CustomPainter: фон, тінь, рамка, '
            'хвиля натискання, фокус (Tab) і активація клавішами Enter/Space.',
            style: textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
