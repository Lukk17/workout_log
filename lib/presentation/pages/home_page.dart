import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workout_log/util/log.dart';
import 'package:workout_log/presentation/app.dart';
import 'package:workout_log/presentation/pages/backup_page.dart';
import 'package:workout_log/presentation/pages/calendar_page.dart';
import 'package:workout_log/presentation/pages/exercise_list_page.dart';
import 'package:workout_log/presentation/pages/timer_page.dart';
import 'package:workout_log/presentation/pages/work_log_page.dart';
import 'package:workout_log/presentation/providers/theme_providers.dart';
import 'package:workout_log/presentation/theme/workout_colors.dart';
import 'package:workout_log/presentation/widgets/responsive_scaffold.dart';

/// Main page of application.
class HomePage extends ConsumerStatefulWidget {
  final Function(Widget) callback;

  const HomePage({super.key, required this.callback});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage>
    with TickerProviderStateMixin {
  static const _tag = 'HomePage';

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    logFine('started', name: _tag);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveScaffold(
      scaffoldKey: _scaffoldKey,
      appBarBuilder: _createAppBar,
      body: _createBody(),
      bottomNavigationBar: _createTabBar(context),
      drawer: _openSettings(context),
    );
  }

  PreferredSize _createAppBar(BuildContext context, ResponsiveDimensions dims) {
    final colors = WorkoutColors.of(context);
    final titleFontSize =
        dims.width * (dims.isPortrait ? 0.055 : 0.03);
    return PreferredSize(
      preferredSize: Size.fromHeight(dims.appBarHeight),
      child: AppBar(
        leading: IconButton(
          icon: Icon(Icons.settings, color: colors.titleColor),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        title: Text(
          MyApp.title,
          style: TextStyle(
            color: colors.titleColor,
            fontSize: titleFontSize,
          ),
        ),
        backgroundColor: colors.appBarColor,
        centerTitle: !dims.isPortrait,
        actions: <Widget>[
          MaterialButton(
            padding: const EdgeInsets.all(5),
            onPressed: () async => _openCalendar(),
            child: dims.isPortrait
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

  Widget _createTabBar(BuildContext context) {
    return Builder(builder: (context) {
      final colors = WorkoutColors.of(context);
      final dims = ResponsiveDimensions.of(context);
      return Container(
        color: colors.backgroundColor,
        child: TabBar(
          indicatorColor: colors.indicatorColor,
          labelColor: colors.tabBarColor,
          controller: _tabController,
          tabs: <Widget>[
            Tab(
              text: dims.isPortrait ? 'Log' : null,
              icon: Icon(Icons.assignment, color: colors.tabBarIconColor),
            ),
            Tab(
              text: dims.isPortrait ? 'Timer' : null,
              icon: Icon(Icons.timer, color: colors.tabBarIconColor),
            ),
          ],
        ),
      );
    });
  }

  Widget _createBody() {
    return Builder(builder: (context) {
      final colors = WorkoutColors.of(context);
      final showBackground = ref.watch(backgroundImageProvider);
      // The blurred background is a static layer behind a scrollable list.
      // Wrapping it in a RepaintBoundary caches it as a texture so the
      // expensive saveLayer + Gaussian-blur in BackdropFilter only runs
      // when the background itself changes (toggling visibility / theme),
      // not on every workout-list scroll frame.
      return Stack(
        fit: StackFit.expand,
        children: [
          if (showBackground)
            RepaintBoundary(
              child: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(colors.backgroundImage),
                    fit: BoxFit.fitHeight,
                  ),
                ),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 3.0, sigmaY: 3.0),
                  child: const SizedBox.expand(),
                ),
              ),
            ),
          TabBarView(
            physics: const NeverScrollableScrollPhysics(),
            controller: _tabController,
            children: const [WorkLogPage(), TimerPage()],
          ),
        ],
      );
    });
  }

  Future<void> _openCalendar() async {
    await showDialog(
      context: context,
      builder: (context) => const CalendarPage(),
    );
  }

  Widget _openSettings(BuildContext context) {
    return Builder(builder: (context) {
      final colors = WorkoutColors.of(context);
      final dims = ResponsiveDimensions.of(context);
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
                height: dims.height * (dims.isPortrait ? 0.2 : 0.1),
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
                        onChanged: (value) => ref
                            .read(themeModeProvider.notifier)
                            .toggle(value),
                      ),
                    ],
                  ),
                  SizedBox(height: dims.height * 0.1),
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
                    height:
                        dims.height * (dims.isPortrait ? 0.1 : 0.05),
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
                          builder: (context) => const BackupPage()),
                    ),
                  ),
                  SizedBox(
                    height: dims.height * (dims.isPortrait ? 0.2 : 0.1),
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
                          builder: (context) => const ExerciseListPage()),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    });
  }
}
