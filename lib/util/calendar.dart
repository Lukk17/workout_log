import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:table_calendar/table_calendar.dart';

class Calendar extends StatefulWidget {

  final Function(Widget) callback;
  Calendar(this.callback);

  @override
  State<StatefulWidget> createState() => _Calendar();

}
class _Calendar extends State<Calendar> {

  DateTime selectedDay = DateTime.now();
  @override
  Widget build(BuildContext context) {
    return _create();
  }

   Widget _create() {
   return Column(
      children: <Widget>[
        _spacer(20),
        Center(
          child: MaterialButton(
            height: 50,
            minWidth: 75,
            onPressed: _showDialog,
            color: Colors.red,
            child: Text("Pick day"),
          ),
        ),
        _spacer(20),
        Expanded(
            child: TableCalendar(
          locale: 'en_US',
          onDaySelected: _showWorkLog(),
          selectedDay: selectedDay,
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
        ))
      ],
    );
  }

   _showDialog(){
    setState(() {
      DatePicker.showDatePicker(context,
          currentTime: DateTime.now(),
          onConfirm: (date) => selectedDay=date);
    });
  }

  _showWorkLog(){
    print('XX');
  }

  static Widget _spacer(double size) {
    return Container(margin: EdgeInsets.all(size));
  }

}
