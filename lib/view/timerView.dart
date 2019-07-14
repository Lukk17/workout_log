import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:workout_log/setting/appThemeSettings.dart';
import 'package:workout_log/util/timerPainter.dart';
import 'package:workout_log/util/timerService.dart';
import 'package:workout_log/util/util.dart';

import '../main.dart';

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
  double position = 0;
  bool dragUp = true;
  Orientation screenOrientation;

  TimerService timerService = MyApp.timerService;

  @override
  void initState() {
    super.initState();
    //  timerService need to know view to callback method in right view
    timerService.initTimerView(_displayTime);
    //  this flag inform timerService that he can call _displayTime() method
    timerService.isTimerOnView = true;
  }

  @override
  Widget build(BuildContext context) {
    return _createTimer();
  }

  Widget _createTimer() {
    return OrientationBuilder(builder: (context, orientation) {
      screenOrientation = orientation;
      if (orientation == Orientation.portrait) {
        //  portrait
        //  orientation
        if (timerService.isAnimating() ||
            timerService.pause ||
            timerService.running) {
          return Center(
            child: Stack(
              children: <Widget>[
                Positioned.fill(
                    child: AnimatedBuilder(
                        animation: timerService.animationController,
                        builder: (BuildContext context, Widget child) {
                          return CustomPaint(
                            painter: TimerCirclePainter(
                                animation: timerService.animationController),
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
                    color: AppThemeSettings.timerColor,
                    fontSize: MediaQuery.of(context).size.width * 0.2 * scale,
                    shadows: AppThemeSettings.textBorder,
                  ),
                ),
              ),
              Util.spacerSelectable(
                  left: MediaQuery.of(context).size.width * 0.4 * scale),
              Center(
                child: Text(
                  "M",
                  style: TextStyle(
                    fontSize: MediaQuery.of(context).size.width * 0.2 * scale,
                    color: AppThemeSettings.timerColor,
                    shadows: AppThemeSettings.textBorder,
                  ),
                ),
              ),
              Util.spacerSelectable(
                  left: MediaQuery.of(context).size.width * 0.5 * scale),
              Center(
                child: Text(
                  "S",
                  style: TextStyle(
                    fontSize: MediaQuery.of(context).size.width * 0.2 * scale,
                    color: AppThemeSettings.timerColor,
                    shadows: AppThemeSettings.textBorder,
                  ),
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
                  timerService.changeHour(
                      time: timerService.hour, dragUp: dragUp);
                  setState(() {});
                },
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.5 * scale,
                  child: Center(
                    child: Text(
                      //  padLeft to add additional 0 to be always same length of string
                      timerService.hour.toString().padLeft(2, "0"),
                      style: TextStyle(
                        fontSize:
                            MediaQuery.of(context).size.width * 0.4 * scale,
                        color: AppThemeSettings.timerColor,
                        shadows: AppThemeSettings.textBorder,
                      ),
                    ),
                  ),
                ),
              ),
              Text(
                ":",
                style: TextStyle(
                  fontSize: MediaQuery.of(context).size.width * 0.4 * scale,
                  color: AppThemeSettings.timerColor,
                  shadows: AppThemeSettings.textBorder,
                ),
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
                  timerService.changeMinute(
                      time: timerService.minute, dragUp: dragUp);
                  setState(() {});
                },
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.5 * scale,
                  child: Center(
                    child: Text(
                      //  padLeft to add additional 0 to be always same length of string
                      timerService.minute.toString().padLeft(2, "0"),
                      style: TextStyle(
                        fontSize:
                            MediaQuery.of(context).size.width * 0.4 * scale,
                        color: AppThemeSettings.timerColor,
                        shadows: AppThemeSettings.textBorder,
                      ),
                    ),
                  ),
                ),
              ),
              Text(
                ":",
                style: TextStyle(
                  fontSize: MediaQuery.of(context).size.width * 0.4 * scale,
                  color: AppThemeSettings.timerColor,
                  shadows: AppThemeSettings.textBorder,
                ),
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
                  timerService.changeSec(time: timerService.sec, dragUp: dragUp);
                  setState(() {});
                },
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.8 * scale,
                  child: Center(
                    child: Row(
                      children: <Widget>[
                        Text(
                          timerService.getDecimalSeconds(),
                          style: TextStyle(
                            fontSize:
                                MediaQuery.of(context).size.width * 0.4 * scale,
                            color: AppThemeSettings.timerColor,
                            shadows: AppThemeSettings.textBorder,
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
    return timerService.pause
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
              timerService.isAnimating()
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
                            timerService.timerCache =
                                getDuration().inMilliseconds,
                            _startTimer(),
                          },
                      textColor: AppThemeSettings.buttonTextColor,
                      color: AppThemeSettings.buttonColor,
                      child: Text("Start"),
                    ),
            ],
          );
  }
  /// Updates the state of this widget
  /// with correct time values and animation state
  void _displayTime(int milliseconds) {
    setState(() {
      timerService.computeTime(milliseconds);
    });
  }

  Duration getDuration() {
    return timerService.getDuration();
  }

  _startTimer() {
    timerService.startTimer();
  }

  void _stopTimer() {
    setState(() {
      timerService.stopTimer();
    });
  }

  void _resetTimer() {
    setState(() {
      timerService.resetTimer();
    });
  }

  void _pauseTimer() {
    setState(() {
      timerService.pauseTimer();
    });
  }

  @override
  void dispose() {
    ///  when view is closed timerService need to be informed,
    ///  to stop calling _displayTime() method in here
    timerService.isTimerOnView = false;
    super.dispose();
  }
}
