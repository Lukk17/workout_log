import 'package:audioplayers/audio_cache.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:workout_log/setting/appThemeSettings.dart';
import 'package:workout_log/util/timerPainter.dart';
import 'package:workout_log/util/util.dart';

class TimerView extends StatefulWidget {
  // send back build widget
  final Function(Widget) callback;

  // constructor with callback to calling view
  TimerView(this.callback);

  @override
  State<StatefulWidget> createState() => _TimerViewState();
}

class _TimerViewState extends State<TimerView>
    with SingleTickerProviderStateMixin {
  int _hour = 0;
  int _minute = 0;
  int _sec = 0;
  int _milliseconds = 0;

  int timerCache = 0;
  bool pause = false;
  double position = 0;
  bool dragUp = true;
  Orientation screenOrientation;
  AnimationController animationController;

  @override
  void initState() {
    super.initState();

    animationController = AnimationController(
      vsync: this,
      duration: Duration(
          hours: _hour,
          minutes: _minute,
          seconds: _sec,
          milliseconds: _milliseconds),
    );
    animationController.addListener(() => {
          _displayTime((animationController.duration.inMilliseconds *
                  animationController.value)
              .toInt()),
          if (animationController.value == 0)
            {
              _stopTimer(),
              _startAlarm(),
            },
        });
  }

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
        if (animationController.isAnimating || pause) {
          return Center(
            child: Stack(
              children: <Widget>[
                Positioned.fill(
                    child: AnimatedBuilder(
                        animation: animationController,
                        builder: (BuildContext context, Widget child) {
                          return CustomPaint(
                            painter: TimerCirclePainter(
                                animation: animationController),
                          );
                        })),
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Util.spacer(MediaQuery.of(context).size.height * 0.035),
                    Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          createTimer(scale: 1),
                          Util.spacer(
                              MediaQuery.of(context).size.height * 0.05),
                          createControlButtons(scale: 1),
                        ])
                  ],
                ),
              ],
            ),
          );
        } else {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    createTimeButton(timeText: "30 sec", seconds: 30),
                    createTimeButton(timeText: "1 min", seconds: 60),
                    createTimeButton(timeText: "3 min", seconds: 60 * 3),
                    createTimeButton(timeText: "5 min", seconds: 60 * 5),
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
        }

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
                    createTimeButton(timeText: "3 min", seconds: 60 * 3),
                  ]),
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  createTimeButton(timeText: "1 min", seconds: 60),
                  createTimeButton(timeText: "5 min", seconds: 60 * 5),
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
                  setState(() {});
                },
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.5 * scale,
                  child: Center(
                    child: Text(
                      //  padLeft to add additional 0 to be always same length of string
                      _hour.toString().padLeft(2, "0"),
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
                  setState(() {});
                },
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.5 * scale,
                  child: Center(
                    child: Text(
                      //  padLeft to add additional 0 to be always same length of string
                      _minute.toString().padLeft(2, "0"),
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
                  _sec = _changeTime(time: _sec, dragUp: dragUp);
                  setState(() {});
                },
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.8 * scale,
                  child: Center(
                    child: Row(
                      children: <Widget>[
                        Text(
                          getDecimalSeconds(),
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

  Widget createTimeButton({@required String timeText, @required int seconds}) {
    return MaterialButton(
      height: (screenOrientation == Orientation.portrait)
          ? MediaQuery.of(context).size.height * 0.06
          : MediaQuery.of(context).size.height * 0.15,
      minWidth: MediaQuery.of(context).size.width * 0.15,
      onPressed: () {
        _displayTime(seconds * 1000);
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
                onPressed: _startTimer,
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
              animationController.isAnimating
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
                      onPressed: () => {
                            timerCache = getDuration().inMilliseconds,
                            _startTimer(),
                          },
                      textColor: AppThemeSettings.buttonTextColor,
                      color: AppThemeSettings.buttonColor,
                      child: Text("Start"),
                    ),
            ],
          );
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  void _displayTime(int milliseconds) {
    setState(() {
      //  if more than second
      if (milliseconds / 1000 >= 1) {
        // check if there is more than one minute
        if (milliseconds / (60 * 1000) >= 1) {
          // check if there is more than one hour
          if (milliseconds / (60 * 60 * 1000) >= 1) {
            _hour = (milliseconds / (60 * 60 * 1000)).floor();
            _minute = ((milliseconds - (_hour * 60 * 60 * 1000)) / (60 * 1000))
                .floor();
            _sec = ((milliseconds -
                        (_hour * 60 * 60 * 1000) -
                        (_minute * 60 * 1000)) /
                    1000)
                .floor();
            _milliseconds = ((milliseconds -
                    (_hour * 60 * 60 * 1000) -
                    (_minute * 60 * 1000)) -
                _sec * 1000);

            //  if less than hour:
          } else {
            _hour = 0;
            _minute = (milliseconds / (60 * 1000)).floor();
            _sec = ((milliseconds - (_minute * 60 * 1000)) / 1000).floor();
            _milliseconds =
                ((milliseconds - (_minute * 60 * 1000)) - _sec * 1000);
          }
        }
        //  if less than minute:
        else {
          _hour = 0;
          _minute = 0;
          _sec = (milliseconds / 1000).floor();
          _milliseconds = milliseconds - (_sec * 1000);
        }
      } else {
        _hour = 0;
        _minute = 0;
        _sec = 0;
        _milliseconds = milliseconds;
      }
    });
  }

  Duration getDuration() {
    return Duration(
        hours: _hour,
        minutes: _minute,
        seconds: _sec,
        milliseconds: _milliseconds);
  }

  int _startTimer() {
    animationController.duration = getDuration();
    //  if paused do not save time to cache
    if (pause) {
      animationController.duration = Duration(milliseconds: timerCache);
    }
    pause = false;

    animationController.reverse(
        from:
            animationController.value == 0.0 ? 1.0 : animationController.value);

    return 0;
  }

  void _stopTimer() {
    setState(() {
      _displayTime(timerCache);
      animationController.stop();
      animationController.value = 1;
    });
  }

  void _resetTimer() {
    setState(() {
      //  reset start button text to "Start" (from "Continue")
      pause = false;
      _displayTime(timerCache);
      animationController.value = 1;
    });
  }

  void _pauseTimer() {
    setState(() {
      pause = true;
      animationController.stop();
    });
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

  String getDecimalSeconds() {
    //  padLeft to add additional 0 to be always same length of string
    //  because of this number is not int the length of pad is different than 2
    String secs = _sec.toStringAsFixed(0).padLeft(2, "0");

    String milis = (_milliseconds / 100).toStringAsFixed(0);

    //  check needed because of toStringAsFixed(0)
    //  which sometimes cast millis to be 10 and crash UI
    if (milis == "10") {
      milis = "9";
    }

    return "$secs.$milis";
  }
}
