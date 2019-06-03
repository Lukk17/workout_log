import 'package:flutter/material.dart';
import 'package:workout_log/util/TimerBuilder.dart';
import 'package:workout_log/util/calendar.dart';
import 'package:workout_log/view/bodyPartLogView.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'entity/bodyPart.dart';

void main() {
  initializeDateFormatting().then((_)=> runApp(MyApp()));
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.

  static const String _TITLE = "It is your time !";

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData.dark(
//        in normal ThemeData:
//        primarySwatch: Colors.red,
          ),
      home: HelloWorldPage(title: _TITLE),
    );
  }
}

class HelloWorldPage extends StatefulWidget {
  HelloWorldPage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application.
  // Fields in a Widget subclass are always marked "final".
  final String title;

  // override to manually creates private (starting with _ ) subclass
  // to update state of counter widget
  @override
  _HelloWorldPageState createState() => _HelloWorldPageState();
}

class _HelloWorldPageState extends State<HelloWorldPage> {
  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: _createAppBar(),
        body: _createBody(),
      ),
    );
  }

  Widget _createAppBar() {
    return AppBar(
      // Here we take the value from the MyHomePage object that was created by
      // the App.build method, and use it to set our appbar title.
      title: Text(widget.title),
      backgroundColor: Colors.red,
      bottom: TabBar(
        tabs: <Widget>[
          Tab(text: "log"),
          Tab(text: "calendar"),
          Tab(text: "timer")
        ],
      ),
    );
  }

  Widget _createBody() {
    return TabBarView(children: [
      Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Column(
            children: <Widget>[
              _createCategoryButton('chest', BodyPart.CHEST),
              _spacer(15),
              _createCategoryButton('back', BodyPart.BACK),
              _spacer(15),
              _createCategoryButton('arm', BodyPart.ARM),
              _spacer(15),
              _createCategoryButton('leg', BodyPart.LEG),
            ],
          )
        ],
      ),
      Center(
          child: Calendar.create()),
      // calling builder to get callback (Widget) and send it to _buildTimer
      TimerBuilder(_buildTimer),
    ]);
  }

  _buildTimer(Widget widget) {
    return widget;
  }

  Widget _createCategoryButton(String text, BodyPart bodyPart) {
    MaterialButton cb = MaterialButton(
      // after pushing button, navigate to a new screen
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                BodyPartLogView(date: DateTime.now(), bodyPart: bodyPart),
          ),
        );
      },
      height: 60,
      minWidth: 350,
      color: Colors.red,
      child: Text(text),
    );
    return cb;
  }

  Widget _spacer(double size) {
    return Container(margin: EdgeInsets.all(size));
  }
}
