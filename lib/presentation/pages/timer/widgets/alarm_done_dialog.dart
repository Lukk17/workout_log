import 'package:flutter/material.dart';

class AlarmDoneDialog extends StatelessWidget {
  const AlarmDoneDialog({super.key});

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
