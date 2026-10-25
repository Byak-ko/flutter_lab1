import 'package:flutter/material.dart';

import '../widgets/painted_button/painted_button.dart';

class ButtonPage extends StatefulWidget {
  const ButtonPage({super.key});

  @override
  State<ButtonPage> createState() => _ButtonPageState();
}

class _ButtonPageState extends State<ButtonPage> {
  int _clicks = 0;
  bool _enabled = true;

  VoidCallback? get _onPressed =>
      _enabled ? () => setState(() => _clicks++) : null;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Кнопки'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            'Натискань: $_clicks',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              PaintedButton(
                label: 'Надіслати',
                autofocus: true,
                style: PaintedButtonStyle.filled(primary),
                onPressed: _onPressed,
              ),
              PaintedButton(
                label: 'Зберегти',
                icon: Icons.save,
                style: PaintedButtonStyle.filled(const Color(0xFF2E7D32)),
                onPressed: _onPressed,
              ),
              PaintedButton(
                label: 'Скасувати',
                style: PaintedButtonStyle.outlined(primary),
                onPressed: _onPressed,
              ),
              PaintedButton(
                label: 'Видалити',
                icon: Icons.delete_outline,
                style: PaintedButtonStyle.filled(
                  const Color(0xFFC62828),
                  radius: 4,
                ),
                onPressed: _onPressed,
              ),
              PaintedButton(
                label: 'Купити',
                icon: Icons.shopping_cart,
                style: PaintedButtonStyle.filled(primary, radius: 28).copyWith(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 36,
                    vertical: 18,
                  ),
                  textStyle: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onPressed: _onPressed,
              ),
              const PaintedButton(label: 'Недоступно', onPressed: null),
            ],
          ),
          const SizedBox(height: 24),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Кнопки активні'),
            value: _enabled,
            onChanged: (v) => setState(() => _enabled = v),
          ),
        ],
      ),
    );
  }
}
