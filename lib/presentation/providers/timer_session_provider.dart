import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:workout_log/presentation/providers/timer_preset_provider.dart';

/// Snapshot of the rest-timer's UI state. `completed` is a one-shot flag
/// the widget watches via `ref.listen` to fire the alarm dialog; the
/// notifier clears it once the dialog is acknowledged.
@immutable
class TimerSession {
  const TimerSession({
    required this.selected,
    required this.remaining,
    required this.running,
    this.completed = false,
  });

  final Duration selected;
  final Duration remaining;
  final bool running;
  final bool completed;

  TimerSession copyWith({
    Duration? selected,
    Duration? remaining,
    bool? running,
    bool? completed,
  }) {
    return TimerSession(
      selected: selected ?? this.selected,
      remaining: remaining ?? this.remaining,
      running: running ?? this.running,
      completed: completed ?? this.completed,
    );
  }
}

class TimerSessionNotifier extends StateNotifier<TimerSession> {
  TimerSessionNotifier(this._ref)
    : super(
        const TimerSession(
          selected: Duration(seconds: 60),
          remaining: Duration(seconds: 60),
          running: false,
        ),
      ) {
    // Mirror the persisted preset into the session whenever it changes.
    // SharedPreferences loads after construction so the initial state
    // is the in-memory default until this listener fires.
    _ref.listen<Duration>(
      timerPresetProvider,
      (_, next) => _applyPersistedPreset(next),
    );
    _applyPersistedPreset(_ref.read(timerPresetProvider));
  }

  final Ref _ref;
  Timer? _ticker;

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  void _applyPersistedPreset(Duration persisted) {
    if (state.running) {
      return;
    }

    if (persisted == state.selected) {
      return;
    }

    state = state.copyWith(selected: persisted, remaining: persisted);
  }

  void pick(Duration duration) {
    if (state.running) {
      return;
    }

    state = state.copyWith(selected: duration, remaining: duration);
    _ref.read(timerPresetProvider.notifier).set(duration);
  }

  void start() {
    if (state.running || state.remaining.inMilliseconds == 0) {
      return;
    }

    state = state.copyWith(running: true, completed: false);
    _ticker = Timer.periodic(const Duration(seconds: 1), _tick);
  }

  void _tick(Timer t) {
    final next = state.remaining - const Duration(seconds: 1);

    if (next.inMilliseconds <= 0) {
      t.cancel();
      state = state.copyWith(
        remaining: Duration.zero,
        running: false,
        completed: true,
      );

      return;
    }

    state = state.copyWith(remaining: next);
  }

  void pause() {
    _ticker?.cancel();
    state = state.copyWith(running: false);
  }

  void reset() {
    _ticker?.cancel();
    state = state.copyWith(
      remaining: state.selected,
      running: false,
      completed: false,
    );
  }

  /// Called after the alarm dialog is dismissed. Rewinds the displayed
  /// countdown to the picked preset so the next set is ready to start.
  void acknowledgeAlarm() {
    state = state.copyWith(remaining: state.selected, completed: false);
  }
}

final timerSessionProvider =
    StateNotifierProvider<TimerSessionNotifier, TimerSession>(
      (ref) => TimerSessionNotifier(ref),
    );
