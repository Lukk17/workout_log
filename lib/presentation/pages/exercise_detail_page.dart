import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:workout_log/data/db/work_log_dao.dart';
import 'package:workout_log/domain/models/body_part.dart';
import 'package:workout_log/domain/models/work_log.dart';
import 'package:workout_log/presentation/pages/exercise_form_page.dart';
import 'package:workout_log/presentation/providers/data_providers.dart';
import 'package:workout_log/presentation/theme/workout_colors.dart';
import 'package:workout_log/presentation/util/responsive.dart';
import 'package:workout_log/presentation/widgets/responsive_scaffold.dart';
import 'package:workout_log/util/log.dart';

class ExerciseDetailPage extends ConsumerStatefulWidget {
  final WorkLog workLog;

  const ExerciseDetailPage({super.key, required this.workLog});

  @override
  ConsumerState<ExerciseDetailPage> createState() => _ExerciseDetailPageState();
}

class _ExerciseDetailPageState extends ConsumerState<ExerciseDetailPage> {
  static const _tag = 'ExerciseDetailPage';

  // Local copy edited via copyWith; parent route refetches on pop.
  late WorkLog _workLog;
  late _Layout _layout;

  WorkLogDao get _workLogDao => ref.read(workLogDaoProvider);

  @override
  void initState() {
    super.initState();
    _workLog = widget.workLog;
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveScaffold(
      appBarBuilder: (context, dims) {
        _layout = _Layout.from(dims);
        return _DetailAppBar(workLog: _workLog, layout: _layout);
      },
      body: Builder(builder: (context) {
        _layout = _Layout.from(ResponsiveDimensions.of(context));
        final keys = _workLog.series.keys.toList();
        return Column(
          children: <Widget>[
            _ExerciseNameHeader(
              workLog: _workLog,
              layout: _layout,
              onEdit: _openEditExercise,
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                _BodyPartsSection(workLog: _workLog, layout: _layout),
              ],
            ),
            _TableHeaderRow(layout: _layout),
            Divider(
              indent: _layout.screenWidth * 0.05,
              endIndent: _layout.screenWidth * 0.05,
              color: WorkoutColors.of(context).borderColor,
            ),
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: keys.length * 2 + 1,
                itemBuilder: (context, index) {
                  if (index == keys.length * 2) {
                    return SizedBox(
                      height: _layout.screenHeight * 0.10,
                      width: _layout.screenWidth * 0.5,
                    );
                  }
                  final isDivider = index.isOdd;
                  final keyIndex = index ~/ 2;
                  if (isDivider) {
                    return Divider(
                      indent: _layout.screenWidth * 0.05,
                      endIndent: _layout.screenWidth * 0.05,
                      color: WorkoutColors.of(context).borderColor,
                    );
                  }
                  return _SeriesRow(
                    index: keyIndex,
                    setKey: keys[keyIndex],
                    workLog: _workLog,
                    layout: _layout,
                    onDelete: () => _deleteSeries(keyIndex),
                    onEditLoad: () => _openEditDialog(_EditField.load, keys[keyIndex]),
                    onEditRepeats: () =>
                        _openEditDialog(_EditField.repeats, keys[keyIndex]),
                  );
                },
              ),
            ),
          ],
        );
      }),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Add series',
        onPressed: _addSeriesToWorkLog,
        backgroundColor: WorkoutColors.of(context).buttonColor,
        foregroundColor: WorkoutColors.of(context).secondaryColor,
        child:
            Icon(Icons.add, color: WorkoutColors.of(context).buttonTextColor),
      ),
    );
  }

  void _openEditExercise() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ExerciseFormPage(exercise: _workLog.exercise),
      ),
    );
  }

  Future<void> _openEditDialog(_EditField field, String setKey) async {
    Util.blockOrientation(_layout.isPortrait);
    final result = await showDialog<String>(
      context: context,
      builder: (_) => _SetValueDialog(
        title: field == _EditField.load ? 'Edit load value' : 'Edit repeats number',
        hint: field == _EditField.load
            ? _workLog.getLoad(setKey)
            : _workLog.getReps(setKey),
        isPortrait: _layout.isPortrait,
        screenHeight: _layout.screenHeight,
      ),
    );
    Util.unlockOrientation();
    if (!mounted || result == null) return;

    final updated = field == _EditField.load
        ? _workLog.copyWith(load: {..._workLog.load, setKey: result})
        : _workLog.copyWith(series: {..._workLog.series, setKey: result});
    await _workLogDao.update(updated);
    if (!mounted) return;
    setState(() => _workLog = updated);
    _invalidateParent();
    logFine('${field.name} changed to $result for $updated', name: _tag);
  }

  Future<void> _addSeriesToWorkLog() async {
    final newIndex = (_workLog.series.length + 1).toString();
    final updated = _workLog.copyWith(
      series: {..._workLog.series, newIndex: '0'},
      load: {..._workLog.load, newIndex: '0'},
    );
    await _workLogDao.update(updated);
    if (!mounted) return;
    setState(() => _workLog = updated);
    _invalidateParent();
    logFine('Series added to: $updated', name: _tag);
  }

  Future<void> _deleteSeries(int i) async {
    final rebuilt = _workLog.copyWith(
      series: _removeIndexAndShift(_workLog.series, i),
      load: _removeIndexAndShift(_workLog.load, i),
    );
    await _workLogDao.update(rebuilt);
    if (!mounted) return;
    setState(() => _workLog = rebuilt);
    _invalidateParent();
    logFine('Series number $i deleted from $rebuilt', name: _tag);
  }

  static Map<String, String> _removeIndexAndShift(
      Map<String, String> source, int removedIndex) {
    final result = <String, String>{};
    source.forEach((key, value) {
      final n = int.parse(key);
      if (n == removedIndex) return;
      final newKey = n > removedIndex ? (n - 1).toString() : key;
      result[newKey] = value;
    });
    return result;
  }

  void _invalidateParent() {
    ref.invalidate(workLogsByDateProvider(_workLog.created));
  }
}

