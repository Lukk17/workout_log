import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Rest-timer countdown. Pick a preset (or set a custom duration), tap
/// Start, the page counts down to zero, then vibrates + plays an alert
/// system sound. Pure-Flutter — no notification permissions, no extra
/// packages.
class TimerPage extends ConsumerStatefulWidget {
  const TimerPage({super.key});

  @override
  ConsumerState<TimerPage> createState() => _TimerPageState();
}

class _TimerPageState extends ConsumerState<TimerPage> {
  /// Common rest-between-sets durations, in seconds.
  static const List<int> _presets = [30, 60, 90, 120, 180];

  Duration _selected = const Duration(seconds: 60);
  Duration _remaining = const Duration(seconds: 60);
  Timer? _ticker;
  bool _running = false;

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  void _pickPreset(int seconds) {
    if (_running) return;
    setState(() {
      _selected = Duration(seconds: seconds);
      _remaining = _selected;
    });
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
        _ring();
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

  void _ring() {
    HapticFeedback.heavyImpact();
    SystemSound.play(SystemSoundType.alert);
  }

  Future<void> _pickCustom() async {
    final picked = await showDialog<Duration>(
      context: context,
      builder: (context) => const _CustomDurationDialog(),
    );
    if (picked == null || !mounted) return;
    setState(() {
      _selected = picked;
      _remaining = picked;
    });
  }

  String _format(Duration d) {
    final m = d.inMinutes.toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final progress = _selected.inMilliseconds == 0
        ? 0.0
        : _remaining.inMilliseconds / _selected.inMilliseconds;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          // Big circular countdown
          AspectRatio(
            aspectRatio: 1,
            child: Stack(
              alignment: Alignment.center,
              children: <Widget>[
                SizedBox.expand(
                  child: CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 12,
                    color: colorScheme.primary,
                    backgroundColor: colorScheme.surfaceContainerHighest,
                  ),
                ),
                Text(
                  _format(_remaining),
                  style: textTheme.displayMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),

          // Preset chips
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: <Widget>[
              for (final secs in _presets)
                ChoiceChip(
                  label: Text('${secs}s'),
                  selected: _selected.inSeconds == secs,
                  onSelected: _running ? null : (_) => _pickPreset(secs),
                ),
              ActionChip(
                label: const Text('Custom'),
                avatar: const Icon(Icons.edit, size: 18),
                onPressed: _running ? null : _pickCustom,
              ),
            ],
          ),

          // Controls
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              FilledButton.icon(
                onPressed: _running ? _pause : _start,
                icon: Icon(_running ? Icons.pause : Icons.play_arrow),
                label: Text(_running ? 'Pause' : 'Start'),
              ),
              OutlinedButton.icon(
                onPressed: _reset,
                icon: const Icon(Icons.refresh),
                label: const Text('Reset'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Simple dialog that asks for minutes + seconds and returns a [Duration].
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
          onPressed: () {
            final m = int.tryParse(_minutesController.text) ?? 0;
            final s = int.tryParse(_secondsController.text) ?? 0;
            final total = Duration(minutes: m, seconds: s);
            if (total.inSeconds <= 0) {
              Navigator.pop(context);
              return;
            }
            Navigator.pop(context, total);
          },
          child: const Text('Set'),
        ),
      ],
    );
  }
}
