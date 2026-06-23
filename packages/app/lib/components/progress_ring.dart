import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/tokens.dart';

class CalmProgressRing extends StatelessWidget {
  final double progress; // 0.0 to 1.0
  final double size;

  const CalmProgressRing({
    super.key,
    required this.progress,
    this.size = 64.0,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;

    return CustomPaint(
      size: Size(size, size),
      painter: _ProgressRingPainter(
        progress: progress.clamp(0.0, 1.0),
        trackColor: t.border,
        fillColor: t.accent,
        strokeWidth: 6.0,
      ),
    );
  }
}

class _ProgressRingPainter extends CustomPainter {
  final double progress;
  final Color trackColor;
  final Color fillColor;
  final double strokeWidth;

  _ProgressRingPainter({
    required this.progress,
    required this.trackColor,
    required this.fillColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (math.min(size.width, size.height) - strokeWidth) / 2;

    // 1. Draw track
    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    canvas.drawCircle(center, radius, trackPaint);

    // 2. Draw progress arc
    if (progress > 0) {
      final fillPaint = Paint()
        ..color = fillColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round; // rounded caps

      final rect = Rect.fromCircle(center: center, radius: radius);
      const startAngle = -math.pi / 2; // start at top
      final sweepAngle = 2 * math.pi * progress;

      canvas.drawArc(rect, startAngle, sweepAngle, false, fillPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _ProgressRingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.trackColor != trackColor ||
        oldDelegate.fillColor != fillColor ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
