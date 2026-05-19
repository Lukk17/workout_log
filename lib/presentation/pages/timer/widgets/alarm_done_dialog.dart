import 'package:flutter/material.dart';
import 'package:workout_log/data/alarm/alarm_service.dart';

class AlarmDoneDialog extends StatelessWidget {
  const AlarmDoneDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      icon: const Icon(Icons.alarm, size: 48),
      title: const Text(alarmTitle, textAlign: TextAlign.center),
      actionsAlignment: MainAxisAlignment.center,
      actions: <Widget>[
        FilledButton.icon(
          icon: const Icon(Icons.fitness_center),
          label: const Text(alarmBody),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }
}
