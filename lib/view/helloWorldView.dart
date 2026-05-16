import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:workout_log/main.dart';
import 'package:workout_log/presentation/providers/theme_providers.dart';
import 'package:workout_log/presentation/theme/workout_colors.dart';
import 'package:workout_log/util/util.dart';
import 'package:workout_log/view/backupView.dart';
import 'package:workout_log/view/calendarView.dart';
import 'package:workout_log/view/exerciseListView.dart';
import 'package:workout_log/view/workLogPageView.dart';

/// Main page of application.
class HelloWorldView extends ConsumerStatefulWidget {
  final Function(Widget) callback;

  const HelloWorldView({super.key, required this.callback});

  @override
  ConsumerState<HelloWorldView> createState() => _HelloWorldViewState();
}

class _HelloWorldViewState extends ConsumerState<HelloWorldView>
    with TickerProviderStateMixin {
  final Logger _log = Logger('HelloWorldView');

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  late TabController _tabController;

  Orientation? _screenOrientation;
  late bool _isPortraitOrientation;
  late double _screenHeight;
  late double _screenWidth;

  late double _appBarHeightPortrait;
  late double _appBarHeightLandscape;
  late double titleFontSizePortrait;
  late double titleFontSizeLandscape;

  void setupDimensions() {
    _screenHeight = Util.getScreenHeight(context);
    _screenWidth = Util.getScreenWidth(context);

    _appBarHeightPortrait = _screenHeight * 0.08;
    _appBarHeightLandscape = _screenHeight * 0.1;
    titleFontSizePortrait = _screenWidth * 0.055;
    titleFontSizeLandscape = _screenWidth * 0.03;
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 1, vsync: this);
    _log.fine('started');
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(builder: (context, orientation) {
      _isPortraitOrientation = orientation == Orientation.portrait;
      _screenOrientation = orientation;
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

  PreferredSize _createAppBar() {
    final colors = WorkoutColors.of(context);
    return PreferredSize(
      preferredSize: Size.fromHeight(_isPortraitOrientation
          ? _appBarHeightPortrait
          : _appBarHeightLandscape),
      child: AppBar(
        leading: IconButton(
          icon: Icon(Icons.settings, color: colors.titleColor),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        title: Text(
          MyApp.title,
          style: TextStyle(
            color: colors.titleColor,
            fontSize: _isPortraitOrientation
                ? titleFontSizePortrait
                : titleFontSizeLandscape,
          ),
        ),
        backgroundColor: colors.appBarColor,
        centerTitle: !_isPortraitOrientation,
        actions: <Widget>[
          MaterialButton(
            padding: const EdgeInsets.all(5),
            onPressed: () async => _openCalendar(),
            child: _isPortraitOrientation
                ? Column(
                    children: <Widget>[
                      Icon(Icons.calendar_today, color: colors.titleColor),
                      Text('Calendar',
                          style: TextStyle(color: colors.titleColor)),
                    ],
                  )
                : Icon(Icons.calendar_today, color: colors.iconColor),
          ),
        ],
      ),
    );
  }

  Widget _createTabBar() {
    final colors = WorkoutColors.of(context);
    return Container(
      color: colors.backgroundColor,
      child: TabBar(
        indicatorColor: colors.indicatorColor,
        labelColor: colors.tabBarColor,
        controller: _tabController,
        tabs: <Widget>[
          Tab(
            text: _isPortraitOrientation ? 'log' : null,
            icon: Icon(Icons.assignment, color: colors.tabBarIconColor),
          ),
        ],
      ),
    );
  }

  Widget _createBody() {
    final colors = WorkoutColors.of(context);
    final showBackground = ref.watch(backgroundImageProvider);
    return Container(
      decoration: showBackground
          ? BoxDecoration(
              image: DecorationImage(
                image: AssetImage(colors.backgroundImage),
                fit: BoxFit.fitHeight,
              ),
            )
          : const BoxDecoration(),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 3.0, sigmaY: 3.0),
        child: TabBarView(
          physics: const NeverScrollableScrollPhysics(),
          controller: _tabController,
          children: const [WorkLogPageView()],
        ),
      ),
    );
  }

  Future<void> _openCalendar() async {
    await showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        children: <Widget>[
          CalendarView((widget) => {}, _screenOrientation!),
        ],
      ),
    );
  }

  Widget _openSettings() {
    final colors = WorkoutColors.of(context);
    final isDark = ref.watch(themeModeProvider) == ThemeMode.dark;
    final showBackground = ref.watch(backgroundImageProvider);
    return Drawer(
      child: Container(
        color: colors.drawerColor,
        child: ListView(
          children: <Widget>[
            Center(
              child: Text(
                'Settings',
                style: TextStyle(
                  color: colors.textColor,
                  fontWeight: FontWeight.bold,
                  fontSize: WorkoutTypography.headerSize,
                ),
              ),
            ),
            SizedBox(
              height: _screenHeight * (_isPortraitOrientation ? 0.2 : 0.1),
            ),
            Column(
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      'Dark mode:',
                      style: TextStyle(
                        color: colors.textColor,
                        fontSize: WorkoutTypography.fontSize,
                      ),
                    ),
                    Switch(
                      value: isDark,
                      onChanged: (value) =>
                          ref.read(themeModeProvider.notifier).toggle(value),
                    ),
                  ],
                ),
                SizedBox(height: _screenHeight * 0.1),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      'Background image:',
                      style: TextStyle(
                        color: colors.textColor,
                        fontSize: WorkoutTypography.fontSize,
                      ),
                    ),
                    Switch(
                      value: showBackground,
                      onChanged: (value) => ref
                          .read(backgroundImageProvider.notifier)
                          .set(value),
                    ),
                  ],
                ),
                SizedBox(
                  height: _screenHeight * (_isPortraitOrientation ? 0.1 : 0.05),
                ),
                MaterialButton(
                  color: colors.buttonColor,
                  child: Text(
                    'Backup',
                    style: TextStyle(
                      color: colors.buttonTextColor,
                      fontSize: WorkoutTypography.fontSize,
                    ),
                  ),
                  onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const BackupView())),
                ),
                SizedBox(
                  height: _screenHeight * (_isPortraitOrientation ? 0.2 : 0.1),
                ),
                MaterialButton(
                  color: colors.buttonColor,
                  child: Text(
                    'Edit Exercises',
                    style: TextStyle(
                      color: colors.buttonTextColor,
                      fontSize: WorkoutTypography.fontSize,
                    ),
                  ),
                  onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const ExerciseListView())),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
