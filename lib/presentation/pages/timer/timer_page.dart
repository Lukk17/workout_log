import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workout_log/presentation/pages/timer/widgets/alarm_done_dialog.dart';
import 'package:workout_log/presentation/pages/timer/widgets/countdown_dial.dart';
import 'package:workout_log/presentation/pages/timer/widgets/custom_duration_dialog.dart';
import 'package:workout_log/presentation/pages/timer/widgets/preset_chips.dart';
import 'package:workout_log/presentation/pages/timer/widgets/timer_controls.dart';
import 'package:workout_log/presentation/providers/alarm_providers.dart';
import 'package:workout_log/presentation/providers/timer_preset_provider.dart';

class TimerPage extends ConsumerStatefulWidget {
  const TimerPage({super.key});

  @override
  ConsumerState<TimerPage> createState() => _TimerPageState();
}

class _TimerPageState extends ConsumerState<TimerPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  Duration _selected = const Duration(seconds: 60);
  Duration _remaining = const Duration(seconds: 60);
  Timer? _ticker;
  bool _running = false;
  bool _permissionRequested = false;

  @override
  void initState() {
    super.initState();
    // Defer to after the first frame so we don't block startup; request
    // notification permission the first time the user lands on this page.
    WidgetsBinding.instance.addPostFrameCallback((_) => _ensurePermission());
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  // Sync runs from build, not initState, because the persisted value
  // loads asynchronously after the notifier is constructed — so on
  // first render we may see the in-memory default before the real
  // persisted preset arrives.
  void _syncFromPreset(Duration persisted) {
    if (_running) return;
    if (persisted == _selected) return;
    _selected = persisted;
    _remaining = persisted;
  }

  Future<void> _ensurePermission() async {
    if (_permissionRequested || !mounted) return;
    _permissionRequested = true;
    await ref.read(alarmServiceProvider).requestPermissions();
  }

  void _pickPreset(Duration duration) {
    if (_running) return;
    setState(() {
      _selected = duration;
      _remaining = duration;
    });
    ref.read(timerPresetProvider.notifier).set(duration);
  }

  void _start() {
    if (_running || _remaining.inMilliseconds == 0) return;
    setState(() => _running = true);
    _ticker = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      final next = _remaining - const Duration(seconds: 1);
      if (next.inMilliseconds <= 0) {
        t.cancel();
        setState(() {
          _remaining = Duration.zero;
          _running = false;
        });
        _fireAlarm();
      } else {
        setState(() => _remaining = next);
      }
    });
  }

  void _pause() {
    _ticker?.cancel();
    if (mounted) setState(() => _running = false);
  }

  void _reset() {
    _ticker?.cancel();
    setState(() {
      _remaining = _selected;
      _running = false;
    });
  }

  Future<void> _fireAlarm() async {
    final alarm = ref.read(alarmServiceProvider);
    HapticFeedback.heavyImpact();
    // Notification fires regardless of focus state; the sound channel
    // doubles as the loud alarm tone.
    await alarm.ring();
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlarmDoneDialog(),
    );
    // Dismiss the notification once the user acknowledges in-app, then
    // reset the countdown to the selected duration so the chip + MM:SS
    // are ready for the next set.
    await alarm.cancel();
    if (!mounted) return;
    setState(() => _remaining = _selected);
  }

  Future<void> _pickCustom() async {
    final picked = await showDialog<Duration>(
      context: context,
      builder: (context) => const CustomDurationDialog(),
    );
    if (picked == null || !mounted) return;
    _pickPreset(picked);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // AutomaticKeepAliveClientMixin
    _syncFromPreset(ref.watch(timerPresetProvider));

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          CountdownDial(remaining: _remaining, total: _selected),
          PresetChips(
            selected: _selected,
            enabled: !_running,
            onPickPreset: _pickPreset,
            onPickCustom: _pickCustom,
          ),
          TimerControls(
            running: _running,
            onStart: _start,
            onPause: _pause,
            onReset: _reset,
          ),
        ],
      ),
    );
  }
}
