import 'dart:io';
import 'package:flutter_homura/homura_config.dart';

main() {
  // rewrite homura config if necessary.
  var original = 'web/index.html';
  var backup = 'tool/.tmp/_index.html';

  File(original).copy(backup);
  File(original).readAsString().then((String contents) {
    if (!isFirebaseVersionMatched(contents)) {
      //ignore: avoid_print
      print('rewriting homura config in web/index.html');
      var newContents = replaceHomuraConfig(contents);
      File('web/index.html').writeAsString(newContents);
    }
  });
}

bool isFirebaseVersionMatched(String contents) {
  var reg = RegExp('firebase@${homuraConfig["firebaseVersion"]}');
  return reg.hasMatch(contents);
}

String getHomuraConfig() {
  String config = '';
  config += '<!-- homura firebase@${homuraConfig["firebaseVersion"]} -->\n';
  config +=
      '  <script src="https://www.gstatic.com/firebasejs/${homuraConfig["firebaseVersion"]}/firebase-app.js"></script>\n';
  config +=
      '  <script src="https://www.gstatic.com/firebasejs/${homuraConfig["firebaseVersion"]}/firebase-auth.js"></script>\n';
  if (homuraConfig.containsKey('googleSigninClientId')) {
    config +=
        '  <meta name="google-signin-client_id" content="${homuraConfig['googleSigninClientId']}">\n';
  }
  if (homuraConfig.containsKey('facebookConfig')) {
    config +=
        '  <script async defer crossorigin="anonymous" src="https://connect.facebook.net/en_US/sdk.js"></script>\n';
  }

  config += '  <script>\n';
  config += '    const firebaseConfig = {\n';
  config += '      apiKey: "${homuraConfig["firebaseConfig"]["apiKey"]}",\n';
  config +=
      '      authDomain: "${homuraConfig["firebaseConfig"]["authDomain"]}",\n';
  config +=
      '      projectId: "${homuraConfig["firebaseConfig"]["projectId"]}",\n';
  config +=
      '      storageBucket: "${homuraConfig["firebaseConfig"]["storageBucket"]}",\n';
  config +=
      '      messagingSenderId: "${homuraConfig["firebaseConfig"]["messagingSenderId"]}",\n';
  config += '      appId: "${homuraConfig["firebaseConfig"]["appId"]}",\n';
  config +=
      '      measurementId: "${homuraConfig["firebaseConfig"]["measurementId"]}",\n';
  config += '    };\n';
  config += '    firebase.initializeApp(firebaseConfig);\n';
  config += '  </script>\n';

  config += '  <!-- homura end -->';
  return config;
}

String replaceHomuraConfig(String contents) {
  // var reg = RegExp(r'<!-- homura[0-9a-z@\s\.\->\n]*<!-- homura end -->');
  var reg = RegExp(r'<!-- homura[\S\s]*homura end -->');

  return contents.replaceFirst(reg, getHomuraConfig());
}
