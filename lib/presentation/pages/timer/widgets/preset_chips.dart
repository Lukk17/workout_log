import 'package:flutter/material.dart';
import 'package:workout_log/presentation/pages/timer/widgets/preset_chip_row.dart';

class PresetChips extends StatelessWidget {
  const PresetChips({
    super.key,
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

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        PresetChipRow(
          presets: _shortPresets,
          selected: selected,
          enabled: enabled,
          onPick: onPickPreset,
        ),
        const SizedBox(height: 8),
        PresetChipRow(
          presets: _longPresets,
          selected: selected,
          enabled: enabled,
          onPick: onPickPreset,
        ),
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
