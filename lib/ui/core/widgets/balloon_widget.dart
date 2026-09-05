import 'package:flutter/material.dart';
import 'package:bubbleshooter/domain/models/bubble.dart';
import 'balloon_renderer.dart';

class BalloonWidget extends StatelessWidget {
  const BalloonWidget({
    super.key,
    required this.color,
    this.size = 40.0,
    this.opacity = 1.0,
  });

  final BubbleColor color;
  final double size;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _BalloonPainter(
          color: color,
          opacity: opacity,
        ),
      ),
    );
  }
}

class _BalloonPainter extends CustomPainter {
  const _BalloonPainter({
    required this.color,
    required this.opacity,
  });

  final BubbleColor color;
  final double opacity;

  @override
  void paint(Canvas canvas, Size size) {
    final radius = size.width / 2.0;
    final center = Offset(size.width / 2.0, size.height / 2.0);
    BalloonRenderer.renderBalloon(
      canvas: canvas,
      center: center,
      radius: radius * 0.82,
      color: color,
      opacity: opacity,
    );
  }

  @override
  bool shouldRepaint(covariant _BalloonPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.opacity != opacity;
}
