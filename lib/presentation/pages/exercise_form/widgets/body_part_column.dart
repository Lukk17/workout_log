import 'package:flutter/material.dart';
import 'package:workout_log/domain/models/body_part.dart';
import 'package:workout_log/presentation/theme/workout_colors.dart';
import 'package:workout_log/presentation/util/responsive.dart';

class BodyPartColumn extends StatelessWidget {
  const BodyPartColumn({
    super.key,
    required this.title,
    required this.selected,
    required this.excluded,
    required this.onToggle,
  });

  final String title;
  final Set<BodyPart> selected;
  final Set<BodyPart> excluded;
  final void Function(BodyPart bp, bool value) onToggle;

  @override
  Widget build(BuildContext context) {
    final colors = WorkoutColors.of(context);
    final checkboxes = <Widget>[];
    for (final bp in BodyPart.values) {
      if (bp == BodyPart.undefined) continue;
      if (excluded.contains(bp)) continue;
      final name = Util.getBpName(bp);
      checkboxes.add(Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        alignment: WrapAlignment.center,
        children: <Widget>[
          Text(name, style: TextStyle(color: colors.textColor)),
          Checkbox(
            value: selected.contains(bp),
            onChanged: (value) => onToggle(bp, value ?? false),
          ),
        ],
      ));
    }
    return Column(
      children: <Widget>[
        Text(title),
        Wrap(
          alignment: WrapAlignment.spaceAround,
          spacing: 8,
          runSpacing: 4,
          children: checkboxes,
        ),
      ],
    );
  }
}
