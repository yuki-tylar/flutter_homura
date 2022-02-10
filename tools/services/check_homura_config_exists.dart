import 'dart:io';

import 'package:colorize/colorize.dart';

main() async {
  var path = 'lib/homura_config.dart';
  var result = await FileSystemEntity.isFile(path);
  if (result) {
    exitCode = 0;
  } else {
    stderr.writeln(
      Colorize('Error: Could not find homura_config.dart').red(),
    );
    stderr.writeln('Please set the file within lib folder\n');
    exitCode = 2;
  }
}
