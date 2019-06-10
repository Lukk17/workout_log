import 'package:flutter/material.dart';
import 'package:workout_log/view/calendarView.dart';
import 'package:workout_log/view/timerView.dart';
import 'package:workout_log/view/workLogPageView.dart';

class HelloWorldView extends StatefulWidget {
  static DateTime date = DateTime.now();

  HelloWorldView({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application.
  // Fields in a Widget subclass are always marked "final".
  final String title;

  // override to manually creates private (starting with _ ) subclass
  // to update state of counter widget
  @override
  _HelloWorldViewState createState() => _HelloWorldViewState();
}

class _HelloWorldViewState extends State<HelloWorldView> {
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
        Tab(
          text: "statistic",
          icon: Icon(Icons.assessment),
        ),
      ],
    );
  }

  Widget _createBody() {
    return TabBarView(children: [
      // calling builder to get callback (Widget)
      WorkLogPageView((widget) => {}, HelloWorldView.date),
      TimerView((widget) => {}),
      Center(),
    ]);
  }

  _openCalendar() {
    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
            children: <Widget>[
              CalendarView((widget) => {}),
            ],
          ),
    );
    print('openCalendar');
  }

  updateDate() {}

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
}
