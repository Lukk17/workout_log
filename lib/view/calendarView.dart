import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
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

  @override
  void initState() {
    super.initState();
    if (widget.screenOrientation == Orientation.landscape) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeRight,
        DeviceOrientation.landscapeLeft,
      ]);
    } else {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
    }
  }

  @override
  dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _create(context);
  }

  Widget _create(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height * 0.7,
      child: (widget.screenOrientation == Orientation.portrait)
          ? Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    createNaviButton(name: "Go to date..", onPressed: _setDate),
                    Util.spacer(MediaQuery.of(context).size.height * 0.01),
                    createNaviButton(name: "Go to today", onPressed: _today),
                  ],
                ),
                Util.spacer(MediaQuery.of(context).size.height * 0.01),
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
                Util.spacerSelectable(
                    left: MediaQuery.of(context).size.width * 0.01,
                    right: 0,
                    bottom: 0,
                    top: 0),
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Column(
                      children: <Widget>[
                        createNaviButton(
                            name: "Go to date..", onPressed: _setDate),
                        Util.spacerSelectable(
                            top: MediaQuery.of(context).size.height * 0.03,
                            bottom: 0,
                            left: 0,
                            right: 0),
                        createNaviButton(
                            name: "Go to today", onPressed: _today),
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

  Widget createNaviButton(
      {@required Function onPressed, @required String name}) {
    return Center(
      child: MaterialButton(
        height: (widget.screenOrientation == Orientation.portrait)
            ? MediaQuery.of(context).size.height * 0.07
            : MediaQuery.of(context).size.height * 0.1,
        minWidth: MediaQuery.of(context).size.height * 0.07,
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
      height: (widget.screenOrientation == Orientation.portrait)
          ? MediaQuery.of(context).size.height * 0.07
          : MediaQuery.of(context).size.height * 0.1,
      minWidth: (widget.screenOrientation == Orientation.portrait)
          ? MediaQuery.of(context).size.width * 0.4
          : MediaQuery.of(context).size.width * 0.2,
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
      rowHeight: (widget.screenOrientation == Orientation.portrait)
          ? MediaQuery.of(context).size.height * 0.07
          : MediaQuery.of(context).size.height * 0.09,
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
    DatePicker.showDatePicker(context,
        currentTime: DateTime.now(), onConfirm: (date) => _pickDate(date));
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
    Navigator.pop(context);
  }

}
