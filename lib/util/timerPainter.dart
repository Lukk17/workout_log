import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:workout_log/setting/appThemeSettings.dart';

class TimerCirclePainter extends CustomPainter {
  Color circleColor = AppThemeSettings.circleColor;
  Color arcColor = AppThemeSettings.arcColor;

  TimerCirclePainter({
    this.animation,
  }) : super(repaint: animation);

  final Animation<double> animation;

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = circleColor
      ..strokeWidth = AppThemeSettings.timerCircleWidth
      ..strokeCap = AppThemeSettings.strokeCap
      ..style = AppThemeSettings.paintingStyle;

    canvas.drawCircle(size.center(Offset.zero), size.width / 2.1, paint);
    paint.color = arcColor;
    double progress = (1.0 - animation.value) * 2 * math.pi;
    //    canvas.drawArc(Offset.zero & size, math.pi * 1.5, -progress, false, paint);
    canvas.drawArc(
        Rect.fromCircle(center: Offset(size.width / 2, size.height / 2), radius: size.width / 2.1), math.pi * 1.5, -progress, false, paint);
  }

  @override
  bool shouldRepaint(TimerCirclePainter old) {
    return animation.value != old.animation.value || arcColor != old.arcColor || circleColor != old.circleColor;
  }
}
