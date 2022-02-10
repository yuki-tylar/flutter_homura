import 'dart:io';

import 'package:colorize/colorize.dart';

main() async {
  var path = 'lib/firebase_options.dart';
  var result = await FileSystemEntity.isFile(path);
  if (result) {
    exitCode = 0;
  } else {
    stderr.writeln(
      Colorize('Error: Could not find firebase_option.dart').red(),
    );
    stderr.writeln('Please initialize using flutterFire cli');
    stderr.writeln(
        'You can run the command ${Colorize('flutterfire configure').bgBlack()} in terminal.');
    stderr.writeln(Colorize(
            'You can learn more here. https://firebase.flutter.dev/docs/cli\n')
        .dark());
    exitCode = 2;
  }
}
