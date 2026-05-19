import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:workout_log/presentation/widgets/responsive_scaffold.dart';

/// A red, full-extent slidable action that calls [onDelete] when tapped.
/// Used by both the work-log card list and the exercise-detail series
/// rows so the swipe-to-delete affordance looks the same everywhere.
class DeleteActionPane extends ActionPane {
  DeleteActionPane({super.key, required VoidCallback onDelete})
      : super(
          motion: const ScrollMotion(),
          extentRatio: 0.25,
          children: [
            Builder(builder: (context) {
              final dims = ResponsiveDimensions.of(context);
              return Container(
                margin: EdgeInsets.symmetric(vertical: dims.height * 0.01),
                child: SlidableAction(
                  onPressed: (context) => onDelete(),
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  icon: Icons.delete,
                  label: 'Delete',
                ),
              );
            }),
          ],
        );
}
