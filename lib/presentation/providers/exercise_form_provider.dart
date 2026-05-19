import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:workout_log/domain/models/body_part.dart';
import 'package:workout_log/domain/models/exercise.dart';

/// Selected primary/secondary body parts during an ExerciseFormPage
/// session. Lives in a family keyed by the (optional) exercise being
/// edited so the create-new and edit-existing flows don't share state.
@immutable
class ExerciseFormState {
  const ExerciseFormState({required this.primary, required this.secondary});

  factory ExerciseFormState.from(Exercise? exercise) {
    if (exercise == null) {
      return const ExerciseFormState(
        primary: <BodyPart>{},
        secondary: <BodyPart>{},
      );
    }

    return ExerciseFormState(
      primary: {...exercise.bodyParts},
      secondary: {...exercise.secondaryBodyParts},
    );
  }

  final Set<BodyPart> primary;
  final Set<BodyPart> secondary;

  ExerciseFormState copyWith({
    Set<BodyPart>? primary,
    Set<BodyPart>? secondary,
  }) {
    return ExerciseFormState(
      primary: primary ?? this.primary,
      secondary: secondary ?? this.secondary,
    );
  }
}

class ExerciseFormNotifier extends StateNotifier<ExerciseFormState> {
  ExerciseFormNotifier(Exercise? initial)
    : super(ExerciseFormState.from(initial));

  void togglePrimary(BodyPart bp, {required bool value}) {
    if (value) {
      state = state.copyWith(
        primary: {...state.primary, bp},
        secondary: state.secondary.where((b) => b != bp).toSet(),
      );

      return;
    }

    state = state.copyWith(
      primary: state.primary.where((b) => b != bp).toSet(),
    );
  }

  void toggleSecondary(BodyPart bp, {required bool value}) {
    if (value) {
      state = state.copyWith(
        secondary: {...state.secondary, bp},
        primary: state.primary.where((b) => b != bp).toSet(),
      );

      return;
    }

    state = state.copyWith(
      secondary: state.secondary.where((b) => b != bp).toSet(),
    );
  }
}

final exerciseFormProvider = StateNotifierProvider.autoDispose
    .family<ExerciseFormNotifier, ExerciseFormState, Exercise?>(
      (ref, initial) => ExerciseFormNotifier(initial),
    );
