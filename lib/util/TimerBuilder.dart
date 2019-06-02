import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';

import 'package:audioplayers/audio_cache.dart';

class TimerBuilder extends StatefulWidget {
  // send back build widget
  final Function(Widget) callback;

  // constructor with callback to calling view
  TimerBuilder(this.callback);

  @override
  State<StatefulWidget> createState() => _TimerBuilderState();
}

class _TimerBuilderState extends State<TimerBuilder> {
  int _hour = 0;
  int _minute = 0;
  double _sec = 0.0;
  double _timer = 0;
  double timerCache = 0;
  bool run = false;
  bool pause = false;

  @override
  Widget build(BuildContext context) {
    return _createTimer();
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
                _displayTime(5);
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
              createControlButtons(),
            ])
      ],
    );
  }

  Widget createControlButtons() {
    return pause
        ?
        //  if paused show "Continue" and "Reset" buttons
        Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              MaterialButton(
                height: 75,
                minWidth: 150,
                //  if timer is running pause it if not start it
                onPressed: run ? _pauseTimer : _startTimer,
                textColor: Colors.white,
                color: Colors.red,
                child: Text("Continue"),
              ),
              _spacer(20),
              MaterialButton(
                height: 75,
                minWidth: 150,
                onPressed: _resetTimer,
                textColor: Colors.white,
                color: Colors.red,
                child: Text("Reset"),
              )
            ],
          )
        :
        // if not paused:
        Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              run
                  ?
                  //  if running show "Pause" and "Stop" buttons
                  Row(
                      children: <Widget>[
                        MaterialButton(
                          height: 75,
                          minWidth: 150,
                          onPressed: _pauseTimer,
                          textColor: Colors.white,
                          color: Colors.red,
                          child: Text("Pause"),
                        ),
                        _spacer(20),
                        MaterialButton(
                          height: 75,
                          minWidth: 150,
                          onPressed: _stopTimer,
                          textColor: Colors.white,
                          color: Colors.red,
                          child: Text("Stop"),
                        )
                      ],
                    )
                  :
                  //  if not running show "Start" button
                  MaterialButton(
                      height: 75,
                      minWidth: 150,
                      onPressed: _startTimer,
                      textColor: Colors.white,
                      color: Colors.red,
                      child: Text("Start"),
                    ),
            ],
          );
  }

  void _customTimer() {
    //  parse string date without time to get 0 h, 0 min, 0 sec in time picker
    DatePicker.showTimePicker(context, currentTime: DateTime.parse("20120227"),
        onConfirm: (date) {
      _displayTime(
          (date.second + date.minute * 60 + date.hour * 60 * 60).toDouble());
    });
  }

  Widget _spacer(double size) {
    return Container(margin: EdgeInsets.all(size));
  }

  void _displayTime(double time) {
    setState(() {
      _timer = time;
      // check if there is more than or equal to one minute
      if (time / 60 >= 1) {
        // check if there is more than one hour
        if (time / (60 * 60) >= 1) {
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

  int _startTimer() {
    //  if paused do not save time to cache
    if (!pause) {
      timerCache = _timer;
    }
    run = true;
    pause = false;
    const duration = const Duration(milliseconds: 1);

    Timer.periodic(
      duration,
      (Timer t) => setState(
            () {
              if (run) {
                if (_timer < 0.1) {
                  _timer = 0;
                  run = false;
                  _displayTime(_timer);
                  _startAlarm();
                  t.cancel();
                } else {
                  setState(
                    () {
                      _timer = _timer - 0.001;
                      _displayTime(_timer);
                    },
                  );
                }
              } else {
                t.cancel();
              }
            },
          ),
    );
    return 0;
  }

  void _stopTimer() {
    run = false;
    _timer = timerCache;
    _displayTime(_timer);
  }

  void _resetTimer() {
    //  reset start button text to "Start" (from "Continue")
    pause = false;

    run = false;
    _timer = timerCache;
    _displayTime(_timer);
  }

  void _pauseTimer() {
    run = false;
    pause = true;
  }

  _startAlarm() {
    SystemSound.play(SystemSoundType.click);
    AudioCache player = AudioCache();
    player.play('CarHornAlarm.mp3');
  }
}
