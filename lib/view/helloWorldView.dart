import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workout_log/setting/appThemeSettings.dart';
import 'package:workout_log/util/appBuilder.dart';
import 'package:workout_log/view/calendarView.dart';
import 'package:workout_log/view/timerView.dart';
import 'package:workout_log/view/workLogPageView.dart';

/// Main page of application.
///
/// Contains links to settings, calendar, workLogs and timer.
class HelloWorldView extends StatefulWidget {
  static DateTime date = DateTime.now();
  final Function(Widget) callback;

  HelloWorldView({Key key, @required this.title, @required this.callback})
      : super(key: key);

  // This widget is the home page of your application.
  // Fields in a Widget subclass are always marked "final".
  final String title;

  // override to manually creates private (starting with _ ) subclass
  // to update state of counter widget
  @override
  _HelloWorldViewState createState() => _HelloWorldViewState();
}

class _HelloWorldViewState extends State<HelloWorldView>
    with SingleTickerProviderStateMixin {
  TabController _tabController;
  SharedPreferences prefs;
  Orientation screenOrientation;

  //  creating key to change drawer icon
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  void initState() {
    _tabController = new TabController(length: 2, vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    return OrientationBuilder(builder: (context, orientation) {
      screenOrientation = orientation;
      return Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(AppThemeSettings.background),
            fit: BoxFit.cover,
          ),
        ),
        child: Scaffold(
          key: _scaffoldKey,
          appBar: _createAppBar(),
          body: _createBody(),
          bottomNavigationBar: _createTabBar(),
          drawer: _openSettings(),
        ),
      );
    });
  }

  Widget _createAppBar() {
    return PreferredSize(
      preferredSize: Size.fromHeight((screenOrientation == Orientation.portrait)
          ? MediaQuery.of(context).size.height * 0.08
          : MediaQuery.of(context).size.width * 0.05),
      child: AppBar(
        //  changing drawer icon
        leading: new IconButton(
            icon: new Icon(Icons.settings),
            onPressed: () => _scaffoldKey.currentState.openDrawer()),

        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(
          widget.title,
          style: TextStyle(
              color: AppThemeSettings.titleColor,
              fontSize: (screenOrientation == Orientation.portrait)
                  ? MediaQuery.of(context).size.height * 0.03
                  : MediaQuery.of(context).size.width * 0.03),
        ),
        backgroundColor: AppThemeSettings.appBarColor,
        centerTitle: (screenOrientation == Orientation.portrait) ? false : true,
        actions: <Widget>[
          MaterialButton(
            padding: EdgeInsets.all(5),
            onPressed: _openCalendar,
            child: (screenOrientation == Orientation.portrait)
                ? Column(
                    children: <Widget>[
                      Icon(
                        Icons.calendar_today,
                        color: AppThemeSettings.calendarIconColor,
                      ),
                      Text(
                        "Calendar",
                        style: TextStyle(
                            color: AppThemeSettings.calendarIconColor),
                      ),
                    ],
                  )
                : Icon(
                    Icons.calendar_today,
                    color: AppThemeSettings.calendarIconColor,
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
            text: (screenOrientation == Orientation.portrait) ? "log" : null,
            icon: Icon(Icons.assignment),
          ),
          Tab(
            text: (screenOrientation == Orientation.portrait) ? "timer" : null,
            icon: Icon(Icons.timer),
          ),
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
    return TabBarView(
        // disable scrolling tabView by dragging
        physics: NeverScrollableScrollPhysics(),
        controller: _tabController,
        children: [
          // calling builder to get callback (Widget)
          WorkLogPageView((widget) => {}, HelloWorldView.date),
          TimerView((widget) => {}),
//          Center(),
        ]);
  }

  /// async to wait for dialog close and refresh state
  _openCalendar() async {
    await showDialog(
      context: context,
      builder: (context) => SimpleDialog(
            children: <Widget>[
              //  send screen orientation to dialog creator
              CalendarView((widget) => {}, screenOrientation),
            ],
          ),
    );
    setState(() {});
  }

  updateDate() async {}

  _openSettings() {
    updateDate();
    return Drawer(
      child: Container(
        color: AppThemeSettings.drawerColor,
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            Center(
              child: DrawerHeader(
                child: Text(
                  "Settings",
                  style: TextStyle(
                      color: AppThemeSettings.textColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 30),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text("Dark mode:"),
                Switch(
                    value: AppThemeSettings.theme == ThemeData.dark(),
                    onChanged: (isDark) => _changeTheme(isDark))
              ],
            ),
            ListTile(
              title: Text(
                "close",
                style: TextStyle(
                    color: AppThemeSettings.textColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 20),
              ),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  _changeTheme(bool isDark) async {
    prefs = await SharedPreferences.getInstance();

    if (isDark) {
      prefs.setBool("isDark", true);
      AppThemeSettings.theme = AppThemeSettings.themeD;
    } else {
      prefs.setBool("isDark", false);
      AppThemeSettings.theme = AppThemeSettings.themeL;
    }
    AppBuilder.of(context).rebuild();
  }
}
