import 'package:flutter/material.dart';

/// Used to call rebuild() method which will rebuild all app
/// needed for changing theme and background
class AppBuilder extends StatefulWidget {
  final Function(BuildContext) builder;

  const AppBuilder(Key key, {required this.builder}) : super(key: key);

  @override
  AppBuilderState createState() => new AppBuilderState();

  // return AppBuilder of given context so rebuild can be called
  static AppBuilderState? of(BuildContext context) {
    return context.findAncestorStateOfType<AppBuilderState>();
  }
}

class AppBuilderState extends State<AppBuilder> {
  @override
  Widget build(BuildContext context) {
    return widget.builder(context);
  }

  void rebuild() {
    setState(() {});
  }
}
