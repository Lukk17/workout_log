import 'package:workout_log/entity/exercise.dart';

class WorkLog {
  int id;
  Exercise exercise;
  int series = 0;
  int repeat = 0;

  WorkLog(this.exercise);
}
