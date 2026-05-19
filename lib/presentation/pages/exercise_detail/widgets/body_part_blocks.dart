import 'package:flutter/material.dart';
import 'package:workout_log/domain/models/body_part.dart';
import 'package:workout_log/presentation/pages/exercise_detail/detail_table_layout.dart';
import 'package:workout_log/presentation/theme/workout_colors.dart';
import 'package:workout_log/presentation/util/responsive.dart';

class BodyPartBlocks extends StatelessWidget {
  const BodyPartBlocks({
    super.key,
    required this.parts,
    required this.layout,
  });

  final Set<BodyPart> parts;
  final DetailTableLayout layout;

  @override
  Widget build(BuildContext context) {
    final colors = WorkoutColors.of(context);
    final blocks = parts
        .map((bp) => SizedBox(
              height: layout.screenHeight * 0.05,
              width: layout.screenWidth * 0.3,
              child: Container(
                color: Util.getBpColor(bp, colors),
                child: Center(
                  child: Text(
                    Util.getBpName(bp),
                    style: const TextStyle(color: Colors.amber),
                  ),
                ),
              ),
            ))
        .toList();

    if (blocks.length <= 3) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: blocks,
      );
    }
    return Column(
      children: <Widget>[
        Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: blocks.take(3).toList()),
        SizedBox(height: layout.screenHeight * 0.01),
        Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: blocks.skip(3).toList()),
      ],
    );
  }
}
