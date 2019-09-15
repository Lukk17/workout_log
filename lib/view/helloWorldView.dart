import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workout_log/setting/appThemeSettings.dart';
import 'package:workout_log/util/appBuilder.dart';
import 'package:workout_log/util/util.dart';
import 'package:workout_log/view/backupView.dart';
import 'package:workout_log/view/calendarView.dart';
import 'package:workout_log/view/workLogPageView.dart';

import '../main.dart';
import 'exerciseListView.dart';

/// Main page of application.
///
/// Contains links to settings, calendar, workLogs and timer.
class HelloWorldView extends StatefulWidget {
  // This widget is the home page of your application.
  // Fields in a Widget subclass are always marked "final".
  static DateTime date = DateTime.now();
  final Function(Widget) callback;

  HelloWorldView({Key key, @required this.callback}) : super(key: key);

  // override to manually creates private (starting with _ ) subclass
  // to update state of counter widget
  @override
  _HelloWorldViewState createState() => _HelloWorldViewState();
}

class _HelloWorldViewState extends State<HelloWorldView>
    with TickerProviderStateMixin {
  final Logger _log = new Logger("HelloWorldView");

  static const String BACKGROUND_IMAGE = "backgroundImage";
  static const String IS_DARK = "isDark";

  //  creating key to change drawer icon
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  TabController _tabController;
  SharedPreferences _prefs;
  bool _backgroundImage = true;

  Orientation _screenOrientation;
  bool _isPortraitOrientation;
  double _screenHeight;
  double _screenWidth;

  double _appBarHeightPortrait;
  double _appBarHeightLandscape;
  double titleFontSizePortrait;
  double titleFontSizeLandscape;

  BuildContext helloContext;

  void setupDimensions() {
    _getScreenHeight();
    _getScreenWidth();

    _appBarHeightPortrait = _screenHeight * 0.08;
    _appBarHeightLandscape = _screenHeight * 0.1;
    titleFontSizePortrait = _screenWidth * 0.055;
    titleFontSizeLandscape = _screenWidth * 0.03;
  }

  @override
  void initState() {
    super.initState();
    _tabController = new TabController(length: 1, vsync: this);
    _getPrefs();
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    return OrientationBuilder(builder: (context, orientation) {
      _isPortraitOrientation = orientation == Orientation.portrait;

      _screenOrientation = orientation;
      helloContext = context;

      setupDimensions();

      return Scaffold(
        key: _scaffoldKey,
        appBar: _createAppBar(),
        body: _createBody(),
        bottomNavigationBar: _createTabBar(),
        drawer: _openSettings(),
      );
    });
  }

  Widget _createAppBar() {
    return PreferredSize(
      preferredSize: Size.fromHeight(_isPortraitOrientation
          ? _appBarHeightPortrait
          : _appBarHeightLandscape),
      child: AppBar(
        //  changing drawer icon
        leading: new IconButton(
            icon: new Icon(
              Icons.settings,
              color: AppThemeSettings.titleColor,
            ),
            onPressed: () => _scaffoldKey.currentState.openDrawer()),

        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(
          MyApp.TITLE,
          style: TextStyle(
              color: AppThemeSettings.titleColor,
              fontSize: _isPortraitOrientation
                  ? titleFontSizePortrait
                  : titleFontSizeLandscape),
        ),
        backgroundColor: AppThemeSettings.appBarColor,
        centerTitle: _isPortraitOrientation ? false : true,
        actions: <Widget>[
          MaterialButton(
            padding: EdgeInsets.all(5),
            onPressed: () async => {
              await _openCalendar(),
            },
            child: _isPortraitOrientation
                ? Column(
                    children: <Widget>[
                      Icon(
                        Icons.calendar_today,
                        color: AppThemeSettings.titleColor,
                      ),
                      Text(
                        "Calendar",
                        style: TextStyle(color: AppThemeSettings.titleColor),
                      ),
                    ],
                  )
                : Icon(
                    Icons.calendar_today,
                    color: AppThemeSettings.iconColor,
                  ),
          ),
        ],
      ),
    );
  }

  Widget _createTabBar() {
    return Container(
      color: AppThemeSettings.backgroundColor,
      child: TabBar(
        indicatorColor: AppThemeSettings.indicatorColor,
        labelColor: AppThemeSettings.tabBarColor,
        controller: _tabController,
        tabs: <Widget>[
          Tab(
            text: _isPortraitOrientation ? "log" : null,
            icon: Icon(
              Icons.assignment,
              color: AppThemeSettings.tabBarIconColor,
            ),
          ),
          //          Tab(
          //            text: (screenOrientation == Orientation.portrait) ? "timer" : null,
          //            icon: Icon(Icons.timer),
          //          ),
          //          Tab(
          //            text: (screenOrientation == Orientation.portrait)
          //                ? "statistic"
          //                : null,
          //            icon: Icon(Icons.assessment),
          //          ),
        ],
      ),
    );
  }

  Widget _createBody() {
    return Container(
      decoration: _backgroundImage
          ? BoxDecoration(
              image: DecorationImage(
                image: AssetImage(AppThemeSettings.background),
                fit: BoxFit.fitHeight,
              ),
            )
          : BoxDecoration(),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 3.0, sigmaY: 3.0),
        child: TabBarView(
            // disable scrolling tabView by dragging
            physics: NeverScrollableScrollPhysics(),
            controller: _tabController,
            children: [
              // calling builder to get callback (Widget)
              WorkLogPageView((widget) => {}, HelloWorldView.date),
              //              TimerView((widget) => {}),
              //          Center(),
            ]),
      ),
    );
  }

  /// async to wait for dialog close and refresh state
  _openCalendar() async {
    await showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        children: <Widget>[
          //  send screen orientation to dialog creator
          CalendarView((widget) => {}, _screenOrientation),
        ],
      ),
    );
    _rebuildApp();
  }

  _openSettings() {
    return Drawer(
      child: Container(
        color: AppThemeSettings.drawerColor,
        child: ListView(
          children: <Widget>[
            Center(
              child: Text(
                "Settings",
                style: TextStyle(
                    color: AppThemeSettings.textColor,
                    fontWeight: FontWeight.bold,
                    fontSize: AppThemeSettings.headerSize),
              ),
            ),
            _isPortraitOrientation
                ? Util.spacerSelectable(top: _screenHeight * 0.2)
                : Util.spacerSelectable(top: _screenHeight * 0.1),
            Column(
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      "Dark mode:",
                      style: TextStyle(
                        color: AppThemeSettings.textColor,
                        fontSize: AppThemeSettings.fontSize,
                      ),
                    ),
                    Switch(
                        value: AppThemeSettings.theme == ThemeData.dark(),
                        onChanged: (isDark) => _changeTheme(isDark))
                  ],
                ),
                _isPortraitOrientation
                    ? Util.spacerSelectable(top: _screenHeight * 0.1)
                    : Util.spacerSelectable(top: _screenHeight * 0.1),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      "Background image:",
                      style: TextStyle(
                        color: AppThemeSettings.textColor,
                        fontSize: AppThemeSettings.fontSize,
                      ),
                    ),
                    Switch(
                        value: _backgroundImage,
                        onChanged: (isImage) => _changeBackground(isImage))
                  ],
                ),
                _isPortraitOrientation
                    ? Util.spacerSelectable(top: _screenHeight * 0.1)
                    : Util.spacerSelectable(top: _screenHeight * 0.05),
                MaterialButton(
                  color: AppThemeSettings.buttonColor,
                  child: Text(
                    "Backup",
                    style: TextStyle(
                        color: AppThemeSettings.buttonTextColor,
                        fontSize: AppThemeSettings.fontSize),
                  ),
                  onPressed: () => Navigator.push(context,
                          MaterialPageRoute(builder: (context) => BackupView()))
                      .then((_) => _rebuildApp()),
                ),
                _isPortraitOrientation
                    ? Util.spacerSelectable(top: _screenHeight * 0.2)
                    : Util.spacerSelectable(top: _screenHeight * 0.1),
                MaterialButton(
                  color: AppThemeSettings.buttonColor,
                  child: Text(
                    "Edit Exercises",
                    style: TextStyle(
                        color: AppThemeSettings.buttonTextColor,
                        fontSize: AppThemeSettings.fontSize),
                  ),
                  onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ExerciseListView()))
                      .then((_) => _rebuildApp()),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  _changeBackground(bool isImage) {
    _log.fine("Background image: $isImage");

    if (isImage) {
      _backgroundImage = true;
      _prefs.setBool(BACKGROUND_IMAGE, true);
    } else {
      _backgroundImage = false;
      _prefs.setBool(BACKGROUND_IMAGE, false);
    }
    _rebuildApp();
  }

  _changeTheme(bool isDark) async {
    _log.fine("Dark theme: $isDark");

    _prefs = await SharedPreferences.getInstance();

    if (isDark) {
      _prefs.setBool(IS_DARK, true);
      AppThemeSettings.theme = AppThemeSettings.themeD;
    } else {
      _prefs.setBool(IS_DARK, false);
      AppThemeSettings.theme = AppThemeSettings.themeL;
    }
    _rebuildApp();
  }

  void _getPrefs() async {
    _prefs = await SharedPreferences.getInstance();

    Set<String> prefKeys = _prefs.getKeys();

    if (prefKeys.contains(BACKGROUND_IMAGE)) {
      _backgroundImage = _prefs.get(BACKGROUND_IMAGE);
    } else {
      _backgroundImage = true;
      _prefs.setBool(BACKGROUND_IMAGE, true);
    }

    if (prefKeys.contains(IS_DARK)) {
      _changeTheme(_prefs.getBool(IS_DARK));
    } else {
      _prefs.setBool(IS_DARK, true);
    }
    _log.fine(
        "Shared Preference: backgroundImage: ${_prefs.get(BACKGROUND_IMAGE)}, isDark: ${_prefs.getBool(IS_DARK)}");
  }

  _getScreenHeight() {
    _screenHeight = Util.getScreenHeight(context);
  }

  _getScreenWidth() {
    _screenWidth = Util.getScreenWidth(context);
  }

  _rebuildApp() {
    _log.fine("App rebuilded");
    Util.rebuild = true;
    AppBuilder.of(context).rebuild();
  }
}