enum _EditField { load, repeats }

class _DetailAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _DetailAppBar({required this.workLog, required this.layout});

  final WorkLog workLog;
  final _Layout layout;

  @override
  Size get preferredSize =>
      Size.fromHeight(layout.isPortrait ? layout.screenHeight * 0.08 : layout.screenHeight * 0.1);

  @override
  Widget build(BuildContext context) {
    final colors = WorkoutColors.of(context);
    return AppBar(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          SizedBox(
            width: layout.screenWidth * 0.3,
            child: Text(
              workLog.created.toIso8601String().substring(0, 10),
              textAlign: TextAlign.end,
              style: TextStyle(color: colors.titleColor),
            ),
          ),
        ],
      ),
      backgroundColor: colors.appBarColor,
    );
  }
}

class _ExerciseNameHeader extends StatelessWidget {
  const _ExerciseNameHeader({
    required this.workLog,
    required this.layout,
    required this.onEdit,
  });

  final WorkLog workLog;
  final _Layout layout;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final colors = WorkoutColors.of(context);
    return GestureDetector(
      onLongPress: onEdit,
      child: Container(
        height: layout.isPortrait
            ? layout.exerciseHeightPortrait
            : layout.exerciseHeightLandscape,
        width: layout.exerciseWidth,
        alignment: const FractionalOffset(0.5, 0.5),
        child: Text(
          workLog.exercise.name,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: colors.textColor,
            fontSize: WorkoutTypography.headerSize,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class _TableHeaderRow extends StatelessWidget {
  const _TableHeaderRow({required this.layout});

  final _Layout layout;

  @override
  Widget build(BuildContext context) {
    final colors = WorkoutColors.of(context);
    final height = layout.isPortrait
        ? layout.portraitColumnHeight
        : layout.headerLandscapeColumnHeight;
    Widget cell(String text, double width) => Container(
          height: height,
          width: width,
          alignment: const FractionalOffset(0.5, 0.5),
          child: Text(
            text,
            style: TextStyle(
              color: colors.textColor,
              fontSize: WorkoutTypography.fontSize,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
    return Row(
      children: <Widget>[
        cell('series', layout.seriesColumnWidth),
        cell('load', layout.columnWidth),
        cell('repeats', layout.columnWidth),
      ],
    );
  }
}

class _SeriesRow extends StatelessWidget {
  const _SeriesRow({
    required this.index,
    required this.setKey,
    required this.workLog,
    required this.layout,
    required this.onDelete,
    required this.onEditLoad,
    required this.onEditRepeats,
  });

  final int index;
  final String setKey;
  final WorkLog workLog;
  final _Layout layout;
  final VoidCallback onDelete;
  final VoidCallback onEditLoad;
  final VoidCallback onEditRepeats;

  @override
  Widget build(BuildContext context) {
    final cellHeight = layout.isPortrait
        ? layout.portraitColumnHeight
        : layout.landscapeColumnHeight;
    final actionMargin = EdgeInsets.symmetric(
      vertical: layout.screenHeight * 0.01,
      horizontal: layout.screenWidth * 0.01,
    );

    return Slidable(
      key: ValueKey(setKey),
      startActionPane: ActionPane(
        motion: const ScrollMotion(),
        extentRatio: 0.25,
        children: [
          Container(
            margin: actionMargin,
            child: SlidableAction(
              onPressed: (_) => onDelete(),
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              icon: Icons.delete,
              label: 'Delete',
            ),
          ),
        ],
      ),
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        extentRatio: 0.25,
        children: [
          Container(
            margin: actionMargin,
            child: SlidableAction(
              onPressed: (_) => onEditLoad(),
              backgroundColor: Colors.yellow,
              foregroundColor: Colors.black,
              icon: Icons.edit,
              label: 'Edit load',
            ),
          ),
          Container(
            margin: actionMargin,
            child: SlidableAction(
              onPressed: (_) => onEditRepeats(),
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              icon: Icons.edit,
              label: 'Edit repeats',
            ),
          ),
        ],
      ),
      child: _SeriesRowBody(
        index: index,
        load: workLog.getLoad(setKey),
        reps: workLog.getReps(setKey),
        cellHeight: cellHeight,
        layout: layout,
        onEditLoad: onEditLoad,
        onEditRepeats: onEditRepeats,
      ),
    );
  }
}

class _SeriesRowBody extends StatelessWidget {
  const _SeriesRowBody({
    required this.index,
    required this.load,
    required this.reps,
    required this.cellHeight,
    required this.layout,
    required this.onEditLoad,
    required this.onEditRepeats,
  });

  final int index;
  final String load;
  final String reps;
  final double cellHeight;
  final _Layout layout;
  final VoidCallback onEditLoad;
  final VoidCallback onEditRepeats;

  @override
  Widget build(BuildContext context) {
    final colors = WorkoutColors.of(context);
    final cellStyle = TextStyle(
      color: colors.textColor,
      fontSize: WorkoutTypography.fontSize,
    );

    Widget cell({required double width, required Widget child}) => Container(
          height: cellHeight,
          width: width,
          alignment: const FractionalOffset(0.5, 0.5),
          child: child,
        );

    return Row(
      children: <Widget>[
        cell(
          width: layout.seriesColumnWidth,
          child: Center(child: Text(index.toString(), style: cellStyle)),
        ),
        cell(
          width: layout.columnWidth,
          child: MaterialButton(
            onPressed: onEditLoad,
            child: Text(load, style: cellStyle),
          ),
        ),
        cell(
          width: layout.columnWidth,
          child: MaterialButton(
            onPressed: onEditRepeats,
            child: Text(reps, style: cellStyle),
          ),
        ),
      ],
    );
  }
}

class _BodyPartsSection extends StatelessWidget {
  const _BodyPartsSection({required this.workLog, required this.layout});

  final WorkLog workLog;
  final _Layout layout;

  @override
  Widget build(BuildContext context) {
    final colors = WorkoutColors.of(context);
    return Column(
      children: <Widget>[
        Text(
          'Primary',
          style: TextStyle(
            color: colors.titleColor,
            fontSize: layout.isPortrait
                ? layout.titleFontSizePortrait
                : layout.titleFontSizeLandscape,
          ),
        ),
        SizedBox(height: layout.screenHeight * 0.01),
        _BodyPartBlocks(parts: workLog.exercise.bodyParts, layout: layout),
        SizedBox(height: layout.screenHeight * 0.02),
        const Text('Secondary'),
        SizedBox(height: layout.screenHeight * 0.01),
        _BodyPartBlocks(
            parts: workLog.exercise.secondaryBodyParts, layout: layout),
      ],
    );
  }
}

class _BodyPartBlocks extends StatelessWidget {
  const _BodyPartBlocks({required this.parts, required this.layout});

  final Set<BodyPart> parts;
  final _Layout layout;

  @override
  Widget build(BuildContext context) {
    final colors = WorkoutColors.of(context);
    final blocks = parts
        .map((bp) => SizedBox(
              height: layout.screenHeight * 0.05,
              width: layout.screenWidth * 0.3,
              child: Container(
                color: Util.getBpColor(bp, colors),
                child: Center(
                  child: Text(
                    Util.getBpName(bp),
                    style: const TextStyle(color: Colors.amber),
                  ),
                ),
              ),
            ))
        .toList();

    if (blocks.length <= 3) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: blocks,
      );
    }
    return Column(
      children: <Widget>[
        Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: blocks.take(3).toList()),
        SizedBox(height: layout.screenHeight * 0.01),
        Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: blocks.skip(3).toList()),
      ],
    );
  }
}

class _SetValueDialog extends StatefulWidget {
  const _SetValueDialog({
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
  State<_SetValueDialog> createState() => _SetValueDialogState();
}

class _SetValueDialogState extends State<_SetValueDialog> {
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
          child:
              Text('CANCEL', style: TextStyle(color: colors.buttonTextColor)),
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

class _Layout {
  const _Layout._({
    required this.screenHeight,
    required this.screenWidth,
    required this.isPortrait,
    required this.exerciseHeightPortrait,
    required this.exerciseHeightLandscape,
    required this.exerciseWidth,
    required this.columnWidth,
    required this.seriesColumnWidth,
    required this.headerLandscapeColumnHeight,
    required this.portraitColumnHeight,
    required this.landscapeColumnHeight,
    required this.titleFontSizePortrait,
    required this.titleFontSizeLandscape,
  });

  factory _Layout.from(ResponsiveDimensions dims) => _Layout._(
        screenHeight: dims.height,
        screenWidth: dims.width,
        isPortrait: dims.isPortrait,
        exerciseHeightPortrait: dims.height * 0.1,
        exerciseHeightLandscape: dims.height * 0.15,
        exerciseWidth: dims.width,
        columnWidth: dims.width * 0.375,
        seriesColumnWidth: dims.width * 0.25,
        headerLandscapeColumnHeight: dims.height * 0.15,
        portraitColumnHeight: dims.height * 0.1,
        landscapeColumnHeight: dims.height * 0.17,
        titleFontSizePortrait: dims.width * 0.055,
        titleFontSizeLandscape: dims.width * 0.03,
      );

  final double screenHeight;
  final double screenWidth;
  final bool isPortrait;
  final double exerciseHeightPortrait;
  final double exerciseHeightLandscape;
  final double exerciseWidth;
  final double columnWidth;
  final double seriesColumnWidth;
  final double headerLandscapeColumnHeight;
  final double portraitColumnHeight;
  final double landscapeColumnHeight;
  final double titleFontSizePortrait;
  final double titleFontSizeLandscape;
}
