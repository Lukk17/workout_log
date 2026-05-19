import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workout_log/domain/models/work_log.dart';
import 'package:workout_log/presentation/pages/exercise_detail/detail_table_layout.dart';
import 'package:workout_log/presentation/pages/exercise_detail/widgets/body_parts_section.dart';
import 'package:workout_log/presentation/pages/exercise_detail/widgets/detail_app_bar.dart';
import 'package:workout_log/presentation/pages/exercise_detail/widgets/exercise_name_header.dart';
import 'package:workout_log/presentation/pages/exercise_detail/widgets/series_row.dart';
import 'package:workout_log/presentation/pages/exercise_detail/widgets/set_value_dialog.dart';
import 'package:workout_log/presentation/pages/exercise_detail/widgets/table_header_row.dart';
import 'package:workout_log/presentation/pages/exercise_form/exercise_form_page.dart';
import 'package:workout_log/presentation/providers/exercise_detail_provider.dart';
import 'package:workout_log/presentation/theme/workout_colors.dart';
import 'package:workout_log/presentation/util/system_chrome.dart';
import 'package:workout_log/presentation/widgets/responsive_scaffold.dart';

class ExerciseDetailPage extends ConsumerWidget {
  const ExerciseDetailPage({super.key, required this.workLog});

  final WorkLog workLog;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(exerciseDetailProvider(workLog));
    final notifier = ref.read(exerciseDetailProvider(workLog).notifier);

    return ResponsiveScaffold(
      appBarBuilder: (context, dims) =>
          DetailAppBar(workLog: current, layout: DetailTableLayout.from(dims)),
      body: Builder(
        builder: (context) {
          final layout = DetailTableLayout.from(
            ResponsiveDimensions.of(context),
          );

          return _DetailBody(
            workLog: current,
            layout: layout,
            onEditExercise: () => _openEditExercise(context, current),
            onEditLoad: (setKey) => _openEditDialog(
              context,
              EditField.load,
              setKey,
              current,
              notifier,
              layout,
            ),
            onEditRepeats: (setKey) => _openEditDialog(
              context,
              EditField.repeats,
              setKey,
              current,
              notifier,
              layout,
            ),
            onDeleteSeries: notifier.deleteSeries,
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Add series',
        onPressed: notifier.addSeries,
        backgroundColor: WorkoutColors.of(context).buttonColor,
        foregroundColor: WorkoutColors.of(context).secondaryColor,
        child: Icon(
          Icons.add,
          color: WorkoutColors.of(context).buttonTextColor,
        ),
      ),
    );
  }

  void _openEditExercise(BuildContext context, WorkLog current) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ExerciseFormPage(exercise: current.exercise),
      ),
    );
  }

  Future<void> _openEditDialog(
    BuildContext context,
    EditField field,
    String setKey,
    WorkLog current,
    ExerciseDetailNotifier notifier,
    DetailTableLayout layout,
  ) async {
    blockOrientation(portrait: layout.isPortrait);

    final result = await showDialog<String>(
      context: context,
      builder: (_) => SetValueDialog(
        title: field == EditField.load
            ? 'Edit load value'
            : 'Edit repeats number',
        hint: field == EditField.load
            ? current.getLoad(setKey)
            : current.getReps(setKey),
        isPortrait: layout.isPortrait,
        screenHeight: layout.screenHeight,
      ),
    );

    unlockOrientation();

    if (result == null) {
      return;
    }

    if (field == EditField.load) {
      await notifier.editLoad(setKey, result);
    } else {
      await notifier.editRepeats(setKey, result);
    }
  }
}

class _DetailBody extends StatelessWidget {
  const _DetailBody({
    required this.workLog,
    required this.layout,
    required this.onEditExercise,
    required this.onEditLoad,
    required this.onEditRepeats,
    required this.onDeleteSeries,
  });

  final WorkLog workLog;
  final DetailTableLayout layout;
  final VoidCallback onEditExercise;
  final ValueChanged<String> onEditLoad;
  final ValueChanged<String> onEditRepeats;
  final ValueChanged<int> onDeleteSeries;

  @override
  Widget build(BuildContext context) {
    final keys = workLog.series.keys.toList();
    final borderColor = WorkoutColors.of(context).borderColor;

    return Column(
      children: <Widget>[
        ExerciseNameHeader(
          workLog: workLog,
          layout: layout,
          onEdit: onEditExercise,
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            BodyPartsSection(workLog: workLog, layout: layout),
          ],
        ),
        TableHeaderRow(layout: layout),
        Divider(
          indent: layout.screenWidth * 0.05,
          endIndent: layout.screenWidth * 0.05,
          color: borderColor,
        ),
        Expanded(
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: keys.length * 2 + 1,
            itemBuilder: (context, index) {
              if (index == keys.length * 2) {
                return SizedBox(
                  height: layout.screenHeight * 0.10,
                  width: layout.screenWidth * 0.5,
                );
              }

              final isDivider = index.isOdd;
              final keyIndex = index ~/ 2;

              if (isDivider) {
                return Divider(
                  indent: layout.screenWidth * 0.05,
                  endIndent: layout.screenWidth * 0.05,
                  color: borderColor,
                );
              }

              final setKey = keys[keyIndex];

              return SeriesRow(
                index: keyIndex,
                setKey: setKey,
                workLog: workLog,
                layout: layout,
                onDelete: () => onDeleteSeries(keyIndex),
                onEditLoad: () => onEditLoad(setKey),
                onEditRepeats: () => onEditRepeats(setKey),
              );
            },
          ),
        ),
      ],
    );
  }
}
