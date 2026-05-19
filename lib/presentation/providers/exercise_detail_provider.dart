import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:workout_log/domain/models/work_log.dart';
import 'package:workout_log/presentation/providers/data_providers.dart';
import 'package:workout_log/util/log.dart';

/// Route-scoped editor for a single [WorkLog]. The family key is the
/// initial workLog the page received via navigation, so every detail
/// route gets its own notifier instance; autoDispose tears it down when
/// the page pops.
///
/// Note: the family key is a [WorkLog] (a freezed value class with
/// stable equality), so a re-navigation with a value-equal WorkLog
/// reuses the existing notifier. If a parent provider hands the page a
/// WorkLog with refreshed fields, a *new* notifier is spawned and the
/// old one auto-disposes — that's intentional, the user's local edits
/// in the previous route are dropped when the underlying data shifts.
class ExerciseDetailNotifier extends StateNotifier<WorkLog> {
  ExerciseDetailNotifier(this._ref, WorkLog initial) : super(initial);

  final Ref _ref;
  static const _tag = 'ExerciseDetailNotifier';

  Future<void> editLoad(String setKey, String value) async {
    final updated = state.copyWith(load: {...state.load, setKey: value});
    await _persist(updated);
    logFine('load changed to $value for $updated', name: _tag);
  }

  Future<void> editRepeats(String setKey, String value) async {
    final updated = state.copyWith(series: {...state.series, setKey: value});
    await _persist(updated);
    logFine('repeats changed to $value for $updated', name: _tag);
  }

  Future<void> addSeries() async {
    final nextIndex = (state.series.length + 1).toString();
    final updated = state.copyWith(
      series: {...state.series, nextIndex: '0'},
      load: {...state.load, nextIndex: '0'},
    );
    await _persist(updated);
    logFine('Series added to: $updated', name: _tag);
  }

  Future<void> deleteSeries(int removedIndex) async {
    final rebuilt = state.copyWith(
      series: _removeIndexAndShift(state.series, removedIndex),
      load: _removeIndexAndShift(state.load, removedIndex),
    );
    await _persist(rebuilt);
    logFine('Series number $removedIndex deleted from $rebuilt', name: _tag);
  }

  Future<void> _persist(WorkLog updated) async {
    await _ref.read(workLogDaoProvider).update(updated);
    state = updated;
    _ref.invalidate(workLogsByDateProvider(state.created));
  }

  static Map<String, String> _removeIndexAndShift(
    Map<String, String> source,
    int removedIndex,
  ) {
    final result = <String, String>{};

    source.forEach((key, value) {
      final n = int.parse(key);

      if (n == removedIndex) {
        return;
      }

      final newKey = n > removedIndex ? (n - 1).toString() : key;
      result[newKey] = value;
    });

    return result;
  }
}

final exerciseDetailProvider = StateNotifierProvider.autoDispose
    .family<ExerciseDetailNotifier, WorkLog, WorkLog>(
  (ref, initial) => ExerciseDetailNotifier(ref, initial),
);
