import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workout_log/presentation/pages/calendar/calendar_page.dart';
import 'package:workout_log/presentation/pages/home/widgets/home_app_bar.dart';
import 'package:workout_log/presentation/pages/home/widgets/home_body.dart';
import 'package:workout_log/presentation/pages/home/widgets/home_bottom_bar.dart';
import 'package:workout_log/presentation/pages/home/widgets/settings_drawer.dart';
import 'package:workout_log/presentation/widgets/responsive_scaffold.dart';
import 'package:workout_log/util/log.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

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
      appBarBuilder: (context, dims) => HomeAppBar(
        dims: dims,
        onOpenSettings: () => _scaffoldKey.currentState?.openDrawer(),
        onOpenCalendar: _openCalendar,
      ),
      body: HomeBody(tabController: _tabController),
      bottomNavigationBar: HomeBottomBar(tabController: _tabController),
      drawer: const SettingsDrawer(),
    );
  }

  Future<void> _openCalendar() async {
    await showDialog(
      context: context,
      builder: (context) => const CalendarPage(),
    );
  }
}
