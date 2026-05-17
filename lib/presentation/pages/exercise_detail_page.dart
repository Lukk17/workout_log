import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:workout_log/util/log.dart';
import 'package:workout_log/data/db/work_log_dao.dart';
import 'package:workout_log/domain/models/body_part.dart';
import 'package:workout_log/domain/models/work_log.dart';
import 'package:workout_log/presentation/providers/data_providers.dart';
import 'package:workout_log/presentation/theme/workout_colors.dart';
import 'package:workout_log/presentation/util/responsive.dart';
import 'package:workout_log/presentation/widgets/responsive_scaffold.dart';

import 'exercise_form_page.dart';

/// This is most detailed view for each WorkLog.
///
/// In Tab bar there is body part name and date.
/// Main view have name of exercise,
/// below it series and repeats in each series shown as table.
class ExerciseDetailPage extends ConsumerStatefulWidget {
  final WorkLog workLog;

  const ExerciseDetailPage({super.key, required this.workLog});

  @override
  ConsumerState<ExerciseDetailPage> createState() => _ExerciseDetailPageState();
}

class _ExerciseDetailPageState extends ConsumerState<ExerciseDetailPage> {
  WorkLogDao get _workLogDao => ref.read(workLogDaoProvider);
  static const _tag = 'ExerciseDetailPage';

  /// The page owns a local copy of the workLog so mutations can be applied
  /// via copyWith without mutating the immutable freezed instance passed in
  /// from the parent. The parent route is responsible for re-fetching from
  /// the DB on pop (via workLogsByDateProvider invalidation).
  late WorkLog _workLog;

  @override
  void initState() {
    super.initState();
    _workLog = widget.workLog;
  }

  /// Derived layout for this page. Computed once per build from the
  /// inherited [ResponsiveDimensions], then passed (or read off
  /// `_layout`) by helpers. Replaces a previous set of 13 mutable late
  /// fields that were re-set on every build.
  late _Layout _layout;

