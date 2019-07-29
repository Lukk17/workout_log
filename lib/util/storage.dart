import 'dart:io';

import 'package:path_provider/path_provider.dart';

class Storage {
  static Directory _dir;
  static String _path;
  static const String _FILENAME = "worklogBackup.txt";

  static void writeToFile(String content) async {
    await getApplicationDocumentsDirectory().then((Directory directory) => _dir = directory);
    _path = _dir.path + "/" + _FILENAME;
    File file = File(_path);
    file.writeAsString(content);
  }
}
