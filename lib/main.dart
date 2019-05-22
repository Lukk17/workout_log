import 'package:flutter/material.dart';
import 'dart:async';

import 'package:workout_log/bodyPart/chest.dart';

import 'entity/bodyPart.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.

  static const String _TITLE = "It is your time !";

  static String get TITLE => _TITLE;

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
  int _counter = 0;

  // update state of widget to increase count value
  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

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
          floatingActionButton: _createFloatingActionButton()),
    );
  }

  Widget _spacer() {
    return Container(margin: EdgeInsets.all(5));
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
      Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Column(
              children: <Widget>[
                _createCategoryButton('chest', BodyPart.CHEST),
                _spacer(),
                _createCategoryButton('back', BodyPart.BACK),
                _spacer(),
                _createCategoryButton('arm', BodyPart.ARM),
                _spacer(),
                _createCategoryButton('leg', BodyPart.LEG),
              ],
            ),
            Text(
              'You have pushed the button this many times:',
              style: TextStyle(color: Colors.red),
            ),
            Text(
              '$_counter',
              style:
                  Theme.of(context).textTheme.display1.apply(color: Colors.red),
            ),
          ],
        ),
      ),
      Center(
          child: Text(
        'calendar',
        style: TextStyle(color: Colors.red),
      )),
      Column(children: <Widget>[
        Center(
          child: Text(
            'timer',
            style: TextStyle(color: Colors.red),
          ),
        ),
      ])
    ]);
  }

  Widget _createFloatingActionButton() {
    return FloatingActionButton(
      onPressed: _incrementCounter,

      // text which will be shown after long press on button
      tooltip: 'Increment',

      child: Icon(Icons.add),
      backgroundColor: Colors.red,
      foregroundColor: Colors.black,
    );
  }

  Widget _createCategoryButton(String text, BodyPart bodyPart) {
    MaterialButton cb = MaterialButton(
      // after pushing button, navigate to a new screen
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Chest(date: DateTime.now(), bodyPart: bodyPart),
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
}
