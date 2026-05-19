import 'package:flutter/material.dart';

class TimerControls extends StatelessWidget {
  const TimerControls({
    super.key,
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