  @override
  Widget build(BuildContext context) {
    return ResponsiveScaffold(
      appBarBuilder: (context, dims) {
        _layout = _Layout.from(dims);
        return PreferredSize(
          preferredSize: Size.fromHeight(dims.appBarHeight),
          child: AppBar(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                /// created date of this log
                Container(
                  width: _layout.screenWidth * 0.3,
                  child: Text(
                    _workLog.created.toIso8601String().substring(0, 10),
                    textAlign: TextAlign.end,
                    style:
                        TextStyle(color: WorkoutColors.of(context).titleColor),
                  ),
                ),
              ],
            ),
            backgroundColor: WorkoutColors.of(context).appBarColor,
          ),
        );
      },
      body: Builder(builder: (context) {
        _layout = _Layout.from(ResponsiveDimensions.of(context));
        final wList = _createRowsForSeries();
        return Column(
          children: <Widget>[

            /// exercise name
            GestureDetector(
              onLongPress: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            ExerciseFormPage(
                              exercise: _workLog.exercise,
                            )));
              },
              child: Container(
                height: _layout.isPortrait
                    ? _layout.exerciseHeightPortrait
                    : _layout.exerciseHeightLandscape,
                width: _layout.exerciseWidth,
                alignment: FractionalOffset(0.5, 0.5),
                child: Text(
                  _workLog.exercise.name,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: WorkoutColors.of(context).textColor,
                    fontSize: WorkoutTypography.headerSize,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: _getAllBodyParts(_workLog),
            ),

            /// table header
            Row(
              children: <Widget>[
                Container(
                  height: _layout.isPortrait
                      ? _layout.portraitColumnHeight
                      : _layout.headerLandscapeColumnHeight,

                  width: _layout.seriesColumnWidth,
                  alignment: FractionalOffset(0.5, 0.5),
                  child: Text(
                    "series",
                    style: TextStyle(
                      color: WorkoutColors.of(context).textColor,
                      fontSize: WorkoutTypography.fontSize,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  height: _layout.isPortrait
                      ? _layout.portraitColumnHeight
                      : _layout.headerLandscapeColumnHeight,

                  width: _layout.columnWidth,
                  alignment: FractionalOffset(0.5, 0.5),
                  child: Text(
                    "load",
                    style: TextStyle(
                      color: WorkoutColors.of(context).textColor,
                      fontSize: WorkoutTypography.fontSize,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  height: _layout.isPortrait
                      ? _layout.portraitColumnHeight
                      : _layout.headerLandscapeColumnHeight,

                  width: _layout.columnWidth,
                  alignment: FractionalOffset(0.5, 0.5),
                  child: Text(
                    "repeats",
                    style: TextStyle(
                      color: WorkoutColors.of(context).textColor,
                      fontSize: WorkoutTypography.fontSize,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            Divider(indent: _layout.screenWidth * 0.05, endIndent: _layout.screenWidth * 0.05, color: WorkoutColors.of(context).borderColor),

            /// list view builder create series
            Expanded(
              child: ListView.builder(
                itemCount: wList.length,
                itemBuilder: (BuildContext context, int index) {
                  return wList[index];
                },
                //  nested listView need to shrink to size of its children
                //  if not shrieked it will be infinite in size and can't be render
                shrinkWrap: true,
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

  /// Creates row for every recorder set, with divider at the bottom
  /// Slidable widget show action when user slide every row
  List<Widget> _createRowsForSeries() {
    List<Widget> wList = <Widget>[];
    List keys = _workLog.series.keys.toList();

    for (int i = 0; i < keys.length; i++) {
      wList.add(
          Slidable(
            key: ValueKey(keys[i]), // Ensure unique key
            startActionPane: ActionPane(
              motion: const ScrollMotion(),
              extentRatio: 0.25,
              children: [
                Container(
                  margin: EdgeInsets.only(
                      bottom: _layout.screenHeight * 0.01,
                      top: _layout.screenHeight * 0.01,
                      left: _layout.screenWidth * 0.01,
                      right: _layout.screenWidth * 0.01),
                  child: SlidableAction(
                    onPressed: (context) => _deleteSeries(i),
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
                  margin: EdgeInsets.only(
                      bottom: _layout.screenHeight * 0.01,
                      top: _layout.screenHeight * 0.01,
                      left: _layout.screenWidth * 0.01,
                      right: _layout.screenWidth * 0.01),
                  child: SlidableAction(
                    onPressed: (context) => _editLoadDialog(keys[i]).then((v) {
                      SystemChrome.setPreferredOrientations([
                        DeviceOrientation.landscapeRight,
                        DeviceOrientation.landscapeLeft,
                        DeviceOrientation.portraitUp,
                        DeviceOrientation.portraitDown,
                      ]);
                    }),
                    backgroundColor: Colors.yellow,
                    foregroundColor: Colors.black,
                    icon: Icons.edit,
                    label: 'Edit load',
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(
                      bottom: _layout.screenHeight * 0.01,
                      top: _layout.screenHeight * 0.01,
                      left: _layout.screenWidth * 0.01,
                      right: _layout.screenWidth * 0.01),
                  child: SlidableAction(
                    onPressed: (context) => _editRepeatsDialog(i.toString()).then((v) {
                      SystemChrome.setPreferredOrientations([
                        DeviceOrientation.landscapeRight,
                        DeviceOrientation.landscapeLeft,
                        DeviceOrientation.portraitUp,
                        DeviceOrientation.portraitDown,
                      ]);
                    }),
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    icon: Icons.edit,
                    label: 'Edit repeats',
                  ),
                ),
              ],
            ),
            child: Row(
              children: <Widget>[
                Container(
                  height: _layout.isPortrait
                      ? _layout.portraitColumnHeight
                      : _layout.landscapeColumnHeight,
                  width: _layout.seriesColumnWidth,
                  alignment: FractionalOffset(0.5, 0.5),
                  child: Center(
                    child: Text(
                      i.toString(),
                      style: TextStyle(
                        color: WorkoutColors.of(context).textColor,
                        fontSize: WorkoutTypography.fontSize,
                      ),
                    ),
                  ),
                ),
                Container(
                  height: _layout.isPortrait
                      ? _layout.portraitColumnHeight
                      : _layout.landscapeColumnHeight,
                  width: _layout.columnWidth,
                  alignment: FractionalOffset(0.5, 0.5),
                  child: MaterialButton(
                    child: Text(
                      _workLog.getLoad(keys[i]),
                      style: TextStyle(
                        color: WorkoutColors.of(context).textColor,
                        fontSize: WorkoutTypography.fontSize,
                      ),
                    ),
                    onPressed: () {
                      _editLoadDialog(keys[i]).then((v) {
                        SystemChrome.setPreferredOrientations([
                          DeviceOrientation.landscapeRight,
                          DeviceOrientation.landscapeLeft,
                          DeviceOrientation.portraitUp,
                          DeviceOrientation.portraitDown,
                        ]);
                      });
                    },
                  ),
                ),
                Container(
                  height: _layout.isPortrait
                      ? _layout.portraitColumnHeight
                      : _layout.landscapeColumnHeight,
                  width: _layout.columnWidth,
                  alignment: FractionalOffset(0.5, 0.5),
                  child: MaterialButton(
                    child: Text(
                      _workLog.getReps(keys[i]),
                      style: TextStyle(
                        color: WorkoutColors.of(context).textColor,
                        fontSize: WorkoutTypography.fontSize,
                      ),
                    ),
                    onPressed: () {
                      _editRepeatsDialog(keys[i]).then((v) {
                        SystemChrome.setPreferredOrientations([
                          DeviceOrientation.landscapeRight,
                          DeviceOrientation.landscapeLeft,
                          DeviceOrientation.portraitUp,
                          DeviceOrientation.portraitDown,
                        ]);
                      });
                    },
                  ),
                ),
              ],
            ),
          ),);
      wList.add(
        Divider(indent: _layout.screenWidth * 0.05, endIndent: _layout.screenWidth * 0.05, color: WorkoutColors.of(context).borderColor),
      );
    }

    /// add additional container at bottom for better visibility
    wList.add(
      Container(
        height: _layout.screenHeight * 0.10,
        width: _layout.screenWidth * 0.5,
      ),
    );
    return wList;
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

  void _invalidateParent() {
    ref.invalidate(workLogsByDateProvider(_workLog.created));
  }

  /// shows dialog for editing repeats number
  Future<void> _editRepeatsDialog(String set) {
    return _editSetValueDialog(
      title: 'Edit repeats number',
      currentValue: _workLog.getReps(set),
      apply: (parsed) => _workLog.copyWith(
        series: {..._workLog.series, set: parsed},
      ),
      logLabel: 'Repeats',
    );
  }

  /// shows dialog for editing load value
  Future<void> _editLoadDialog(String set) {
    return _editSetValueDialog(
      title: 'Edit load value',
      currentValue: _workLog.getLoad(set),
      apply: (parsed) => _workLog.copyWith(
        load: {..._workLog.load, set: parsed},
      ),
      logLabel: 'Load',
    );
  }

  /// Shared dialog for editing either reps or load for a single set. The
  /// caller supplies a builder that maps the parsed value to an updated
  /// WorkLog (via copyWith) — no in-place map mutation.
  Future<void> _editSetValueDialog({
    required String title,
    required String currentValue,
    required WorkLog Function(String parsed) apply,
    required String logLabel,
  }) {
    final textEditingController = TextEditingController();

    Util.blockOrientation(_layout.isPortrait);

    final List<Widget> dialogWidgets = <Widget>[
      TextField(
        controller: textEditingController,
        autofocus: true,
        autocorrect: true,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(hintText: currentValue),
        maxLength: 4,
      ),
      Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            MaterialButton(
                color: WorkoutColors.of(context).greenButtonColor,
                child: Text(
                  'SAVE',
                  style: TextStyle(
                      color: WorkoutColors.of(context).buttonTextColor),
                ),
                onPressed: () async {
                  // int.parse throws on non-numeric input — that prevents
                  // saving an invalid value (and surfaces a clear error).
                  final parsed =
                      int.parse(textEditingController.text).toString();
                  final updated = apply(parsed);
                  await _workLogDao.update(updated);
                  if (!mounted) return;
                  setState(() => _workLog = updated);
                  _invalidateParent();
                  logFine('$logLabel changed to $parsed for $updated', name: _tag);
                  Navigator.pop(context);
                }),
            MaterialButton(
                color: WorkoutColors.of(context).cancelButtonColor,
                child: Text(
                  'CANCEL',
                  style: TextStyle(
                      color: WorkoutColors.of(context).buttonTextColor),
                ),
                onPressed: () {
                  Navigator.pop(context);
                }),
          ]),
    ];

    return _showDialog(title, dialogWidgets);
  }

  Future<void> _showDialog(String title, List<Widget> dialogWidgets) {
    return showDialog(
        context: context,
        builder: (_) =>
        _layout.isPortrait
            ? SimpleDialog(
            title: Center(heightFactor: 0.3, child: Text(title)),
            contentPadding: EdgeInsets.all(_layout.screenHeight * 0.02),
            children: dialogWidgets
        )
            : SimpleDialog(
            contentPadding: EdgeInsets.all(_layout.screenHeight * 0.01),

            children: <Widget>[
              Center(heightFactor: 0.3, child: Text(title)),
              dialogWidgets.first,
              dialogWidgets.last,
            ]
        )
    );
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

  /// Removes the entry whose 1-based key equals [removedIndex] and shifts
  /// every higher-indexed entry down by 1, preserving the contiguous
  /// numbering invariant that the rest of the page relies on.
  static Map<String, String> _removeIndexAndShift(
      Map<String, String> source, int removedIndex) {
    final result = <String, String>{};
    source.forEach((key, value) {
      final n = int.parse(key);
      if (n == removedIndex) return; // dropped
      final newKey = n > removedIndex ? (n - 1).toString() : key;
      result[newKey] = value;
    });
    return result;
  }

  List<Widget> _getAllBodyParts(WorkLog workLog) {
    List<Widget> result = <Widget>[];
    result.add(Text("Primary", style: TextStyle(
        color: WorkoutColors.of(context).titleColor,
        fontSize: _layout.isPortrait
            ? _layout.titleFontSizePortrait
            : _layout.titleFontSizeLandscape),));
    result.add(SizedBox(height: _layout.screenHeight * 0.01));
    result.add(
        Column(children: _getBodyPartsBlocks(workLog.exercise.bodyParts)));
    result.add(SizedBox(height: _layout.screenHeight * 0.02));
    result.add(Text("Secondary"));
    result.add(SizedBox(height: _layout.screenHeight * 0.01));
    result.add(Column(
        children: _getBodyPartsBlocks(workLog.exercise.secondaryBodyParts)));
    return result;
  }

  List<Widget> _getBodyPartsBlocks(Set<BodyPart> bodyParts) {
    List<Row> result = <Row>[];
    List<SizedBox> boxes = <SizedBox>[];

    bodyParts.forEach((bp) {
      boxes.add(SizedBox(
        height: _layout.screenHeight * 0.05,
        width: _layout.screenWidth * 0.3,
        child: Container(
          color: Util.getBpColor(bp, WorkoutColors.of(context)),
          child: Center(child: Text(
            Util.getBpName(bp), style: TextStyle(color: Colors.amber),)),
        ),
      ));
    });


    /// when more that 3 body parts is in one exercise
    /// make 2 rows
    if (boxes.length <= 3) {
      result.add(Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: boxes,
      ));
    }
    else {
      List<SizedBox> firstRowBoxes = <SizedBox>[];
      List<SizedBox> secondRowBoxes = <SizedBox>[];

      int counter = 0;
      boxes.forEach((box) {
        counter++;

        if(counter < 4){
          firstRowBoxes.add(box);
        }
        else
          {
            secondRowBoxes.add(box);
          };
      });

      result.add(Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: firstRowBoxes,
      ));
      result.add(Row(children: <Widget>[
        SizedBox(height: _layout.screenHeight * 0.01)
      ],));
      result.add(Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: secondRowBoxes,
      ));
    }
    return result;
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
