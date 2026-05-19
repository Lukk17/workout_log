import 'package:workout_log/domain/models/body_part.dart';
import 'package:workout_log/domain/models/exercise.dart';

final List<Exercise> defaultExerciseSeed = [
  Exercise.create(
    name: 'Push Up',
    bodyParts: {BodyPart.chest},
    secondaryBodyParts: {BodyPart.arm},
  ),

  Exercise.create(
    name: 'Pull Up',
    bodyParts: {BodyPart.back},
    secondaryBodyParts: {BodyPart.arm},
  ),

  Exercise.create(
    name: 'Dead Lift',
    bodyParts: {BodyPart.back, BodyPart.leg},
    secondaryBodyParts: {BodyPart.arm},
  ),

  Exercise.create(name: 'Running', bodyParts: {BodyPart.cardio}),

  Exercise.create(
    name: 'Back Lat Pull-Downs',
    bodyParts: {BodyPart.back},
    secondaryBodyParts: {BodyPart.arm},
  ),

  Exercise.create(
    name: 'Dumbbell Flys',
    bodyParts: {BodyPart.chest},
    secondaryBodyParts: {BodyPart.arm, BodyPart.abdominal},
  ),

  Exercise.create(
    name: 'Bench Presses',
    bodyParts: {BodyPart.chest},
    secondaryBodyParts: {BodyPart.arm},
  ),

  Exercise.create(name: 'Barbell Curls', bodyParts: {BodyPart.arm}),

  Exercise.create(
    name: 'Machine Presses',
    bodyParts: {BodyPart.chest},
    secondaryBodyParts: {BodyPart.arm},
  ),

  Exercise.create(
    name: 'Back Extensions',
    bodyParts: {BodyPart.back},
    secondaryBodyParts: {BodyPart.leg, BodyPart.abdominal},
  ),

  Exercise.create(
    name: 'Machine Low Row',
    bodyParts: {BodyPart.back},
    secondaryBodyParts: {BodyPart.arm, BodyPart.abdominal},
  ),

  Exercise.create(
    name: 'Machine Lat Pulldown',
    bodyParts: {BodyPart.back},
    secondaryBodyParts: {BodyPart.arm, BodyPart.abdominal},
  ),

  Exercise.create(
    name: 'Barbell Squats',
    bodyParts: {BodyPart.leg},
    secondaryBodyParts: {BodyPart.back},
  ),

  Exercise.create(
    name: 'Back Presses',
    bodyParts: {BodyPart.arm},
    secondaryBodyParts: {BodyPart.back, BodyPart.abdominal},
  ),

  Exercise.create(
    name: 'Plank',
    bodyParts: {BodyPart.abdominal},
    secondaryBodyParts: {BodyPart.leg},
  ),

  Exercise.create(
    name: 'Leg Raises',
    bodyParts: {BodyPart.abdominal},
    secondaryBodyParts: {BodyPart.leg},
  ),

  Exercise.create(
    name: 'Incline Presses',
    bodyParts: {BodyPart.chest, BodyPart.arm},
  ),

  Exercise.create(
    name: 'Decline Presses',
    bodyParts: {BodyPart.chest},
    secondaryBodyParts: {BodyPart.arm},
  ),

  Exercise.create(
    name: 'Concentration Dumbell Curls',
    bodyParts: {BodyPart.arm},
  ),

  Exercise.create(
    name: 'Dumbell Front Arm Raises',
    bodyParts: {BodyPart.arm},
    secondaryBodyParts: {BodyPart.abdominal, BodyPart.chest},
  ),

  Exercise.create(
    name: 'Muscle-Up',
    bodyParts: {BodyPart.back, BodyPart.arm},
    secondaryBodyParts: {BodyPart.chest, BodyPart.abdominal},
  ),

  Exercise.create(
    name: 'Burpees',
    bodyParts: {BodyPart.cardio},
    secondaryBodyParts: {BodyPart.chest, BodyPart.arm, BodyPart.abdominal},
  ),

  Exercise.create(
    name: 'Cable Crossover Flys',
    bodyParts: {BodyPart.chest},
    secondaryBodyParts: {BodyPart.arm},
  ),

  Exercise.create(
    name: 'Barbell Rows',
    bodyParts: {BodyPart.back},
    secondaryBodyParts: {BodyPart.arm},
  ),

  Exercise.create(
    name: 'Dumbbell Shrugs',
    bodyParts: {BodyPart.arm},
    secondaryBodyParts: {BodyPart.back},
  ),

  Exercise.create(name: 'Dumbbell Curls', bodyParts: {BodyPart.arm}),

  Exercise.create(
    name: 'Bent-Over Lateral Raises',
    bodyParts: {BodyPart.arm},
    secondaryBodyParts: {BodyPart.back},
  ),
];
