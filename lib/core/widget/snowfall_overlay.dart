import 'dart:math';
import 'package:flutter/material.dart';

/// Decorative snow; the entire layer ignores pointer input.
class SnowfallOverlay extends StatefulWidget {
  const SnowfallOverlay({super.key});
  @override
  State<SnowfallOverlay> createState() => _SnowfallOverlayState();
}

class _SnowfallOverlayState extends State<SnowfallOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animation = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 20),
  )..repeat();

  @override
  void dispose() {
    _animation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => IgnorePointer(
    child: ExcludeSemantics(
      child: RepaintBoundary(
        child: CustomPaint(
          painter: _SnowPainter(_animation),
          size: Size.infinite,
        ),
      ),
    ),
  );
}

class _SnowPainter extends CustomPainter {
  _SnowPainter(this.animation) : super(repaint: animation);
  final Animation<double> animation;
  @override
  void paint(Canvas canvas, Size size) {
    final random = Random(25);
    for (var i = 0; i < 45; i++) {
      final x = random.nextDouble();
      final y = random.nextDouble();
      final radius = 1.2 + random.nextDouble() * 2.4;
      final drift = sin(animation.value * pi * 2 + i) * 16;
      final position = Offset(
        (x * size.width + drift) % size.width,
        ((y + animation.value) % 1) * (size.height + 12) - 6,
      );
      canvas.drawCircle(
        position,
        radius + 0.7,
        Paint()..color = const Color(0x187299B1),
      );
      canvas.drawCircle(
        position,
        radius,
        Paint()..color = const Color(0xCFFFFFFF),
      );
    }
  }

  @override
  bool shouldRepaint(_SnowPainter oldDelegate) =>
      oldDelegate.animation != animation;
}
