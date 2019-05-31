import 'dart:async';

import 'package:flutter/material.dart';
import 'package:workout_log/view/bodyPartLogView.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';

import 'entity/bodyPart.dart';

void main() => runApp(MyApp());

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
  int _hour = 0;
  int _minute = 0;
  double _sec = 0.0;
  double timer = 0;

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
          child: Text(
        'calendar',
        style: TextStyle(color: Colors.red),
      )),
      _createTimer(),
    ]);
  }

  Widget _createTimer() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        _spacer(20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            MaterialButton(
              height: 50,
              minWidth: 70,
              onPressed: () {
                _displayTime(60 * 60 * 60 + 688.0);
              },
              textColor: Colors.white,
              color: Colors.red,
              child: Text("30 sec"),
            ),
            _spacer(10),
            MaterialButton(
              height: 50,
              minWidth: 70,
              onPressed: () {
                _displayTime(60);
              },
              textColor: Colors.white,
              color: Colors.red,
              child: Text("1 min"),
            ),
            _spacer(10),
            MaterialButton(
              height: 50,
              minWidth: 70,
              onPressed: () {
                _displayTime(60.0 * 3);
              },
              textColor: Colors.white,
              color: Colors.red,
              child: Text("3 min"),
            ),
            _spacer(10),
            MaterialButton(
              height: 50,
              minWidth: 70,
              onPressed: () {
                _displayTime(60.0 * 5);
              },
              textColor: Colors.white,
              color: Colors.red,
              child: Text("5 min"),
            )
          ],
        ),
        _spacer(10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            MaterialButton(
              height: 50,
              minWidth: 140,
              onPressed: () {
                _customTimer();
              },
              textColor: Colors.white,
              color: Colors.red,
              child: Text("Custom.."),
            )
          ],
        ),
        _spacer(30),
        Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                width: 350,
                child: FittedBox(
                  child: Column(children: <Widget>[
                    Row(
                      children: <Widget>[
                        Center(
                          child: Text(
                            "Hours",
                            style: TextStyle(fontSize: 50),
                          ),
                        ),
                        _spacer(130),
                        Center(
                          child: Text(
                            "Minutes",
                            style: TextStyle(fontSize: 50),
                          ),
                        ),
                        _spacer(130),
                        Center(
                          child: Text(
                            "Seconds",
                            style: TextStyle(fontSize: 50),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: <Widget>[
                        SizedBox(
                          width: 200,
                          child: Center(
                            child: Text(
                              _hour.toString(),
                              style: TextStyle(fontSize: 150),
                            ),
                          ),
                        ),
                        _spacer(25),
                        Text(
                          ":",
                          style: TextStyle(fontSize: 150),
                        ),
                        _spacer(50),
                        SizedBox(
                          width: 200,
                          child: Center(
                            child: Text(
                              _minute.toString(),
                              style: TextStyle(fontSize: 150),
                            ),
                          ),
                        ),
                        _spacer(25),
                        Text(
                          ":",
                          style: TextStyle(fontSize: 150),
                        ),
                        _spacer(50),
                        SizedBox(
                          width: 300,
                          child: Center(
                            child: Text(
                              _sec.toStringAsFixed(1),
                              style: TextStyle(fontSize: 150),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ]),
                ),
              ),
              _spacer(30),
              MaterialButton(
                height: 75,
                minWidth: 200,
                onPressed: _startTimer,
                textColor: Colors.white,
                color: Colors.red,
                child: Text("Start"),
              )
            ])
      ],
    );
  }

  void _displayTime(double time) {
    setState(() {
      timer = time;
      // check if there is more than or equal to one minute
      if (time / 60 >= 1) {
        // check if there is more than one hour
        if (time / (60 * 60) > 1) {
          _hour = (time / (60 * 60)).floor();
          _minute = ((time - (_hour * 60 * 60)) / 60).floor();
          _sec = (time - (_hour * 60 * 60) - (_minute * 60));

          //  if less than hour:
        } else {
          _hour = 0;
          _minute = (time / 60).floor();
          _sec = (time - (_minute * 60));
        }
      }
      //  if less than minute:
      else {
        _hour = 0;
        _minute = 0;
        _sec = time;
      }
    });
  }

  void _startTimer() {
    const duration = const Duration(milliseconds: 1);
    Timer.periodic(
      duration,
      (Timer t) => setState(
            () {
              if (timer < 1) {
                t.cancel();
              } else {
                setState(() {
                  timer = timer - 0.001;
                  _displayTime(timer);
                });
              }
            },
          ),
    );
  }

  void _customTimer() {

    DatePicker.showTimePicker(context, onConfirm: (date) {
      _displayTime((date.second + date.minute * 60 + date.hour *60 *60).toDouble());
    });

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
