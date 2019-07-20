import 'package:android_alarm_manager/android_alarm_manager.dart';
import 'package:audioplayers/audio_cache.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:workout_log/main.dart';
import 'package:workout_log/util/notification.dart';
import 'package:workout_log/view/helloWorldView.dart';

class TimerService {
  AnimationController animationController;
  TickerProvider view;
  Function _displayTime;
  bool isTimerOnView = false;

  NotificationService notificationService = MyApp.notificationService;

  int hour = 0;
  int minute = 0;
  int sec = 0;
  int milliseconds = 0;
  int timerCache = 0;
  bool pause = false;
  bool running = false;

  /// Called in main view to init AnimationController (HelloWorldView)
  ///
  /// Set up TickerProvider, AnimationController and add listener to AnimationController
  setTickerProvider(TickerProvider view) {
    this.view = view;

    if (animationController == null) {
      animationController = AnimationController(
        vsync: view,
        duration: Duration(
            hours: hour,
            minutes: minute,
            seconds: sec,
            milliseconds: milliseconds),
      );
      animationController.addListener(() => {
            if (isTimerOnView)
              {
                _displayTime((animationController.duration.inMilliseconds *
                        animationController.value)
                    .toInt()),
              },
            if (animationController.value == 0)
              {
                stopTimer(),
                _startAlarm(),
              },
          });
    }
  }

  /// Called when TimerView is opened.
  ///
  /// Take as parameter the function to display time on correct view
  initTimerView(Function displayTime) {
    _displayTime = displayTime;
  }

  bool isAnimating() {
    return animationController.isAnimating;
  }

  Duration getDuration() {
    return Duration(
        hours: hour, minutes: minute, seconds: sec, milliseconds: milliseconds);
  }

  startTimer() {
    running = true;
    animationController.duration = getDuration();
    //  if paused do not save time to cache
    if (pause) {
      animationController.duration = Duration(milliseconds: timerCache);
    }
    pause = false;

    animationController.reverse(
        from:
            animationController.value == 0.0 ? 1.0 : animationController.value);
  }

  void pauseTimer() {
    pause = true;
    animationController.stop();
  }

  void stopTimer() {
    running = false;
    computeTime(timerCache);
    animationController.stop();
    animationController.value = 1;
  }

  void resetTimer() {
    //  reset start button text to "Start" (from "Continue")
    running = false;
    pause = false;
    computeTime(timerCache);
    animationController.value = 1;
  }

  _startAlarm() async {
    MyApp.globalKey.currentState.showSnackBar(SnackBar(content: Text("ALARM") ));
    await AndroidAlarmManager.oneShot(Duration(seconds: 1), 17, alarmCallback).then((val) => print(val));
    await notificationService.display(title: "alarm", body: "timer !");
    SystemSound.play(SystemSoundType.click);
    AudioCache player = AudioCache();
    player.play('CarHornAlarm.mp3');
  }

  static void alarmCallback(){
    print('>>>>>>>>>>>>>>>>>>>>>>>>>>>>>. ALARM CALLBACK <<<<<<<<<<<<<<<<<<<<<<<< ');
  }

  void computeTime(int milliseconds) {
    //  if more than second
    if (milliseconds / 1000 >= 1) {
      // check if there is more than one minute
      if (milliseconds / (60 * 1000) >= 1) {
        // check if there is more than one hour
        if (milliseconds / (60 * 60 * 1000) >= 1) {
          hour = (milliseconds / (60 * 60 * 1000)).floor();
          minute =
              ((milliseconds - (hour * 60 * 60 * 1000)) / (60 * 1000)).floor();
          sec =
              ((milliseconds - (hour * 60 * 60 * 1000) - (minute * 60 * 1000)) /
                      1000)
                  .floor();
          milliseconds =
              ((milliseconds - (hour * 60 * 60 * 1000) - (minute * 60 * 1000)) -
                  sec * 1000);

          //  if less than hour:
        } else {
          hour = 0;
          minute = (milliseconds / (60 * 1000)).floor();
          sec = ((milliseconds - (minute * 60 * 1000)) / 1000).floor();
          milliseconds = ((milliseconds - (minute * 60 * 1000)) - sec * 1000);
        }
      }
      //  if less than minute:
      else {
        hour = 0;
        minute = 0;
        sec = (milliseconds / 1000).floor();
        milliseconds = milliseconds - (sec * 1000);
      }
    } else {
      hour = 0;
      minute = 0;
      sec = 0;
      milliseconds = milliseconds;
    }
  }

  changeSec({@required int time, @required bool dragUp}) {
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
    sec = time;
  }

  changeMinute({@required int time, @required bool dragUp}) {
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
    minute = time;
  }

  changeHour({@required int time, @required bool dragUp}) {
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
    hour = time;
  }

  String getDecimalSeconds() {
    //  padLeft to add additional 0 to be always same length of string
    //  because of this number is not int the length of pad is different than 2
    String secs = sec.toStringAsFixed(0).padLeft(2, "0");

    String millis = (milliseconds / 100).toStringAsFixed(0);

    //  check needed because of toStringAsFixed(0)
    //  which sometimes cast millis to be 10 and crash UI
    if (millis == "10") {
      millis = "9";
    }
    return "$secs.$millis";
  }

  void dispose() {
    animationController.dispose();
  }
}
