import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workout_log/data/db/work_log_dao.dart';
import 'package:workout_log/domain/models/work_log.dart';
import 'package:workout_log/presentation/pages/exercise_detail/detail_table_layout.dart';
import 'package:workout_log/presentation/pages/exercise_detail/widgets/body_parts_section.dart';
import 'package:workout_log/presentation/pages/exercise_detail/widgets/detail_app_bar.dart';
import 'package:workout_log/presentation/pages/exercise_detail/widgets/exercise_name_header.dart';
import 'package:workout_log/presentation/pages/exercise_detail/widgets/series_row.dart';
import 'package:workout_log/presentation/pages/exercise_detail/widgets/set_value_dialog.dart';
import 'package:workout_log/presentation/pages/exercise_detail/widgets/table_header_row.dart';
import 'package:workout_log/presentation/pages/exercise_form/exercise_form_page.dart';
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
  late DetailTableLayout _layout;

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
        _layout = DetailTableLayout.from(dims);
        return DetailAppBar(workLog: _workLog, layout: _layout);
      },
      body: Builder(builder: (context) {
        _layout = DetailTableLayout.from(ResponsiveDimensions.of(context));
        final keys = _workLog.series.keys.toList();
        return Column(
          children: <Widget>[
            ExerciseNameHeader(
              workLog: _workLog,
              layout: _layout,
              onEdit: _openEditExercise,
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                BodyPartsSection(workLog: _workLog, layout: _layout),
              ],
            ),
            TableHeaderRow(layout: _layout),
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
                  return SeriesRow(
                    index: keyIndex,
                    setKey: keys[keyIndex],
                    workLog: _workLog,
                    layout: _layout,
                    onDelete: () => _deleteSeries(keyIndex),
                    onEditLoad: () =>
                        _openEditDialog(EditField.load, keys[keyIndex]),
                    onEditRepeats: () =>
                        _openEditDialog(EditField.repeats, keys[keyIndex]),
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

  Future<void> _openEditDialog(EditField field, String setKey) async {
    Util.blockOrientation(_layout.isPortrait);
    final result = await showDialog<String>(
      context: context,
      builder: (_) => SetValueDialog(
        title: field == EditField.load ? 'Edit load value' : 'Edit repeats number',
        hint: field == EditField.load
            ? _workLog.getLoad(setKey)
            : _workLog.getReps(setKey),
        isPortrait: _layout.isPortrait,
        screenHeight: _layout.screenHeight,
      ),
    );
    Util.unlockOrientation();
    if (!mounted || result == null) return;

    final updated = field == EditField.load
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
