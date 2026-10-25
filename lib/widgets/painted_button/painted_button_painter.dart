import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import 'painted_button_style.dart';

class PaintedButtonContent {
  PaintedButtonContent({
    required String label,
    required IconData? icon,
    required TextStyle textStyle,
    required TextDirection textDirection,
    required TextScaler textScaler,
    this.gap = 8,
  }) : _label = TextPainter(
         text: TextSpan(text: label, style: textStyle),
         textDirection: textDirection,
         textScaler: textScaler,
         maxLines: 1,
       )..layout(),
       _icon = icon == null
           ? null
           : (TextPainter(
               text: TextSpan(
                 text: String.fromCharCode(icon.codePoint),
                 style: textStyle.copyWith(
                   fontFamily: icon.fontFamily,
                   package: icon.fontPackage,
                   fontSize: (textStyle.fontSize ?? 14) * 1.25,
                 ),
               ),
               textDirection: textDirection,
               textScaler: textScaler,
             )..layout());

  final TextPainter _label;
  final TextPainter? _icon;
  final double gap;

  Size get size {
    final icon = _icon;
    final width = _label.width + (icon == null ? 0 : icon.width + gap);
    final height = math.max(_label.height, icon?.height ?? 0);
    return Size(width, height);
  }

  void paint(Canvas canvas, Offset center, Color color) {
    final total = size;
    var x = center.dx - total.width / 2;
    final icon = _icon;
    if (icon != null) {
      _recolor(icon, color);
      icon.paint(canvas, Offset(x, center.dy - icon.height / 2));
      x += icon.width + gap;
    }
    _recolor(_label, color);
    _label.paint(canvas, Offset(x, center.dy - _label.height / 2));
  }

  static void _recolor(TextPainter painter, Color color) {
    final span = painter.text! as TextSpan;
    if (span.style?.color == color) return;
    painter
      ..text = TextSpan(
        text: span.text,
        style: span.style?.copyWith(color: color),
      )
      ..layout();
  }

  void dispose() {
    _label.dispose();
    _icon?.dispose();
  }
}

class PaintedButtonPainter extends CustomPainter {
  PaintedButtonPainter({
    required this.style,
    required this.status,
    required this.content,
    this.rippleCenter,
    this.rippleProgress = 0,
  });

  final PaintedButtonStyle style;
  final PaintedButtonStatus status;
  final PaintedButtonContent content;
  final Offset? rippleCenter;

  final double rippleProgress;

  @override
  void paint(Canvas canvas, Size size) {
    final rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(style.radius),
    );

    final elevation = style.elevationFor(status);
    if (elevation > 0) {
      canvas.drawShadow(
        Path()..addRRect(rrect),
        const Color(0xFF000000),
        elevation,
        false,
      );
    }

    canvas.drawRRect(rrect, Paint()..color = style.backgroundFor(status));

    final center = rippleCenter;
    if (center != null && rippleProgress > 0 && rippleProgress < 1) {
      final maxRadius = _farthestCorner(center, size);
      canvas.save();
      canvas.clipRRect(rrect);
      canvas.drawCircle(
        center,
        maxRadius * Curves.easeOut.transform(rippleProgress),
        Paint()
          ..color = style.rippleColor.withValues(
            alpha: style.rippleColor.a * (1 - rippleProgress),
          ),
      );
      canvas.restore();
    }

    final border = style.borderFor(status);
    if (border != null && style.borderWidth > 0) {
      canvas.drawRRect(
        rrect.deflate(style.borderWidth / 2),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = style.borderWidth
          ..color = border,
      );
    }

    if (status.focused && status.enabled) {
      canvas.drawRRect(
        rrect.inflate(3),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..color = style.focusColor,
      );
    }

    final offset = status.pressed ? 1.0 : 0.0;
    content.paint(
      canvas,
      size.center(Offset(0, offset)),
      style.foregroundFor(status),
    );
  }

  static double _farthestCorner(Offset p, Size s) => [
    Offset.zero,
    Offset(s.width, 0),
    Offset(0, s.height),
    Offset(s.width, s.height),
  ].map((c) => (c - p).distance).reduce(math.max);

  @override
  bool shouldRepaint(PaintedButtonPainter old) =>
      old.style != style ||
      old.status != status ||
      old.content != content ||
      old.rippleCenter != rippleCenter ||
      old.rippleProgress != rippleProgress;
}
