import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:workout_log/util/TimerBuilder.dart';
import 'package:workout_log/util/calendar.dart';
import 'package:workout_log/view/bodyPartLogView.dart';

import 'entity/bodyPart.dart';

void main() {
  initializeDateFormatting().then((_) => runApp(MyApp()));
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
        bottomNavigationBar: _createTabBar(),
        drawer: _openSettings(),
      ),
    );
  }

  Widget _createAppBar() {
    return AppBar(
      // Here we take the value from the MyHomePage object that was created by
      // the App.build method, and use it to set our appbar title.
      title: Text(widget.title),
      backgroundColor: Colors.red,
      actions: <Widget>[
        MaterialButton(
          padding: EdgeInsets.all(5),
          onPressed: _openCalendar,
          child: Column(
            children: <Widget>[
              Icon(Icons.calendar_today),
              Text("Calendar"),
            ],
          ),
        )
      ],
    );
  }

  Widget _createTabBar() {
    return TabBar(
      tabs: <Widget>[
        Tab(
          text: "log",
          icon: Icon(Icons.assignment),
        ),
        Tab(
          text: "timer",
          icon: Icon(Icons.timer),
        ),
        Tab(text: "calendar"),
      ],
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
              _spacer(15),
              _createCategoryButton('abdominal', BodyPart.ABDOMINAL),
              _spacer(15),
              _createCategoryButton('all'),
            ],
          )
        ],
      ),
      // calling builder to get callback (Widget) and send it to _buildTimer
      TimerBuilder(_buildTimer),
      Center(child: Calendar(_buildCalendar)),
    ]);
  }

  _buildTimer(Widget widget) {
    return widget;
  }

  _openCalendar() {
    print('openCalendar');
  }

  _openSettings() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            child: Text("Settings"),
          ),
          ListTile(
            title: Text("close"),
            onTap: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  _buildCalendar(Widget widget) {
    return widget;
  }

  /// Creates button routing to BodyPartLogView
  ///
  /// BodyPart is optional due to option for showing all exercises
  /// on any body part
  Widget _createCategoryButton(String text, [BodyPart bodyPart]) {
    /// if method is called without [bodyPart],
    /// then it is set to [BodyPart.UNDEFINED],
    /// which lead to show workLogs from all body parts
    if (bodyPart == null) bodyPart = BodyPart.UNDEFINED;

    MaterialButton cb = MaterialButton(
      // after pushing button, navigate to a new screen
      onPressed: () {
        bodyPart == BodyPart.UNDEFINED
            ? Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BodyPartLogView(
                      date: DateTime.now(), bodyPart: BodyPart.UNDEFINED),
                ),
              )
            : Navigator.push(
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
