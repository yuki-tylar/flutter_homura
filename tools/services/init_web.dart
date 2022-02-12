import 'dart:io';
import 'package:homura/homura_config.dart';

import '_get_firebase_options.dart';

initWeb() async {
  await initIndex();
  exitCode = 0;
}

Future<void> initIndex() async {
  stdout.writeln('Initializing web/index.html...');
  var original = 'web/index.html';
  var backup = 'tools/.tmp/_index.html';

  File(original).copy(backup);
  var contents = File(original).readAsStringSync();
  late String newContents = '';
  if (!existsHomuraConfig(contents)) {
    newContents = await addHomuraConfig(contents);
  } else {
    newContents = await replaceHomuraConfig(contents);
  }
  File('web/index.html').writeAsStringSync(newContents);
  stdout.writeln('Initialized web/index.html\n');
}

bool existsHomuraConfig(String contents) {
  var reg = RegExp('<!-- homura');
  return reg.hasMatch(contents);
}

bool isFirebaseVersionMatched(String contents) {
  var reg = RegExp('firebase@${homuraConfig.firebaseVersion}');
  return reg.hasMatch(contents);
}

Future<String> getHomuraConfig() async {
  var option = await getFirebaseOption(FirebaseOptionType.web);

  print(option.entries
      .map((e) => '${e.key}: "${e.value}",\n')
      .toList()
      .toString());

  String config = (''
      '<!-- homura firebase@${homuraConfig.firebaseVersion} -->\n'
      '  <script src="https://www.gstatic.com/firebasejs/${homuraConfig.firebaseVersion}/firebase-app.js"></script>\n'
      '  <script src="https://www.gstatic.com/firebasejs/${homuraConfig.firebaseVersion}/firebase-auth.js"></script>\n'
      '  ${homuraConfig.signinGoogle.enabled ? '  <meta name="google-signin-client_id" content="${homuraConfig.signinGoogle.webClientId}">\n' : ''}'
      '  ${homuraConfig.signinFacebook.enabled ? '  <script async defer crossorigin="anonymous" src="https://connect.facebook.net/en_US/sdk.js"></script>\n' : ''}'
      '  <script>\n'
      '    const firebaseConfig = {\n'
      '${option.entries.map((e) => '      ${e.key}: "${e.value}",\n').toList().join()}'
      // '      apiKey: "${option["apiKey"]}",\n'
      // '      authDomain: "${option['authDomain']}",\n'
      // '      projectId: "${option['projectId']}",\n'
      // '      storageBucket: "${option['storageBucket']}",\n'
      // '      messagingSenderId: "${option['messagingSenderId']}",\n'
      // '      appId: "${option['appId']}",\n'
      // '      measurementId: "${option['measurementId']}",\n'
      '    };\n'
      '    firebase.initializeApp(firebaseConfig);\n'
      '  </script>\n'
      '  <!-- homura end -->'
      '');
  return config;
}

Future<String> addHomuraConfig(String contents) async {
  var config = await getHomuraConfig();
  return contents.replaceFirst('<body>', '<body>\n  $config\n');
}

Future<String> replaceHomuraConfig(String contents) async {
  var reg = RegExp(r'<!-- homura[\S\s]*homura end -->');
  var config = await getHomuraConfig();

  return contents.replaceFirst(reg, config);
}
