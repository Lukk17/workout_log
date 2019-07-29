import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:logging/logging.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:workout_log/setting/appThemeSettings.dart';
import 'package:workout_log/util/util.dart';

import 'helloWorldView.dart';

class CalendarView extends StatefulWidget {
  final Function(Widget) callback;
  final Orientation screenOrientation;

  CalendarView(this.callback, this.screenOrientation);

  @override
  State<StatefulWidget> createState() => _CalendarViewState();
}

/// on initState block screen orientation
/// on dispose unlock screen orientation
class _CalendarViewState extends State<CalendarView> {
  DateTime _selected = HelloWorldView.date;

  final Logger _log = new Logger("CalendarView");

  double _screenHeight;
  double _screenWidth;
  bool _isPortraitOrientation;

  double _dialogHeight;
  double _dialogWidth;
  double _naviButtonHeightPortrait;
  double _naviButtonHeightLandscape;
  double _naviButtonWidth;
  double _saveButtonHeightPortrait;
  double _saveButtonWidthPortrait;
  double _saveButtonHeightLandscape;
  double _saveButtonWidthLandscape;
  double _calendarRowHeightPortrait;
  double _calendarRowHeightLandscape;

  void setupDimensions() {
    _getScreenHeight();
    _getScreenWidth();

    _dialogHeight = _screenHeight * 0.7;
    // this value of width is required by landscape mode to show it correctly
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

    _isPortraitOrientation = widget.screenOrientation == Orientation.portrait;
    Util.blockOrientation(_isPortraitOrientation);
  }

  @override
  dispose() {
    Util.unlockOrientation();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    setupDimensions();

    return _create(context);
  }

  Widget _create(BuildContext context) {
    return Container(
      width: _dialogWidth,
      height: _dialogHeight,
      child: (_isPortraitOrientation)
          ? Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    createNaviButton(name: "Go to date..", onPressed: _setDate),
                    Util.spacer(_screenHeight * 0.01),
                    createNaviButton(name: "Go to today", onPressed: _today),
                  ],
                ),
                Util.spacer(_screenHeight * 0.01),
                Flexible(
                  child: createTabCalendar(),
                ),
                Center(
                  child: createSaveButton(),
                ),
              ],
            )
          : Row(
              children: <Widget>[
                Util.spacerSelectable(left: _screenWidth * 0.01),
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Column(
                      children: <Widget>[
                        createNaviButton(name: "Go to date..", onPressed: _setDate),
                        Util.spacerSelectable(top: _screenHeight * 0.03),
                        createNaviButton(name: "Go to today", onPressed: _today),
                      ],
                    ),
                    createSaveButton(),
                  ],
                ),
                Expanded(
                  child: createTabCalendar(),
                ),
              ],
            ),
    );
  }

  Widget createNaviButton({@required Function onPressed, @required String name}) {
    return Center(
      child: MaterialButton(
        height: _isPortraitOrientation ? _naviButtonHeightPortrait : _naviButtonHeightLandscape,
        minWidth: _naviButtonWidth,
        onPressed: onPressed,
        color: AppThemeSettings.buttonColor,
        child: Text(
          name,
          style: TextStyle(color: AppThemeSettings.buttonTextColor),
        ),
      ),
    );
  }

  Widget createSaveButton() {
    return MaterialButton(
      height: _isPortraitOrientation ? _saveButtonHeightPortrait : _saveButtonHeightLandscape,
      minWidth: _isPortraitOrientation ? _saveButtonWidthPortrait : _saveButtonWidthLandscape,
      onPressed: _save,
      color: AppThemeSettings.greenButtonColor,
      child: Text(
        "Save",
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
      ),
    );
  }

  Widget createTabCalendar() {
    return TableCalendar(
      rowHeight: _isPortraitOrientation ? _calendarRowHeightPortrait : _calendarRowHeightLandscape,
      locale: 'en_US',
      selectedDay: _selected,
      onDaySelected: (day, list) => {_selectedDate(day)},
      startingDayOfWeek: StartingDayOfWeek.monday,
      headerStyle: HeaderStyle(
          leftChevronIcon: Icon(
            Icons.arrow_back,
            color: AppThemeSettings.previousButton,
          ),
          rightChevronIcon: Icon(
            Icons.arrow_forward,
            color: AppThemeSettings.nextButton,
          ),
          formatButtonVisible: false),
    );
  }

  _setDate() {
    DatePicker.showDatePicker(context, currentTime: DateTime.now(), onConfirm: (date) => _pickDate(date));
  }

  _today() {
    _pickDate(DateTime.now());
  }

  _pickDate(DateTime date) {
    setState(() {
      _selected = date;
    });
  }

  _selectedDate(DateTime day) {
    setState(() {
      _selected = day;
    });
    print(day);
  }

  _save() {
    HelloWorldView.date = _selected;

    _log.fine("Choosen date: $_selected");

    Navigator.pop(context);
  }

  _getScreenHeight() {
    _screenHeight = Util.getScreenHeight(context);
  }

  _getScreenWidth() {
    _screenWidth = Util.getScreenWidth(context);
  }
}
