import 'package:flutter/material.dart';

class CustomDurationDialog extends StatefulWidget {
  const CustomDurationDialog({super.key});

  @override
  State<CustomDurationDialog> createState() => _CustomDurationDialogState();
}

class _CustomDurationDialogState extends State<CustomDurationDialog> {
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
