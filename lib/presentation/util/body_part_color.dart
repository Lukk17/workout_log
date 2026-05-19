import 'package:flutter/material.dart';
import 'package:workout_log/domain/models/body_part.dart';
import 'package:workout_log/presentation/theme/workout_colors.dart';

extension BodyPartColor on BodyPart {
  Color color(WorkoutColors colors) => switch (this) {
        BodyPart.chest => colors.chestColor,
        BodyPart.back => colors.backColor,
        BodyPart.leg => colors.legColor,
        BodyPart.arm => colors.armColor,
        BodyPart.cardio => colors.cardioColor,
        BodyPart.abdominal => colors.abdominalColor,
        BodyPart.undefined => Colors.white70,
      };
}
