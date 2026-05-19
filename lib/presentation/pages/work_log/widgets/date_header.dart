import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workout_log/presentation/providers/selected_date_provider.dart';
import 'package:workout_log/presentation/theme/workout_colors.dart';
import 'package:workout_log/presentation/widgets/responsive_scaffold.dart';
import 'package:workout_log/util/date_format.dart';

class DateHeader extends ConsumerWidget {
  const DateHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.watch(selectedDateProvider);
    final colors = WorkoutColors.of(context);
    final dims = ResponsiveDimensions.of(context);
    final today = dateFormatter.format(DateTime.now());
    final label = dateFormatter.format(selectedDate);

    return SizedBox(
      height: dims.height * (dims.isPortrait ? 0.1 : 0.2),
      child: Center(
        child: Text(
          label == today ? 'Today' : label,
          textScaler: const TextScaler.linear(3),
          style: TextStyle(
            color: colors.textColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
