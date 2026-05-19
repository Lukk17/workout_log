import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:workout_log/presentation/theme/workout_colors.dart';

class BlurredBackground extends StatelessWidget {
  const BlurredBackground({super.key});

  @override
  Widget build(BuildContext context) {
    // RepaintBoundary caches the blur as a texture; the expensive
    // saveLayer + Gaussian blur only re-runs when this widget itself
    // rebuilds, not on every list-scroll frame above it.
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
