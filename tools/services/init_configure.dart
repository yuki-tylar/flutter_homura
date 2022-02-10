import 'dart:io';
import './init_ios.dart';
import './init_web.dart';

main() async {
  //read firebase_options
  var path = 'lib/firebase_options.dart';
  var contents = File(path).readAsStringSync();
  if (existsIosConfig(contents)) {
    try {
      await initIos();
    } catch (error) {
      stderr.writeln(error);
      exitCode = 2;
    }
  }

  if (existsWebConfig(contents)) {
    await initWeb();
  }
}

bool existsWebConfig(String contents) {
  var reg = RegExp(
      r'static const FirebaseOptions web = FirebaseOptions\(([\s\S^]*?)\);');
  return reg.hasMatch(contents);
}

bool existsIosConfig(String contents) {
  var reg = RegExp(
      r'static const FirebaseOptions ios = FirebaseOptions\(([\s\S^]*?)\);');
  return reg.hasMatch(contents);
}
