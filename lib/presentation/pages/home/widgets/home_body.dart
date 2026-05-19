import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workout_log/presentation/pages/timer/timer_page.dart';
import 'package:workout_log/presentation/pages/work_log/work_log_page.dart';
import 'package:workout_log/presentation/providers/theme_providers.dart';
import 'package:workout_log/presentation/widgets/blurred_background.dart';

class HomeBody extends ConsumerWidget {
  const HomeBody({super.key, required this.tabController});

  final TabController tabController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final showBackground = ref.watch(backgroundImageProvider);
    return Stack(
      fit: StackFit.expand,
      children: [
        if (showBackground) const BlurredBackground(),
        TabBarView(
          physics: const NeverScrollableScrollPhysics(),
          controller: tabController,
          children: const [WorkLogPage(), TimerPage()],
        ),
      ],
    );
  }
}
