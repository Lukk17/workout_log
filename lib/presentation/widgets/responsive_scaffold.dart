import 'package:flutter/material.dart';

@immutable
class ResponsiveDimensions {
  final double width;
  final double height;
  final bool isPortrait;
  final double appBarHeight;

  const ResponsiveDimensions({
    required this.width,
    required this.height,
    required this.isPortrait,
    required this.appBarHeight,
  });

  // Falls back to MediaQuery when no ResponsiveScaffold ancestor exists,
  // so pages can be mounted standalone in widget tests.
  static ResponsiveDimensions of(BuildContext context) {
    final inh = context
        .dependOnInheritedWidgetOfExactType<_ResponsiveDimensionsProvider>();
    if (inh != null) return inh.dimensions;
    final size = MediaQuery.sizeOf(context);
    final isPortrait = MediaQuery.orientationOf(context) == Orientation.portrait;
    return ResponsiveDimensions(
      width: size.width,
      height: size.height,
      isPortrait: isPortrait,
      appBarHeight: size.height * (isPortrait ? 0.08 : 0.1),
    );
  }
}

class _ResponsiveDimensionsProvider extends InheritedWidget {
  final ResponsiveDimensions dimensions;

  const _ResponsiveDimensionsProvider({
    required this.dimensions,
    required super.child,
  });

  @override
  bool updateShouldNotify(_ResponsiveDimensionsProvider old) =>
      old.dimensions.width != dimensions.width ||
      old.dimensions.height != dimensions.height ||
      old.dimensions.isPortrait != dimensions.isPortrait ||
      old.dimensions.appBarHeight != dimensions.appBarHeight;
}

class ResponsiveScaffold extends StatelessWidget {
  final PreferredSizeWidget? appBar;
  final Widget body;
  final Widget? drawer;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;
  final Key? scaffoldKey;
  final bool resizeToAvoidBottomInset;

  // When set, takes precedence over [appBar].
  final PreferredSizeWidget Function(BuildContext, ResponsiveDimensions)? appBarBuilder;

  const ResponsiveScaffold({
    super.key,
    this.appBar,
    required this.body,
    this.drawer,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.scaffoldKey,
    this.resizeToAvoidBottomInset = true,
    this.appBarBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(builder: (context, orientation) {
      final media = MediaQuery.sizeOf(context);
      final isPortrait = orientation == Orientation.portrait;
      final dims = ResponsiveDimensions(
        width: media.width,
        height: media.height,
        isPortrait: isPortrait,
        appBarHeight: media.height * (isPortrait ? 0.08 : 0.1),
      );
      return _ResponsiveDimensionsProvider(
        dimensions: dims,
        child: Scaffold(
          key: scaffoldKey,
          resizeToAvoidBottomInset: resizeToAvoidBottomInset,
          appBar: appBarBuilder?.call(context, dims) ?? appBar,
          body: body,
          drawer: drawer,
          bottomNavigationBar: bottomNavigationBar,
          floatingActionButton: floatingActionButton,
        ),
      );
    });
  }
}
