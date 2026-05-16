import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workout_log/domain/models/exercise.dart';
import 'package:workout_log/presentation/providers/data_providers.dart';
import 'package:workout_log/presentation/theme/workout_colors.dart';
import 'package:workout_log/view/exerciseManipulationView.dart';

class ExerciseListView extends ConsumerWidget {
  const ExerciseListView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = WorkoutColors.of(context);
    final exercisesAsync = ref.watch(exercisesProvider);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Exercises Edit',
          style: TextStyle(
            color: colors.titleColor,
            fontSize: WorkoutTypography.fontSize,
          ),
        ),
        backgroundColor: colors.appBarColor,
      ),
      body: exercisesAsync.when(
        data: (exercises) => ListView.builder(
          itemCount: exercises.length,
          itemBuilder: (context, index) {
            final Exercise e = exercises[index];
            return MaterialButton(
              key: Key(e.name),
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          ExerciseManipulationView(exercise: e)),
                );
                ref.invalidate(exercisesProvider);
              },
              child: Text(
                e.name,
                style: TextStyle(color: colors.specialTextColor),
              ),
            );
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Text(
            'Failed to load exercises: $e',
            style: TextStyle(color: colors.textColor),
          ),
        ),
      ),
    );
  }
}
