import 'package:flutter/material.dart';
import 'package:workout_log/main.dart';

class Chest extends StatefulWidget {
  Chest({
    Key key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _ChestState();
  }
}

class _ChestState extends State<Chest> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return DefaultTabController(
        length: 2,
        child: Scaffold(
            body: Container(
              child: Text('text'),
            ),
            floatingActionButton: Hero(
              tag: "button",
              child: FloatingActionButton(
                // text which will be shown after long press on button
                tooltip: 'Increment',

                child: Icon(Icons.add),
                backgroundColor: Colors.red,
                foregroundColor: Colors.black,
              ),
            )));
  }
}
