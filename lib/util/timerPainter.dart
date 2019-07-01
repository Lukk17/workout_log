import 'package:flutter/material.dart';
//  importing math and referring to that as "math"
import 'dart:math' as math;

import 'package:workout_log/setting/appThemeSettings.dart';



class TimerCirclePainter extends CustomPainter {
  TimerCirclePainter({
    this.animation,
    this.circleColor,
    this.arcColor,
  }) : super(repaint: animation);

  final Animation<double> animation;
  final Color circleColor, arcColor;

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = circleColor
      ..strokeWidth = AppThemeSettings.timerCircleWidth
      ..strokeCap = AppThemeSettings.strokeCap
      ..style = AppThemeSettings.paintingStyle;

    canvas.drawCircle(size.center(Offset.zero), size.width / 2.0, paint);
    paint.color = arcColor;
    double progress = (1.0 - animation.value) * 2 * math.pi;
    canvas.drawArc(Offset.zero & size, math.pi * 1.5, -progress, false, paint);
  }

  @override
  bool shouldRepaint(TimerCirclePainter old) {
    return animation.value != old.animation.value ||
        arcColor != old.arcColor ||
        circleColor != old.circleColor;
  }
}