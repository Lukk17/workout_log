import 'package:flutter/material.dart';

/// Screen-derived dimensions exposed to descendants. Used by pages to size
/// padding, heights, and font scales without each one re-doing the math.
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

  /// Inherited lookup. Returns the dimensions from the nearest enclosing
  /// `ResponsiveScaffold`.
  static ResponsiveDimensions of(BuildContext context) {
    final inh = context
        .dependOnInheritedWidgetOfExactType<_ResponsiveDimensionsProvider>();
    assert(inh != null, 'ResponsiveDimensions.of called outside ResponsiveScaffold');
    return inh!.dimensions;
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

/// `OrientationBuilder` + `Scaffold` rolled into one. Pages call
/// `ResponsiveDimensions.of(context)` to read screen size / orientation
/// without each having to re-implement the `setupDimensions()` boilerplate.
class ResponsiveScaffold extends StatelessWidget {
  final PreferredSizeWidget? appBar;
  final Widget body;
  final Widget? drawer;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;
  final Key? scaffoldKey;
  final bool resizeToAvoidBottomInset;

  /// Optional builder for cases where the page wants to assemble its own
  /// AppBar with access to dimensions (eg. variable height). When set, takes
  /// precedence over [appBar].
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
