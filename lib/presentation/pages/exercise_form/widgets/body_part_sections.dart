import 'package:flutter/material.dart';
import 'package:workout_log/domain/models/body_part.dart';
import 'package:workout_log/presentation/pages/exercise_form/widgets/body_part_column.dart';

class BodyPartSections extends StatelessWidget {
  const BodyPartSections({
    super.key,
    required this.primary,
    required this.secondary,
    required this.isPortrait,
    required this.onToggle,
  });

  final Set<BodyPart> primary;
  final Set<BodyPart> secondary;
  final bool isPortrait;
  final void Function(BodyPart, {required bool secondary, required bool value})
  onToggle;

  @override
  Widget build(BuildContext context) {
    final sections = <Widget>[
      BodyPartColumn(
        title: 'Main Body Parts:',
        selected: primary,
        excluded: secondary,
        onToggle: (bp, value) => onToggle(bp, secondary: false, value: value),
      ),
      BodyPartColumn(
        title: 'Secondary Body Parts:',
        selected: secondary,
        excluded: primary,
        onToggle: (bp, value) => onToggle(bp, secondary: true, value: value),
      ),
    ];
    return isPortrait
        ? Column(children: sections)
        : Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: sections,
          );
  }
}
