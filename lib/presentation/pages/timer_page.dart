import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workout_log/presentation/providers/alarm_providers.dart';
import 'package:workout_log/presentation/providers/timer_preset_provider.dart';
import 'package:workout_log/presentation/theme/workout_colors.dart';

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
  bool _hydrated = false;

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

  // Hydration runs from build, not initState, because the persisted
  // value may not have loaded by the time initState runs.
  void _syncFromPreset(Duration persisted) {
    if (_hydrated || _running) return;
    _hydrated = true;
    if (persisted != _selected) {
      _selected = persisted;
      _remaining = persisted;
    }
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
      builder: (context) => const _AlarmDoneDialog(),
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
      builder: (context) => const _CustomDurationDialog(),
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
          _CountdownDial(remaining: _remaining, total: _selected),
          _PresetChips(
            selected: _selected,
            enabled: !_running,
            onPickPreset: _pickPreset,
            onPickCustom: _pickCustom,
          ),
          _TimerControls(
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

class _CountdownDial extends StatelessWidget {
  const _CountdownDial({required this.remaining, required this.total});

  final Duration remaining;
  final Duration total;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final workoutColors = WorkoutColors.of(context);
    final progress =
        total.inMilliseconds == 0 ? 0.0 : remaining.inMilliseconds / total.inMilliseconds;

    return AspectRatio(
      aspectRatio: 1,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          SizedBox.expand(
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: 12,
              color: workoutColors.arcColor,
              backgroundColor: colorScheme.surfaceContainerHighest,
            ),
          ),
          Text(
            _format(remaining),
            style: textTheme.displayMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  static String _format(Duration d) {
    final m = d.inMinutes.toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }
}

class _PresetChips extends StatelessWidget {
  const _PresetChips({
    required this.selected,
    required this.enabled,
    required this.onPickPreset,
    required this.onPickCustom,
  });

  static const _shortPresets = [30, 60, 90];
  static const _longPresets = [120, 180, 300];

  final Duration selected;
  final bool enabled;
  final ValueChanged<Duration> onPickPreset;
  final VoidCallback onPickCustom;

  static String _presetLabel(int seconds) {
    if (seconds < 60) return '${seconds}s';
    return '${seconds ~/ 60} min';
  }

  Widget _row(List<int> presets) => Wrap(
        spacing: 8,
        alignment: WrapAlignment.center,
        children: <Widget>[
          for (final secs in presets)
            ChoiceChip(
              label: Text(_presetLabel(secs)),
              selected: selected.inSeconds == secs,
              onSelected:
                  enabled ? (_) => onPickPreset(Duration(seconds: secs)) : null,
            ),
        ],
      );

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        _row(_shortPresets),
        const SizedBox(height: 8),
        _row(_longPresets),
        const SizedBox(height: 8),
        ActionChip(
          label: const Text('Custom'),
          avatar: const Icon(Icons.edit, size: 18),
          onPressed: enabled ? onPickCustom : null,
        ),
      ],
    );
  }
}

class _TimerControls extends StatelessWidget {
  const _TimerControls({
    required this.running,
    required this.onStart,
    required this.onPause,
    required this.onReset,
  });

  final bool running;
  final VoidCallback onStart;
  final VoidCallback onPause;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        FilledButton.icon(
          onPressed: running ? onPause : onStart,
          icon: Icon(running ? Icons.pause : Icons.play_arrow),
          label: Text(running ? 'Pause' : 'Start'),
        ),
        OutlinedButton.icon(
          onPressed: onReset,
          icon: const Icon(Icons.refresh),
          label: const Text('Reset'),
        ),
      ],
    );
  }
}

class _AlarmDoneDialog extends StatelessWidget {
  const _AlarmDoneDialog();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      icon: const Icon(Icons.alarm, size: 48),
      title: const Text('Rest over', textAlign: TextAlign.center),
      actionsAlignment: MainAxisAlignment.center,
      actions: <Widget>[
        FilledButton.icon(
          icon: const Icon(Icons.fitness_center),
          label: const Text('Time to lift'),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }
}

class _CustomDurationDialog extends StatefulWidget {
  const _CustomDurationDialog();

  @override
  State<_CustomDurationDialog> createState() => _CustomDurationDialogState();
}

class _CustomDurationDialogState extends State<_CustomDurationDialog> {
  final _minutesController = TextEditingController(text: '2');
  final _secondsController = TextEditingController(text: '0');

  @override
  void dispose() {
    _minutesController.dispose();
    _secondsController.dispose();
    super.dispose();
  }

  void _confirm() {
    final m = int.tryParse(_minutesController.text) ?? 0;
    final s = int.tryParse(_secondsController.text) ?? 0;
    final total = Duration(minutes: m, seconds: s);
    Navigator.pop(context, total.inSeconds > 0 ? total : null);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Custom duration'),
      content: Row(
        children: <Widget>[
          Expanded(
            child: TextField(
              controller: _minutesController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Minutes',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _secondsController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Seconds',
                border: OutlineInputBorder(),
              ),
            ),
          ),
        ],
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _confirm,
          child: const Text('Set'),
        ),
      ],
    );
  }
}
