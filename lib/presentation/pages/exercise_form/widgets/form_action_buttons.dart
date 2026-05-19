import 'package:flutter/material.dart';
import 'package:workout_log/presentation/theme/workout_colors.dart';
import 'package:workout_log/presentation/widgets/responsive_scaffold.dart';

class FormActionButtons extends StatelessWidget {
  const FormActionButtons({
    super.key,
    required this.dims,
    required this.onSave,
    required this.onCancel,
  });

  final ResponsiveDimensions dims;
  final VoidCallback onSave;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final colors = WorkoutColors.of(context);
    final buttonHeight = dims.height * (dims.isPortrait ? 0.06 : 0.1);
    final buttonWidth = dims.width * (dims.isPortrait ? 0.5 : 0.27);
    final saveButton = MaterialButton(
      onPressed: onSave,
      height: buttonHeight,
      minWidth: buttonWidth,
      color: colors.greenButtonColor,
      splashColor: colors.buttonSplashColor,
      textColor: colors.buttonTextColor,
      child: const Text('SAVE'),
    );
    final cancelButton = MaterialButton(
      onPressed: onCancel,
      height: buttonHeight,
      minWidth: buttonWidth,
      color: colors.cancelButtonColor,
      splashColor: colors.buttonSplashColor,
      textColor: colors.buttonTextColor,
      child: const Text('Cancel'),
    );
    final spacer = dims.isPortrait
        ? SizedBox(height: dims.height * 0.05)
        : SizedBox(width: dims.width * 0.1);
    final children = <Widget>[saveButton, spacer, cancelButton];

    return dims.isPortrait
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.center, children: children)
        : Row(mainAxisAlignment: MainAxisAlignment.center, children: children);
  }
}
