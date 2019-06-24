import 'dart:async';

import 'package:audioplayers/audio_cache.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:workout_log/setting/appTheme.dart';
import 'package:workout_log/util/util.dart';

class TimerView extends StatefulWidget {
  // send back build widget
  final Function(Widget) callback;

  // constructor with callback to calling view
  TimerView(this.callback);

  @override
  State<StatefulWidget> createState() => _TimerViewState();
}

class _TimerViewState extends State<TimerView> {
  int _hour = 0;
  int _minute = 0;
  double _sec = 0.0;
  double _timer = 0;
  double timerCache = 0;
  bool run = false;
  bool pause = false;
  double position = 0;
  bool dragUp = true;
  Orientation screenOrientation;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(AppThemeSettings.timerBackground),
          fit: BoxFit.cover,
        ),
      ),
      child: _createTimer(),
    );
  }

  Widget _createTimer() {
    return OrientationBuilder(builder: (context, orientation) {
      screenOrientation = orientation;
      if (orientation == Orientation.portrait) {
        //  portrait
        //  orientation
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  createTimeButton(timeText: "30 sec", seconds: 30),
                  createTimeButton(timeText: "1 min", seconds: 60),
                  createTimeButton(timeText: "3 min", seconds: 60.0 * 3),
                  createTimeButton(timeText: "5 min", seconds: 60.0 * 5),
                ],
              ),
              Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    createTimer(scale: 1),
                    Util.spacer(MediaQuery.of(context).size.height * 0.05),
                    createControlButtons(scale: 1),
                  ])
            ],
          ),
        );

        // landscape
        // orientation
      } else {
        return Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    createTimeButton(timeText: "30 sec", seconds: 30),
                    createTimeButton(timeText: "3 min", seconds: 60.0 * 3),
                  ]),
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  createTimeButton(timeText: "1 min", seconds: 60),
                  createTimeButton(timeText: "5 min", seconds: 60.0 * 5),
                ],
              ),
              Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    createTimer(scale: 0.25),
                    createControlButtons(scale: 0.4),
                  ])
            ],
          ),
        );
      }
    });
  }

  Widget createTimer({@required double scale}) {
    return FittedBox(
      child: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Util.spacerSelectable(
                  left: MediaQuery.of(context).size.width * 0.4 * scale),
              Center(
                child: Text(
                  "H",
                  style: TextStyle(
                      fontSize: MediaQuery.of(context).size.width * 0.2 * scale,
                      color: AppThemeSettings.timerColor),
                ),
              ),
              Util.spacerSelectable(
                  left: MediaQuery.of(context).size.width * 0.4 * scale),
              Center(
                child: Text(
                  "M",
                  style: TextStyle(
                      fontSize: MediaQuery.of(context).size.width * 0.2 * scale,
                      color: AppThemeSettings.timerColor),
                ),
              ),
              Util.spacerSelectable(
                  left: MediaQuery.of(context).size.width * 0.5 * scale),
              Center(
                child: Text(
                  "S",
                  style: TextStyle(
                      fontSize: MediaQuery.of(context).size.width * 0.2 * scale,
                      color: AppThemeSettings.timerColor),
                ),
              ),
              Util.spacerSelectable(
                  left: MediaQuery.of(context).size.width * 0.6 * scale),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Util.spacer(MediaQuery.of(context).size.width * 0.04 * scale),
              GestureDetector(
                //  compare start dy position with updated one
                onVerticalDragStart: (data) {
                  position = data.globalPosition.dy;
                },
                onVerticalDragUpdate: (data) {
                  if (position > data.globalPosition.dy) {
                    dragUp = true;
                  } else {
                    dragUp = false;
                  }
                },
                onVerticalDragEnd: (data) {
                  // when dragging end read final dragUp bool and make action
                  _hour = _changeHour(time: _hour, dragUp: dragUp);
                  setState(() {
                    _timer = _hour * 60.0 * 60.0;
                  });
                },
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.5 * scale,
                  child: Center(
                    child: Text(
                      _hour.toString(),
                      style: TextStyle(
                          fontSize:
                              MediaQuery.of(context).size.width * 0.4 * scale,
                          color: AppThemeSettings.timerColor),
                    ),
                  ),
                ),
              ),
              Text(
                ":",
                style: TextStyle(
                    fontSize: MediaQuery.of(context).size.width * 0.4 * scale,
                    color: AppThemeSettings.timerColor),
              ),
              GestureDetector(
                //  compare start dy position with updated one
                onVerticalDragStart: (data) {
                  position = data.globalPosition.dy;
                },
                onVerticalDragUpdate: (data) {
                  if (position > data.globalPosition.dy) {
                    dragUp = true;
                  } else {
                    dragUp = false;
                  }
                },
                onVerticalDragEnd: (data) {
                  // when dragging end read final dragUp bool and make action
                  _minute = _changeTime(time: _minute, dragUp: dragUp);
                  setState(() {
                    _timer = _minute * 60.0;
                  });
                },
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.5 * scale,
                  child: Center(
                    child: Text(
                      _minute.toString(),
                      style: TextStyle(
                          fontSize:
                              MediaQuery.of(context).size.width * 0.4 * scale,
                          color: AppThemeSettings.timerColor),
                    ),
                  ),
                ),
              ),
              Text(
                ":",
                style: TextStyle(
                    fontSize: MediaQuery.of(context).size.width * 0.4 * scale,
                    color: AppThemeSettings.timerColor),
              ),
              Util.spacer(15),
              GestureDetector(
                //  compare start dy position with updated one
                onVerticalDragStart: (data) {
                  position = data.globalPosition.dy;
                },
                onVerticalDragUpdate: (data) {
                  if (position > data.globalPosition.dy) {
                    dragUp = true;
                  } else {
                    dragUp = false;
                  }
                },
                onVerticalDragEnd: (data) {
                  // when dragging end read final dragUp bool and make action
                  _sec = _changeTime(time: _sec.toInt(), dragUp: dragUp)
                      .floorToDouble();
                  setState(() {
                    _timer = _sec;
                  });
                },
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.8 * scale,
                  child: Center(
                    child: Row(
                      children: <Widget>[
                        Text(
                          _sec.toStringAsFixed(1),
                          style: TextStyle(
                            fontSize:
                                MediaQuery.of(context).size.width * 0.4 * scale,
                            color: AppThemeSettings.timerColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget createTimeButton(
      {@required String timeText, @required double seconds}) {
    return MaterialButton(
      height: (screenOrientation == Orientation.portrait)
          ? MediaQuery.of(context).size.height * 0.06
          : MediaQuery.of(context).size.height * 0.15,
      minWidth: MediaQuery.of(context).size.width * 0.15,
      onPressed: () {
        _displayTime(seconds);
      },
      textColor: AppThemeSettings.buttonTextColor,
      color: AppThemeSettings.buttonColor,
      child: Text(timeText),
    );
  }

  Widget createControlButtons({@required double scale}) {
    return pause
        ?
        //  if paused show "Continue" and "Reset" buttons
        Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              MaterialButton(
                height: (screenOrientation == Orientation.portrait)
                    ? MediaQuery.of(context).size.height * 0.08
                    : MediaQuery.of(context).size.height * 0.15,
                minWidth: MediaQuery.of(context).size.width * 0.4 * scale,
                //  if timer is running pause it if not start it
                onPressed: run ? _pauseTimer : _startTimer,
                textColor: AppThemeSettings.buttonTextColor,
                color: AppThemeSettings.buttonColor,
                child: Text("Continue"),
              ),
              Util.spacer(MediaQuery.of(context).size.width * 0.04),
              MaterialButton(
                height: (screenOrientation == Orientation.portrait)
                    ? MediaQuery.of(context).size.height * 0.08
                    : MediaQuery.of(context).size.height * 0.15,
                minWidth: MediaQuery.of(context).size.width * 0.4 * scale,
                onPressed: _resetTimer,
                textColor: AppThemeSettings.buttonTextColor,
                color: AppThemeSettings.buttonColor,
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
                          height: (screenOrientation == Orientation.portrait)
                              ? MediaQuery.of(context).size.height * 0.08
                              : MediaQuery.of(context).size.height * 0.15,
                          minWidth:
                              MediaQuery.of(context).size.width * 0.4 * scale,
                          onPressed: _pauseTimer,
                          textColor: AppThemeSettings.buttonTextColor,
                          color: AppThemeSettings.buttonColor,
                          child: Text("Pause"),
                        ),
                        Util.spacer(MediaQuery.of(context).size.width * 0.04),
                        MaterialButton(
                          height: (screenOrientation == Orientation.portrait)
                              ? MediaQuery.of(context).size.height * 0.08
                              : MediaQuery.of(context).size.height * 0.15,
                          minWidth:
                              MediaQuery.of(context).size.width * 0.4 * scale,
                          onPressed: _stopTimer,
                          textColor: AppThemeSettings.buttonTextColor,
                          color: AppThemeSettings.buttonColor,
                          child: Text("Stop"),
                        )
                      ],
                    )
                  :
                  //  if not running show "Start" button
                  MaterialButton(
                      height: (screenOrientation == Orientation.portrait)
                          ? MediaQuery.of(context).size.height * 0.08
                          : MediaQuery.of(context).size.height * 0.15,
                      minWidth: MediaQuery.of(context).size.width * 0.6 * scale,
                      onPressed: _startTimer,
                      textColor: AppThemeSettings.buttonTextColor,
                      color: AppThemeSettings.buttonColor,
                      child: Text("Start"),
                    ),
            ],
          );
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
    const duration = const Duration(milliseconds: 100);

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
                      _timer = _timer - 0.1;
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

  int _changeTime({@required int time, @required bool dragUp}) {
    if (dragUp) {
      if (time == 59) {
        time = 0;
      } else {
        time++;
      }
    } else {
      if (time == 0) {
        time = 59;
      } else {
        time--;
      }
    }
    return time;
  }

  int _changeHour({@required int time, @required bool dragUp}) {
    if (dragUp) {
      if (time == 99) {
        time = 0;
      } else {
        time++;
      }
    } else {
      if (time == 0) {
        time = 99;
      } else {
        time--;
      }
    }
    return time;
  }
}
