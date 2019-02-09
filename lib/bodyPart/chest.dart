import 'package:flutter/material.dart';

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
  List<Widget> wList = List();

  @override
  void setState(fn) {
    // TODO: implement setState to add row on addButton click
    super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Chest'),
          backgroundColor: Colors.red,
        ),
        body: Container(
          child: ListView(
            children: <Widget>[
              Column(
                children: <Widget>[
                  _createRow('pushups', 30),
                ],
              ),
            ],
          ),
        ),
        floatingActionButton: Hero(
          tag: "button",
          child: FloatingActionButton(
            // text which will be shown after long press on button
            tooltip: 'Add exercise',

            // open pop-up on button press to add new exercise
            onPressed: () => openDialog('Exercise', 'eg. pushup'),

            child: Icon(Icons.add),
            backgroundColor: Colors.red,
            foregroundColor: Colors.black,
          ),
        ),
      ),
    );
  }

  /// Dart Doc comment
  Future openDialog(String title, String hint) {
    return showDialog(
      context: context,
      builder: (_) => SimpleDialog(
            title: Center(child: Text(title)),
            contentPadding: EdgeInsets.all(20),
            children: <Widget>[
              TextField(
                autofocus: true,
                autocorrect: true,
                decoration: InputDecoration(hintText: hint),
              ),
              Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    FlatButton(
                        child: const Text('SAVE'),
                        onPressed: () {
                          Navigator.pop(context);
                        }),
                    FlatButton(
                        child: const Text('CANCEL'),
                        onPressed: () {
                          Navigator.pop(context);
                        }),
                  ]),
            ],
          ),
    );
  }

  Widget _createRow(String text, double fontSize) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: wList,
    );
  }

  List<Widget> addWidget(List<Widget> wList, String text, double fontSize) {
    wList.add(
      Text(text, style: TextStyle(fontSize: fontSize)),
    );
    return wList;
  }
}
