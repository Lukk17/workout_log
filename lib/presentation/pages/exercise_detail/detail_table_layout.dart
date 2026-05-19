import 'package:workout_log/presentation/widgets/responsive_scaffold.dart';

/// Dimensions and font sizes the exercise-detail page derives once per
/// build from its current [ResponsiveDimensions]. The page passes a
/// single instance down to every column / cell / dialog so the layout
/// stays consistent across orientation changes.
class DetailTableLayout {
  const DetailTableLayout._({
    required this.screenHeight,
    required this.screenWidth,
    required this.isPortrait,
    required this.exerciseHeightPortrait,
    required this.exerciseHeightLandscape,
    required this.exerciseWidth,
    required this.columnWidth,
    required this.seriesColumnWidth,
    required this.headerLandscapeColumnHeight,
    required this.portraitColumnHeight,
    required this.landscapeColumnHeight,
    required this.titleFontSizePortrait,
    required this.titleFontSizeLandscape,
  });

  factory DetailTableLayout.from(ResponsiveDimensions dims) =>
      DetailTableLayout._(
        screenHeight: dims.height,
        screenWidth: dims.width,
        isPortrait: dims.isPortrait,
        exerciseHeightPortrait: dims.height * 0.1,
        exerciseHeightLandscape: dims.height * 0.15,
        exerciseWidth: dims.width,
        columnWidth: dims.width * 0.375,
        seriesColumnWidth: dims.width * 0.25,
        headerLandscapeColumnHeight: dims.height * 0.15,
        portraitColumnHeight: dims.height * 0.1,
        landscapeColumnHeight: dims.height * 0.17,
        titleFontSizePortrait: dims.width * 0.055,
        titleFontSizeLandscape: dims.width * 0.03,
      );

  final double screenHeight;
  final double screenWidth;
  final bool isPortrait;
  final double exerciseHeightPortrait;
  final double exerciseHeightLandscape;
  final double exerciseWidth;
  final double columnWidth;
  final double seriesColumnWidth;
  final double headerLandscapeColumnHeight;
  final double portraitColumnHeight;
  final double landscapeColumnHeight;
  final double titleFontSizePortrait;
  final double titleFontSizeLandscape;
}

/// Which field of a series row a [SetValueDialog] is editing.
enum EditField { load, repeats }
