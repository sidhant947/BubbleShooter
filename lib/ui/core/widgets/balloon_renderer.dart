import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:bubbleshooter/domain/models/bubble.dart';

class BalloonRenderer {
  static void renderBalloon({
    required Canvas canvas,
    required Offset center,
    required double radius,
    required BubbleColor color,
    Color? customColor,
    double opacity = 1.0,
    double scale = 1.0,
  }) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    if (scale != 1.0) {
      canvas.scale(scale, scale);
    }

    final double effectiveRadius = radius;
    final effectiveColor = customColor ?? color.color;
    final effectiveDarkColor = customColor != null
        ? HSLColor.fromColor(customColor).withLightness((HSLColor.fromColor(customColor).lightness * 0.68).clamp(0.0, 1.0)).toColor()
        : color.darkColor;
    final effectiveLightColor = customColor != null
        ? HSLColor.fromColor(customColor).withLightness((HSLColor.fromColor(customColor).lightness + (1.0 - HSLColor.fromColor(customColor).lightness) * 0.45).clamp(0.0, 1.0)).toColor()
        : color.lightColor;

    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.2 * opacity)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.5);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(0, effectiveRadius * 0.12),
        width: effectiveRadius * 1.9,
        height: effectiveRadius * 1.9,
      ),
      shadowPaint,
    );

    final bodyPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.35, -0.38),
        radius: 0.92,
        colors: [
          effectiveLightColor.withValues(alpha: opacity),
          effectiveColor.withValues(alpha: opacity),
          effectiveDarkColor.withValues(alpha: opacity),
        ],
        stops: const [0.0, 0.55, 1.0],
      ).createShader(Rect.fromCircle(center: Offset.zero, radius: effectiveRadius));

    canvas.drawCircle(Offset.zero, effectiveRadius, bodyPaint);

    final bounceGlowPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(0.42, 0.48),
        radius: 0.52,
        colors: [
          effectiveLightColor.withValues(alpha: 0.4 * opacity),
          effectiveLightColor.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromCircle(center: Offset.zero, radius: effectiveRadius));
    canvas.drawCircle(Offset.zero, effectiveRadius, bounceGlowPaint);

    final rimPaint = Paint()
      ..color = effectiveDarkColor.withValues(alpha: 0.35 * opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(0.8, effectiveRadius * 0.045);
    canvas.drawCircle(Offset.zero, effectiveRadius, rimPaint);

    // 5. Primary glossy highlight (curved capsule/oval reflection)
    final highlightPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.72 * opacity)
      ..style = PaintingStyle.fill;

    canvas.save();
    canvas.translate(-effectiveRadius * 0.32, -effectiveRadius * 0.36);
    canvas.rotate(-math.pi / 4.2);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset.zero,
          width: effectiveRadius * 0.44,
          height: effectiveRadius * 0.22,
        ),
        Radius.circular(effectiveRadius * 0.11),
      ),
      highlightPaint,
    );
    canvas.restore();

    // 6. Secondary specular glint dot
    final dotPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.55 * opacity)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(
      Offset(-effectiveRadius * 0.12, -effectiveRadius * 0.56),
      effectiveRadius * 0.075,
      dotPaint,
    );

    canvas.restore();
  }
}
