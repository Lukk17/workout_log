import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:workout_log/presentation/providers/selected_date_provider.dart';
import 'package:workout_log/presentation/theme/workout_colors.dart';
import 'package:workout_log/util/util.dart';

DateTime _startOfDay(DateTime d) => DateTime(d.year, d.month, d.day);

class CalendarView extends ConsumerStatefulWidget {
  final Function(Widget) callback;
  final Orientation screenOrientation;

  const CalendarView(this.callback, this.screenOrientation, {super.key});

  @override
  ConsumerState<CalendarView> createState() => _CalendarViewState();
}

class _CalendarViewState extends ConsumerState<CalendarView> {
  late DateTime _selected;

  final Logger _log = Logger('CalendarView');

  double _screenHeight = 0;
  double _screenWidth = 0;
  bool _isPortraitOrientation = false;

  double _dialogHeightPortrait = 0;
  double _dialogHeightLandscape = 0;
  double _dialogWidth = 0;
  double _naviButtonHeightPortrait = 0;
  double _naviButtonHeightLandscape = 0;
  double _naviButtonWidth = 0;
  double _saveButtonHeightPortrait = 0;
  double _saveButtonWidthPortrait = 0;
  double _saveButtonHeightLandscape = 0;
  double _saveButtonWidthLandscape = 0;
  double _calendarRowHeightPortrait = 0;
  double _calendarRowHeightLandscape = 0;

  void setupDimensions() {
    _screenHeight = Util.getScreenHeight(context);
    _screenWidth = Util.getScreenWidth(context);

    _dialogHeightPortrait = _screenHeight * 0.71;
    _dialogHeightLandscape = _screenHeight * 0.8;
    _dialogWidth = _screenWidth;

    _naviButtonHeightPortrait = _screenHeight * 0.07;
    _naviButtonHeightLandscape = _screenHeight * 0.1;
    _naviButtonWidth = _screenWidth * 0.07;
    _saveButtonHeightPortrait = _screenHeight * 0.07;
    _saveButtonWidthPortrait = _screenWidth * 0.4;
    _saveButtonHeightLandscape = _screenHeight * 0.1;
    _saveButtonWidthLandscape = _screenWidth * 0.2;
    _calendarRowHeightPortrait = _screenHeight * 0.07;
    _calendarRowHeightLandscape = _screenHeight * 0.09;
  }

  @override
  void initState() {
    super.initState();
    _selected = ref.read(selectedDateProvider);
    _isPortraitOrientation = widget.screenOrientation == Orientation.portrait;
    Util.blockOrientation(_isPortraitOrientation);
  }

  @override
  void dispose() {
    Util.unlockOrientation();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    setupDimensions();
    final colors = WorkoutColors.of(context);

    return SizedBox(
      width: _dialogWidth,
      height: _isPortraitOrientation
          ? _dialogHeightPortrait
          : _dialogHeightLandscape,
      child: _isPortraitOrientation
          ? Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    _naviButton(colors, name: 'Go to date..', onPressed: _setDate),
                    SizedBox(width: _screenHeight * 0.02, height: _screenHeight * 0.02),
                    _naviButton(colors, name: 'Go to today', onPressed: _today),
                  ],
                ),
                SizedBox(width: _screenHeight * 0.02, height: _screenHeight * 0.02),
                Flexible(child: _tabCalendar(colors)),
                Center(child: _saveButton(colors)),
              ],
            )
          : Row(
              children: <Widget>[
                SizedBox(width: _screenWidth * 0.01),
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Column(
                      children: <Widget>[
                        _naviButton(colors, name: 'Go to date..', onPressed: _setDate),
                        SizedBox(height: _screenHeight * 0.03),
                        _naviButton(colors, name: 'Go to today', onPressed: _today),
                      ],
                    ),
                    _saveButton(colors),
                  ],
                ),
                Expanded(child: _tabCalendar(colors)),
              ],
            ),
    );
  }

  Widget _naviButton(WorkoutColors colors,
      {required VoidCallback onPressed, required String name}) {
    return Center(
      child: MaterialButton(
        height: _isPortraitOrientation
            ? _naviButtonHeightPortrait
            : _naviButtonHeightLandscape,
        minWidth: _naviButtonWidth,
        onPressed: onPressed,
        color: colors.buttonColor,
        child: Text(name, style: TextStyle(color: colors.buttonTextColor)),
      ),
    );
  }

  Widget _saveButton(WorkoutColors colors) {
    return MaterialButton(
      height: _isPortraitOrientation
          ? _saveButtonHeightPortrait
          : _saveButtonHeightLandscape,
      minWidth: _isPortraitOrientation
          ? _saveButtonWidthPortrait
          : _saveButtonWidthLandscape,
      onPressed: _save,
      color: colors.greenButtonColor,
      child: Text(
        'Save',
        style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: colors.buttonTextColor),
      ),
    );
  }

  Widget _tabCalendar(WorkoutColors colors) {
    return TableCalendar(
      rowHeight: _isPortraitOrientation
          ? _calendarRowHeightPortrait
          : _calendarRowHeightLandscape,
      locale: 'en_US',
      onDaySelected: (day, focusedDay) => _selectedDate(day),
      selectedDayPredicate: (day) => isSameDay(_selected, day),
      startingDayOfWeek: StartingDayOfWeek.monday,
      headerStyle: HeaderStyle(
        leftChevronIcon:
            Icon(Icons.arrow_back, color: colors.previousButton),
        rightChevronIcon:
            Icon(Icons.arrow_forward, color: colors.nextButton),
        formatButtonVisible: false,
      ),
      focusedDay: _selected,
      firstDay: DateTime(2000),
      lastDay: DateTime(2100),
    );
  }

  Future<void> _setDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _selected) {
      setState(() => _selected = picked);
    }
  }

  void _today() {
    setState(() => _selected = DateTime.now());
  }

  void _selectedDate(DateTime day) {
    setState(() => _selected = day);
  }

  void _save() {
    final normalized = _startOfDay(_selected);
    ref.read(selectedDateProvider.notifier).state = normalized;
    _log.fine('Chosen date: $normalized');
    Navigator.pop(context);
  }
}
