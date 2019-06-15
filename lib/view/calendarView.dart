import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:workout_log/setting/appTheme.dart';

import 'helloWorldView.dart';

class CalendarView extends StatefulWidget {
  final Function(Widget) callback;

  CalendarView(this.callback);

  @override
  State<StatefulWidget> createState() => _CalendarViewState();
}

class _CalendarViewState extends State<CalendarView> {
  DateTime _selected = HelloWorldView.date;

  @override
  Widget build(BuildContext context) {
    return _create(context);
  }

  Widget _create(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height * 0.6,
      child: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Center(
                child: MaterialButton(
                  height: 50,
                  minWidth: 75,
                  onPressed: _setDate,
                  color: AppThemeSettings.buttonColor,
                  child: Text(
                    "Go to date..",
                    style: TextStyle(color: AppThemeSettings.buttonTextColor),
                  ),
                ),
              ),
              _spacer(10),
              Center(
                child: MaterialButton(
                  height: 50,
                  minWidth: 75,
                  onPressed: _today,
                  color: AppThemeSettings.buttonColor,
                  child: Text(
                    "Go to today",
                    style: TextStyle(color: AppThemeSettings.buttonTextColor),
                  ),
                ),
              ),
            ],
          ),
          _spacer(10),
          Expanded(
            child: TableCalendar(
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
            ),
          ),
          Center(
            child: MaterialButton(
              height: 50,
              minWidth: 150,
              onPressed: _save,
              color: AppThemeSettings.greenButtonColor,
              child: Text(
                "Save",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
            ),
          ),
        ],
      ),
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

  static Widget _spacer(double size) {
    return Container(margin: EdgeInsets.all(size));
  }
}
