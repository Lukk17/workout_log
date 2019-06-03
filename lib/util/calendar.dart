import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:table_calendar/table_calendar.dart';

class Calendar {

  static Widget create(){

     return TableCalendar(
      locale: 'pl_PL',
      headerStyle: HeaderStyle(leftChevronIcon: Icon(Icons.arrow_back, color: Colors.red,),
      rightChevronIcon: Icon(Icons.arrow_forward, color: Colors.red,),
      formatButtonVisible: false,),
    );

  }


}