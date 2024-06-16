import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:workout_log/setting/appThemeSettings.dart';
import 'package:workout_log/util/dbProvider.dart';
import 'package:workout_log/util/util.dart';

class BackupView extends StatefulWidget {
  @override
  _BackupViewState createState() => _BackupViewState();
}

class _BackupViewState extends State<BackupView> {
  final Logger _log = new Logger("backupView");
  final DBProvider _db = DBProvider.db;

  double _screenHeight=100;
  bool _isPortraitOrientation = false;

  double _appBarHeightPortrait =30;
  double _appBarHeightLandscape =30;

  void setupDimensions() {
    _getScreenHeight();

    _appBarHeightPortrait = _screenHeight * 0.08;
    _appBarHeightLandscape = _screenHeight * 0.1;
  }

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(builder: (context, orientation) {
      /// check if new orientation is portrait
      /// rebuild from here where orientation will change
      _isPortraitOrientation = orientation == Orientation.portrait;

      setupDimensions();

      return Scaffold(
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(_isPortraitOrientation ? _appBarHeightPortrait : _appBarHeightLandscape),
            child: AppBar(
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text("Backup"),
                  ],
                ),
                backgroundColor: AppThemeSettings.appBarColor),
          ),
          body: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Center(
                child: Text("Make sure to put backup file under: \n Android/data/com.lukk.workoutlog/files/\n"
                    " and name it: backup.json\n"),
              ),
              MaterialButton(
                color: AppThemeSettings.buttonColor,
                child: Text(
                  "Import backup",
                  style: TextStyle(color: AppThemeSettings.buttonTextColor, fontSize: AppThemeSettings.fontSize),
                ),
                onPressed: () => {_log.fine("Restoring from backup..."), _db.restore()},
              ),
              Util.spacerSelectable(top: _screenHeight * 0.25, bottom: 0, left: 0, right: 0),
              Center(
                child: Text("Backup will be created inside:\n Android/data/com.lukk.workoutlog/files/backup.json \n"),
              ),
              MaterialButton(
                color: AppThemeSettings.buttonColor,
                child: Text(
                  "Create backup",
                  style: TextStyle(color: AppThemeSettings.buttonTextColor, fontSize: AppThemeSettings.fontSize),
                ),
                onPressed: () => {_log.fine("Creating backup..."), _db.backup()},
              ),
            ],
          ));
    });
  }

  _getScreenHeight() {
    _screenHeight = Util.getScreenHeight(context);
  }
}
