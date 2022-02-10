import 'dart:io';

Future<Map> getFirebaseOption(FirebaseOptionType type) async {
  var id = type.name;
  var reg = RegExp(
      'static const FirebaseOptions $id = FirebaseOptions\\(([\\s\\S]*?)\\);');

  String contents = File('lib/firebase_options.dart').readAsStringSync();
  var matched = reg.firstMatch(contents);

  if (matched == null) {
    throw 'Error';
  }

  var configAll = matched.group(1);
  if (configAll == null) {
    throw 'Error';
  }

  Map map;
  var regItem = RegExp(r"\s*(.*):\s*'(.*)',");
  var configs = regItem.allMatches(configAll);
  map = {
    for (var config in configs) config.group(1): config.group(2),
  };
  return map;
}

enum FirebaseOptionType {
  web,
  ios,
  android,
}
