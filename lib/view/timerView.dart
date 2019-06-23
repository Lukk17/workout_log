import 'dart:async';

import 'package:audioplayers/audio_cache.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:workout_log/setting/appTheme.dart';

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
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
//            _spacer(MediaQuery.of(context).size.height * 0.03),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                MaterialButton(
                  height: MediaQuery.of(context).size.height * 0.06,
                  minWidth: MediaQuery.of(context).size.width * 0.09,
                  onPressed: () {
                    _displayTime(30);
                  },
                  textColor: AppThemeSettings.buttonTextColor,
                  color: AppThemeSettings.buttonColor,
                  child: Text("30 sec"),
                ),
                MaterialButton(
                  height: MediaQuery.of(context).size.height * 0.06,
                  minWidth: MediaQuery.of(context).size.width * 0.09,
                  onPressed: () {
                    _displayTime(60);
                  },
                  textColor: AppThemeSettings.buttonTextColor,
                  color: AppThemeSettings.buttonColor,
                  child: Text("1 min"),
                ),
                MaterialButton(
                  height: MediaQuery.of(context).size.height * 0.06,
                  minWidth: MediaQuery.of(context).size.width * 0.09,
                  onPressed: () {
                    _displayTime(60.0 * 3);
                  },
                  textColor: AppThemeSettings.buttonTextColor,
                  color: AppThemeSettings.buttonColor,
                  child: Text("3 min"),
                ),
                MaterialButton(
                  height: MediaQuery.of(context).size.height * 0.06,
                  minWidth: MediaQuery.of(context).size.width * 0.09,
                  onPressed: () {
                    _displayTime(60.0 * 5);
                  },
                  textColor: AppThemeSettings.buttonTextColor,
                  color: AppThemeSettings.buttonColor,
                  child: Text("5 min"),
                )
              ],
            ),
            Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[

                  FittedBox(
                    child: Column(children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          _spacerSelectable(
                              left: MediaQuery.of(context).size.width * 0.4),
                          Center(
                            child: Text(
                              "H",
                              style: TextStyle(
                                  fontSize:
                                      MediaQuery.of(context).size.width * 0.2,
                                  color: AppThemeSettings.timerColor),
                            ),
                          ),
                          _spacerSelectable(
                              left: MediaQuery.of(context).size.width * 0.4),
                          Center(
                            child: Text(
                              "M",
                              style: TextStyle(
                                  fontSize:
                                      MediaQuery.of(context).size.width * 0.2,
                                  color: AppThemeSettings.timerColor),
                            ),
                          ),
                          _spacerSelectable(
                              left: MediaQuery.of(context).size.width * 0.5),
                          Center(
                            child: Text(
                              "S",
                              style: TextStyle(
                                  fontSize:
                                      MediaQuery.of(context).size.width * 0.2,
                                  color: AppThemeSettings.timerColor),
                            ),
                          ),
                          _spacerSelectable(
                              left: MediaQuery.of(context).size.width * 0.6),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          _spacer(MediaQuery.of(context).size.width * 0.04),
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
                              width: MediaQuery.of(context).size.width * 0.5,
                              child: Center(
                                child: Text(
                                  _hour.toString(),
                                  style: TextStyle(
                                      fontSize:
                                          MediaQuery.of(context).size.width *
                                              0.4,
                                      color: AppThemeSettings.timerColor),
                                ),
                              ),
                            ),
                          ),
                          Text(
                            ":",
                            style: TextStyle(
                                fontSize:
                                    MediaQuery.of(context).size.width * 0.4,
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
                              _minute =
                                  _changeTime(time: _minute, dragUp: dragUp);
                              setState(() {
                                _timer = _minute * 60.0;
                              });
                            },
                            child: SizedBox(
                              width: MediaQuery.of(context).size.width * 0.5,
                              child: Center(
                                child: Text(
                                  _minute.toString(),
                                  style: TextStyle(
                                      fontSize:
                                          MediaQuery.of(context).size.width *
                                              0.4,
                                      color: AppThemeSettings.timerColor),
                                ),
                              ),
                            ),
                          ),
                          Text(
                            ":",
                            style: TextStyle(
                                fontSize:
                                    MediaQuery.of(context).size.width * 0.4,
                                color: AppThemeSettings.timerColor),
                          ),
                          _spacer(15),
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
                              _sec = _changeTime(
                                      time: _sec.toInt(), dragUp: dragUp)
                                  .floorToDouble();
                              setState(() {
                                _timer = _sec;
                              });
                            },
                            child: SizedBox(
                              width: MediaQuery.of(context).size.width * 0.8,
                              child: Center(
                                child: Row(
                                  children: <Widget>[
                                    Text(
                                      _sec.toStringAsFixed(1),
                                      style: TextStyle(
                                        fontSize:
                                            MediaQuery.of(context).size.width *
                                                0.4,
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
                  ),
                  _spacer(MediaQuery.of(context).size.height * 0.05),
                  createControlButtons(),
                ])
          ],
        ),
      );
    });
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
                textColor: AppThemeSettings.buttonTextColor,
                color: AppThemeSettings.buttonColor,
                child: Text("Continue"),
              ),
              _spacer(20),
              MaterialButton(
                height: 75,
                minWidth: 150,
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
                          height: 75,
                          minWidth: 150,
                          onPressed: _pauseTimer,
                          textColor: AppThemeSettings.buttonTextColor,
                          color: AppThemeSettings.buttonColor,
                          child: Text("Pause"),
                        ),
                        _spacer(20),
                        MaterialButton(
                          height: 75,
                          minWidth: 150,
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
                      height: 75,
                      minWidth: 150,
                      onPressed: _startTimer,
                      textColor: AppThemeSettings.buttonTextColor,
                      color: AppThemeSettings.buttonColor,
                      child: Text("Start"),
                    ),
            ],
          );
  }

  Widget _spacer(double size) {
    return Container(margin: EdgeInsets.all(size));
  }

  Widget _spacerSelectable(
      {double top, double bottom, double left, double right}) {
    if (top == null) top = 0;
    if (bottom == null) bottom = 0;
    if (left == null) left = 0;
    if (right == null) right = 0;
    return Container(margin: EdgeInsets.fromLTRB(left, top, right, bottom));
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
