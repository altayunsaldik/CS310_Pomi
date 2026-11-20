import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme.dart';

class TimerRing extends StatelessWidget {
  const TimerRing({
    super.key,
    required this.fraction,
    required this.child,
    this.size = 260,
  });

  final double fraction;
  final Widget child;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _RingPainter(fraction),
        child: Center(child: child),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter(this.fraction);
  final double fraction;

  @override
  void paint(Canvas canvas, Size size) {
    const stroke = 9.0;
    final rect = Offset.zero & size;
    final arcRect = rect.deflate(stroke / 2);
    final track = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..color = kTrack;
    final bar = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..color = kInk;
    canvas.drawArc(arcRect, 0, 2 * math.pi, false, track);
    if (fraction > 0) {
      canvas.drawArc(arcRect, -math.pi / 2, 2 * math.pi * fraction, false, bar);
    }
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.fraction != fraction;
}
