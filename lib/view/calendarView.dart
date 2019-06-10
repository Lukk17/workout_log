import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:table_calendar/table_calendar.dart';

import 'helloWorldView.dart';

class CalendarView extends StatefulWidget {
  final Function(Widget) callback;

  CalendarView(this.callback);

  @override
  State<StatefulWidget> createState() => _Calendar();
}

class _Calendar extends State<CalendarView> {
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
                  color: Colors.red,
                  child: Text("Go to date.."),
                ),
              ),
              _spacer(10),
              Center(
                child: MaterialButton(
                  height: 50,
                  minWidth: 75,
                  onPressed: _today,
                  color: Colors.red,
                  child: Text("Go to today"),
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
                    color: Colors.red,
                  ),
                  rightChevronIcon: Icon(
                    Icons.arrow_forward,
                    color: Colors.red,
                  ),
                  formatButtonVisible: false),
            ),
          ),
          Center(
            child: MaterialButton(
              height: 50,
              minWidth: 150,
              onPressed: _save,
              color: Colors.red,
              child: Text("Save"),
            ),
          ),
        ],
      ),
    );
  }

  _setDate() {
    DatePicker.showDatePicker(context,
        currentTime: DateTime.now(), onConfirm: (date) => _saveDate(date));
  }

  _today() {
    _saveDate(DateTime.now());
  }

  _saveDate(DateTime date) {
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
