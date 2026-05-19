import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workout_log/presentation/pages/timer/widgets/alarm_done_dialog.dart';
import 'package:workout_log/presentation/pages/timer/widgets/countdown_dial.dart';
import 'package:workout_log/presentation/pages/timer/widgets/custom_duration_dialog.dart';
import 'package:workout_log/presentation/pages/timer/widgets/preset_chips.dart';
import 'package:workout_log/presentation/pages/timer/widgets/timer_controls.dart';
import 'package:workout_log/presentation/providers/alarm_providers.dart';
import 'package:workout_log/presentation/providers/timer_session_provider.dart';

/// Stateful only to host a single one-shot side effect: ask the OS for
/// notification permission the first time the user lands here. Every
/// piece of timer state itself lives in [timerSessionProvider].
class TimerPage extends ConsumerStatefulWidget {
  const TimerPage({super.key});

  @override
  ConsumerState<TimerPage> createState() => _TimerPageState();
}

class _TimerPageState extends ConsumerState<TimerPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  bool _permissionRequested = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _ensurePermission());
  }

  Future<void> _ensurePermission() async {
    if (_permissionRequested || !mounted) {
      return;
    }

    _permissionRequested = true;
    await ref.read(alarmServiceProvider).requestPermissions();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // AutomaticKeepAliveClientMixin

    // Alarm fire path: a tick lands on zero -> notifier flags
    // `completed`. The widget reacts here so the dialog + audio stay in
    // the UI layer.
    ref.listen<TimerSession>(timerSessionProvider, (prev, next) {
      if (prev?.completed != true && next.completed) {
        _fireAlarm();
      }
    });

    final session = ref.watch(timerSessionProvider);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          CountdownDial(remaining: session.remaining, total: session.selected),
          PresetChips(
            selected: session.selected,
            enabled: !session.running,
            onPickPreset: _pickPreset,
            onPickCustom: _pickCustom,
          ),
          TimerControls(
            running: session.running,
            onStart: ref.read(timerSessionProvider.notifier).start,
            onPause: ref.read(timerSessionProvider.notifier).pause,
            onReset: ref.read(timerSessionProvider.notifier).reset,
          ),
        ],
      ),
    );
  }

  void _pickPreset(Duration duration) {
    ref.read(timerSessionProvider.notifier).pick(duration);
  }

  Future<void> _pickCustom() async {
    final picked = await showDialog<Duration>(
      context: context,
      builder: (context) => const CustomDurationDialog(),
    );

    if (picked == null || !mounted) {
      return;
    }

    _pickPreset(picked);
  }

  Future<void> _fireAlarm() async {
    final alarm = ref.read(alarmServiceProvider);
    HapticFeedback.heavyImpact();

    // Notification fires regardless of focus state; the sound channel
    // doubles as the loud alarm tone.
    await alarm.ring();

    if (!mounted) {
      return;
    }

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlarmDoneDialog(),
    );

    // Dismiss the notification once the user acknowledges in-app, then
    // rewind the countdown so the chip + MM:SS are ready for the next set.
    await alarm.cancel();

    if (!mounted) {
      return;
    }

    ref.read(timerSessionProvider.notifier).acknowledgeAlarm();
  }
}
