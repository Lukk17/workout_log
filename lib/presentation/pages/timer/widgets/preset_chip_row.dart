import 'package:flutter/material.dart';

class PresetChipRow extends StatelessWidget {
  const PresetChipRow({
    super.key,
    required this.presets,
    required this.selected,
    required this.enabled,
    required this.onPick,
  });

  final List<int> presets;
  final Duration selected;
  final bool enabled;
  final ValueChanged<Duration> onPick;

  static String labelFor(int seconds) {
    if (seconds < 120) return '${seconds}s';
    return '${seconds ~/ 60} min';
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      alignment: WrapAlignment.center,
      children: <Widget>[
        for (final secs in presets)
          ChoiceChip(
            label: Text(labelFor(secs)),
            selected: selected.inSeconds == secs,
            onSelected: enabled ? (_) => onPick(Duration(seconds: secs)) : null,
          ),
      ],
    );
  }
}
