import 'package:flutter/material.dart';
import 'package:workout_log/presentation/theme/workout_colors.dart';

class NameField extends StatelessWidget {
  const NameField({
    super.key,
    required this.controller,
    required this.width,
  });

  final TextEditingController controller;
  final double width;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: TextFormField(
        textAlign: TextAlign.center,
        controller: controller,
        style: const TextStyle(fontSize: WorkoutTypography.headerSize),
      ),
    );
  }
}
