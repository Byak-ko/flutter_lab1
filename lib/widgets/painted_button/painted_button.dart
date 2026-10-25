import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'painted_button_painter.dart';
import 'painted_button_style.dart';

export 'painted_button_style.dart';

class PaintedButton extends StatefulWidget {
  const PaintedButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.style,
    this.minSize = const Size(64, 40),
    this.autofocus = false,
  });

  final String label;

  final VoidCallback? onPressed;
  final IconData? icon;
  final PaintedButtonStyle? style;
  final Size minSize;
  final bool autofocus;

  bool get enabled => onPressed != null;

  static const PaintedButtonStyle defaultStyle = PaintedButtonStyle(
    background: Color(0xFF6750A4),
    foreground: Color(0xFFFFFFFF),
  );

  @override
  State<PaintedButton> createState() => _PaintedButtonState();
}

class _PaintedButtonState extends State<PaintedButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ripple = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 400),
  );
  final FocusNode _focusNode = FocusNode(debugLabel: 'PaintedButton');

  bool _hovered = false;
  bool _pressed = false;
  bool _focused = false;
  Offset? _rippleCenter;

  PaintedButtonContent? _content;
  Object? _contentKey;

  PaintedButtonStyle get _style => widget.style ?? PaintedButton.defaultStyle;

  PaintedButtonStatus get _status => PaintedButtonStatus(
    enabled: widget.enabled,
    hovered: _hovered,
    pressed: _pressed,
    focused:
        _focused &&
        FocusManager.instance.highlightMode == FocusHighlightMode.traditional,
  );

  @override
  void initState() {
    super.initState();
    FocusManager.instance.addHighlightModeListener(_onHighlightModeChanged);
  }

  void _onHighlightModeChanged(FocusHighlightMode _) => setState(() {});

  @override
  void didUpdateWidget(PaintedButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.enabled) {
      _hovered = false;
      _pressed = false;
    }
  }

  @override
  void dispose() {
    FocusManager.instance.removeHighlightModeListener(_onHighlightModeChanged);
    _ripple.dispose();
    _focusNode.dispose();
    _content?.dispose();
    super.dispose();
  }

  void _activate() {
    if (!widget.enabled) return;
    widget.onPressed!();
  }

  void _startRipple(Offset center) {
    _rippleCenter = center;
    _ripple.forward(from: 0);
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (!widget.enabled) return KeyEventResult.ignored;
    final key = event.logicalKey;
    if (key != LogicalKeyboardKey.enter &&
        key != LogicalKeyboardKey.numpadEnter &&
        key != LogicalKeyboardKey.space) {
      return KeyEventResult.ignored;
    }
    if (event is KeyDownEvent) {
      setState(() => _pressed = true);
    } else if (event is KeyUpEvent) {
      setState(() => _pressed = false);
      final box = context.findRenderObject() as RenderBox?;
      if (box != null) _startRipple(box.size.center(Offset.zero));
      _activate();
    }
    return KeyEventResult.handled;
  }

  PaintedButtonContent _obtainContent(BuildContext context) {
    final direction = Directionality.of(context);
    final scaler = MediaQuery.textScalerOf(context);
    final key = (
      widget.label,
      widget.icon,
      _style.textStyle,
      direction,
      scaler,
    );
    if (_content == null || key != _contentKey) {
      _content?.dispose();
      _contentKey = key;
      _content = PaintedButtonContent(
        label: widget.label,
        icon: widget.icon,
        textStyle: _style.textStyle,
        textDirection: direction,
        textScaler: scaler,
      );
    }
    return _content!;
  }

  @override
  Widget build(BuildContext context) {
    final content = _obtainContent(context);
    final inner = content.size;
    final size = Size(
      (inner.width + _style.padding.horizontal).clamp(
        widget.minSize.width,
        double.infinity,
      ),
      (inner.height + _style.padding.vertical).clamp(
        widget.minSize.height,
        double.infinity,
      ),
    );
    final enabled = widget.enabled;

    return Semantics(
      button: true,
      enabled: enabled,
      label: widget.label,
      onTap: enabled ? _activate : null,
      focusable: enabled,
      focused: _focused,
      child: Focus(
        focusNode: _focusNode,
        includeSemantics: false,
        autofocus: widget.autofocus,
        canRequestFocus: enabled,
        onFocusChange: (f) => setState(() => _focused = f),
        onKeyEvent: _onKey,
        child: MouseRegion(
          cursor: enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
          onEnter: (_) => setState(() => _hovered = enabled),
          onExit: (_) => setState(() => _hovered = false),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapDown: enabled
                ? (d) {
                    setState(() => _pressed = true);
                    _startRipple(d.localPosition);
                  }
                : null,
            onTapUp: enabled ? (_) => setState(() => _pressed = false) : null,
            onTapCancel: enabled
                ? () => setState(() => _pressed = false)
                : null,
            onTap: enabled ? _activate : null,
            child: AnimatedBuilder(
              animation: _ripple,
              builder: (context, _) => CustomPaint(
                size: size,
                painter: PaintedButtonPainter(
                  style: _style,
                  status: _status,
                  content: content,
                  rippleCenter: _rippleCenter,
                  rippleProgress: _ripple.value,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
