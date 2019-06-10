import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:workout_log/view/helloWorldView.dart';

void main() {
  initializeDateFormatting().then((_) => runApp(MyApp()));
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.

  static const String _TITLE = "It is your time !";

  @override
  Widget build(BuildContext context) {
    //  Lock to portrait orientation
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData.dark(
//        in normal ThemeData:
//        primarySwatch: Colors.red,
          ),
      home: HelloWorldView(title: _TITLE),
    );
  }
}
