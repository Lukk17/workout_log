import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workout_log/presentation/app.dart';
import 'package:workout_log/presentation/pages/backup_page.dart';
import 'package:workout_log/presentation/pages/calendar_page.dart';
import 'package:workout_log/presentation/pages/exercise_list_page.dart';
import 'package:workout_log/presentation/pages/timer_page.dart';
import 'package:workout_log/presentation/pages/work_log_page.dart';
import 'package:workout_log/presentation/providers/theme_providers.dart';
import 'package:workout_log/presentation/theme/workout_colors.dart';
import 'package:workout_log/presentation/widgets/responsive_scaffold.dart';
import 'package:workout_log/util/log.dart';

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
      appBarBuilder: (context, dims) => _HomeAppBar(
        dims: dims,
        onOpenSettings: () => _scaffoldKey.currentState?.openDrawer(),
        onOpenCalendar: _openCalendar,
      ),
      body: _HomeBody(tabController: _tabController),
      bottomNavigationBar: _HomeBottomBar(tabController: _tabController),
      drawer: const _SettingsDrawer(),
    );
  }

  Future<void> _openCalendar() async {
    await showDialog(
      context: context,
      builder: (context) => const CalendarPage(),
    );
  }
}

class _HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _HomeAppBar({
    required this.dims,
    required this.onOpenSettings,
    required this.onOpenCalendar,
  });

  final ResponsiveDimensions dims;
  final VoidCallback onOpenSettings;
  final VoidCallback onOpenCalendar;

  @override
  Size get preferredSize => Size.fromHeight(dims.appBarHeight);

  @override
  Widget build(BuildContext context) {
    final colors = WorkoutColors.of(context);
    final titleFontSize = dims.width * (dims.isPortrait ? 0.055 : 0.03);
    return AppBar(
      leading: IconButton(
        icon: Icon(Icons.settings, color: colors.titleColor),
        onPressed: onOpenSettings,
      ),
      title: Text(
        MyApp.title,
        style: TextStyle(color: colors.titleColor, fontSize: titleFontSize),
      ),
      backgroundColor: colors.appBarColor,
      centerTitle: !dims.isPortrait,
      actions: <Widget>[
        MaterialButton(
          padding: const EdgeInsets.all(5),
          onPressed: onOpenCalendar,
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
    );
  }
}

class _HomeBottomBar extends StatelessWidget {
  const _HomeBottomBar({required this.tabController});

  final TabController tabController;

  @override
  Widget build(BuildContext context) {
    final colors = WorkoutColors.of(context);
    final dims = ResponsiveDimensions.of(context);
    return Container(
      color: colors.backgroundColor,
      child: TabBar(
        indicatorColor: colors.indicatorColor,
        labelColor: colors.tabBarColor,
        controller: tabController,
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
  }
}

class _HomeBody extends ConsumerWidget {
  const _HomeBody({required this.tabController});

  final TabController tabController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final showBackground = ref.watch(backgroundImageProvider);
    return Stack(
      fit: StackFit.expand,
      children: [
        if (showBackground) const _BlurredBackground(),
        TabBarView(
          physics: const NeverScrollableScrollPhysics(),
          controller: tabController,
          children: const [WorkLogPage(), TimerPage()],
        ),
      ],
    );
  }
}

class _BlurredBackground extends StatelessWidget {
  const _BlurredBackground();

  @override
  Widget build(BuildContext context) {
    // RepaintBoundary caches the blur as a texture; the expensive
    // saveLayer + Gaussian blur only re-runs when this widget itself
    // rebuilds, not on every workout-list scroll frame above it.
    final colors = WorkoutColors.of(context);
    return RepaintBoundary(
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
    );
  }
}

class _SettingsDrawer extends ConsumerWidget {
  const _SettingsDrawer();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
            SizedBox(height: dims.height * (dims.isPortrait ? 0.2 : 0.1)),
            _SettingSwitchRow(
              label: 'Dark mode:',
              value: isDark,
              onChanged: (value) =>
                  ref.read(themeModeProvider.notifier).toggle(value),
            ),
            SizedBox(height: dims.height * 0.1),
            _SettingSwitchRow(
              label: 'Background image:',
              value: showBackground,
              onChanged: (value) =>
                  ref.read(backgroundImageProvider.notifier).set(value),
            ),
            SizedBox(height: dims.height * (dims.isPortrait ? 0.1 : 0.05)),
            _DrawerButton(
              label: 'Backup',
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const BackupPage()),
              ),
            ),
            SizedBox(height: dims.height * (dims.isPortrait ? 0.2 : 0.1)),
            _DrawerButton(
              label: 'Edit Exercises',
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const ExerciseListPage()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingSwitchRow extends StatelessWidget {
  const _SettingSwitchRow({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = WorkoutColors.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          label,
          style: TextStyle(
            color: colors.textColor,
            fontSize: WorkoutTypography.fontSize,
          ),
        ),
        Switch(value: value, onChanged: onChanged),
      ],
    );
  }
}

class _DrawerButton extends StatelessWidget {
  const _DrawerButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = WorkoutColors.of(context);
    return MaterialButton(
      color: colors.buttonColor,
      onPressed: onPressed,
      child: Text(
        label,
        style: TextStyle(
          color: colors.buttonTextColor,
          fontSize: WorkoutTypography.fontSize,
        ),
      ),
    );
  }
}
