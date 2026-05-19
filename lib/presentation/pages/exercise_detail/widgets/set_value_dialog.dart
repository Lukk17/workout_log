import 'package:flutter/material.dart';
import 'package:workout_log/presentation/theme/workout_colors.dart';

class SetValueDialog extends StatefulWidget {
  const SetValueDialog({
    super.key,
    required this.title,
    required this.hint,
    required this.isPortrait,
    required this.screenHeight,
  });

  final String title;
  final String hint;
  final bool isPortrait;
  final double screenHeight;

  @override
  State<SetValueDialog> createState() => _SetValueDialogState();
}

class _SetValueDialogState extends State<SetValueDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _save() {
    // int.parse throws on non-numeric input — that prevents saving an
    // invalid value and surfaces a clear error.
    final parsed = int.parse(_controller.text).toString();
    Navigator.pop(context, parsed);
  }

  @override
  Widget build(BuildContext context) {
    final colors = WorkoutColors.of(context);
    final input = TextField(
      controller: _controller,
      autofocus: true,
      autocorrect: true,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(hintText: widget.hint),
      maxLength: 4,
    );
    final actions = Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        MaterialButton(
          color: colors.greenButtonColor,
          onPressed: _save,
          child: Text('SAVE', style: TextStyle(color: colors.buttonTextColor)),
        ),
        MaterialButton(
          color: colors.cancelButtonColor,
          onPressed: () => Navigator.pop(context),
          child: Text(
            'CANCEL',
            style: TextStyle(color: colors.buttonTextColor),
          ),
        ),
      ],
    );

    if (widget.isPortrait) {
      return SimpleDialog(
        title: Center(heightFactor: 0.3, child: Text(widget.title)),
        contentPadding: EdgeInsets.all(widget.screenHeight * 0.02),
        children: [input, actions],
      );
    }
    return SimpleDialog(
      contentPadding: EdgeInsets.all(widget.screenHeight * 0.01),
      children: <Widget>[
        Center(heightFactor: 0.3, child: Text(widget.title)),
        input,
        actions,
      ],
    );
  }
}
