import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

@immutable
class PaintedButtonStatus {
  const PaintedButtonStatus({
    this.enabled = true,
    this.hovered = false,
    this.pressed = false,
    this.focused = false,
  });

  final bool enabled;
  final bool hovered;
  final bool pressed;
  final bool focused;

  @override
  bool operator ==(Object other) =>
      other is PaintedButtonStatus &&
      other.enabled == enabled &&
      other.hovered == hovered &&
      other.pressed == pressed &&
      other.focused == focused;

  @override
  int get hashCode => Object.hash(enabled, hovered, pressed, focused);
}

@immutable
class PaintedButtonStyle {
  const PaintedButtonStyle({
    required this.background,
    required this.foreground,
    this.borderColor,
    this.borderWidth = 0,
    this.radius = 12,
    this.elevation = 3,
    this.padding = const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
    this.textStyle = const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
    this.disabledBackground = const Color(0xFFE0E0E0),
    this.disabledForeground = const Color(0xFF9E9E9E),
    this.focusColor = const Color(0xFF1E88E5),
  });

  factory PaintedButtonStyle.filled(Color color, {double radius = 12}) =>
      PaintedButtonStyle(
        background: color,
        foreground: _onColor(color),
        radius: radius,
      );

  factory PaintedButtonStyle.outlined(Color color, {double radius = 12}) =>
      PaintedButtonStyle(
        background: const Color(0x00000000),
        foreground: color,
        borderColor: color,
        borderWidth: 1.5,
        radius: radius,
        elevation: 0,
        disabledBackground: const Color(0x00000000),
      );

  final Color background;
  final Color foreground;
  final Color? borderColor;
  final double borderWidth;
  final double radius;
  final double elevation;
  final EdgeInsets padding;
  final TextStyle textStyle;
  final Color disabledBackground;
  final Color disabledForeground;
  final Color focusColor;

  bool get _isTransparent => background.a == 0;

  Color backgroundFor(PaintedButtonStatus s) {
    if (!s.enabled) return disabledBackground;
    if (_isTransparent) {
      if (s.pressed) return foreground.withValues(alpha: 0.16);
      if (s.hovered) return foreground.withValues(alpha: 0.08);
      return background;
    }
    if (s.pressed) return _shade(background, -0.12);
    if (s.hovered) return _shade(background, 0.08);
    return background;
  }

  Color foregroundFor(PaintedButtonStatus s) =>
      s.enabled ? foreground : disabledForeground;

  Color? borderFor(PaintedButtonStatus s) => borderColor == null
      ? null
      : (s.enabled ? borderColor : disabledForeground);

  double elevationFor(PaintedButtonStatus s) {
    if (!s.enabled || elevation == 0) return 0;
    if (s.pressed) return elevation / 3;
    if (s.hovered) return elevation + 2;
    return elevation;
  }

  Color get rippleColor => foreground.withValues(alpha: 0.24);

  PaintedButtonStyle copyWith({
    Color? background,
    Color? foreground,
    double? radius,
    double? elevation,
    EdgeInsets? padding,
    TextStyle? textStyle,
  }) => PaintedButtonStyle(
    background: background ?? this.background,
    foreground: foreground ?? this.foreground,
    borderColor: borderColor,
    borderWidth: borderWidth,
    radius: radius ?? this.radius,
    elevation: elevation ?? this.elevation,
    padding: padding ?? this.padding,
    textStyle: textStyle ?? this.textStyle,
    disabledBackground: disabledBackground,
    disabledForeground: disabledForeground,
    focusColor: focusColor,
  );

  static Color _shade(Color color, double amount) {
    final hsl = HSLColor.fromColor(color);
    return hsl
        .withLightness((hsl.lightness + amount).clamp(0.0, 1.0))
        .toColor();
  }

  static Color _onColor(Color background) => background.computeLuminance() > 0.5
      ? const Color(0xFF000000)
      : const Color(0xFFFFFFFF);
}
