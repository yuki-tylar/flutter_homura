import 'dart:io';
import 'package:colorize/colorize.dart';
import 'package:homura/homura_config.dart';

import '_generate_random_string.dart';
import '_get_firebase_options.dart';
import '_get_reversed_id.dart';

initIos() async {
  stdout.writeln('Initializing homura setting for ios...');
  try {
    await initProj();
    await initInfo();
  } catch (error) {
    rethrow;
  }
  stdout.writeln('Initialized homura setting for ios');
}

Future<void> initInfo() async {
  stdout.writeln(Colorize('  Initializing ios/Runner/info.plist...').dark());
  var original = 'ios/Runner/info.plist';
  var backup = 'tools/.tmp/_info.plist';
  File(original).copy(backup);

  var option = await getFirebaseOption(FirebaseOptionType.ios);
  var config = '';
  if (homuraConfig.signinGoogle.enabled ||
      homuraConfig.signinFacebook.enabled) {
    config = (''
        '  <!-- homura section start -->\n'
        '  <key>CFBundleURLTypes</key>\n'
        '  <array>\n'
        '    <dict>\n'
        '      <key>CFBundleTypeRole</key>\n'
        '      <string>Editor</string>\n'
        '      <key>CFBundleURLSchemes</key>\n'
        '      <array>\n'
        '${homuraConfig.signinGoogle.enabled ? '        <string>${getReversedId(option['iosClientId'])}</string>\n' : ''}'
        '${homuraConfig.signinFacebook.enabled ? '        <string>fb${homuraConfig.signinFacebook.appId}</string>\n' : ''}'
        '      </array>\n'
        '    </dict>\n'
        '  </array>\n'
        '${homuraConfig.signinFacebook.enabled ? (''
            '  <key>FacebookAppID</key>\n'
            '  <string>${homuraConfig.signinFacebook.appId}</string>\n'
            '  <key>FacebookClientToken</key>\n'
            '  <string>${homuraConfig.signinFacebook.clientToken}</string>\n'
            '  <key>FacebookDisplayName</key>\n'
            '  <string>${homuraConfig.signinFacebook.appName}</string>\n'
            '  <key>LSApplicationQueriesSchemes</key>\n'
            '  <array>\n'
            '    <string>fbapi</string>\n'
            '    <string>fb-messenger-share-api</string>\n'
            '    <string>fbauth2</string>\n'
            '    <string>fbshareextension</string>\n'
            '  </array>\n'
            '') : ''}'
        '  <!-- homura section end -->\n'
        '');
  }

  var contents = File(original).readAsStringSync();
  var reg = RegExp(
      r'\s*<!-- homura section start -->[\s\S]*?<!-- homura section end -->\s');
  if (!reg.hasMatch(contents)) {
    reg = RegExp(r'</dict>\s*</plist>\s*$');
    var matched = reg.firstMatch(contents);
    if (matched == null) {
      throw 'not-found-right-place-to-write-homura-setting-in-info_plist';
    }
    contents = contents.replaceFirst(
      reg,
      config + (matched.group(0) ?? ''),
    );
  } else {
    contents = contents.replaceFirst(
      reg,
      '\n$config',
    );
  }
  File(original).writeAsStringSync(contents);
  stdout.writeln(Colorize('  Initialized ios/Runner/info.plist').dark());
}

Future<void> initProj() async {
  var original = 'ios/Runner.xcodeproj/project.pbxproj';
  var backup = 'tools/.tmp/_project.pbxproj';
  File(original).copy(backup);

  var contents = File(original).readAsStringSync();
  var reg = RegExp(r'GoogleService-Info\.plist');
  if (reg.hasMatch(contents)) {
    return;
  }

  var result = addPBXFileReference(contents);
  var fileRef = result.id;
  result = addPBXBuildFile(fileRef, result.contents);
  var buildFileRef = result.id;
  var resultContents = addPBXGroup(fileRef, result.contents);
  resultContents = addPBXResourcesBuildPhase(buildFileRef, resultContents);
  File(original).writeAsString(resultContents);
}

List<String> getKeys(String data) {
  var reg = RegExp(r'\b[A-Z0-9]+\b');
  var keys = reg.allMatches(data);

  return keys.map((key) => key.group(0) ?? '').toList();
}

_WriteResult addPBXFileReference(String contents) {
  var reg = RegExp(
      r'\/\* Begin PBXFileReference section \*\/([\s\S]*)/* End PBXFileReference section \*\/');
  var data = reg.firstMatch(contents)?.group(1) ?? '';

  if (data.isEmpty) {
    throw 'Error';
  }

  var id = generateRandomString(
    length: 24,
    uppercase: true,
    number: true,
    excludes: getKeys(data),
  );

  var insert =
      '$id /* GoogleService-Info.plist */ = {isa = PBXFileReference; fileEncoding = 4; lastKnownFileType = text.plist.xml; path = "GoogleService-Info.plist"; sourceTree = "<group>"; };';
  contents = contents.replaceFirst(
    '/* End PBXFileReference section */',
    '    $insert\n/* End PBXFileReference section */',
  );

  return _WriteResult(id, contents);
}

_WriteResult addPBXBuildFile(String fileRef, String contents) {
  var reg = RegExp(
      r'\/\* Begin PBXBuildFile section \*\/([\s\S]*)/* End PBXBuildFile section \*\/');
  var data = reg.firstMatch(contents)?.group(1) ?? '';

  if (data.isEmpty) {
    throw 'Error';
  }

  var id = generateRandomString(
    length: 24,
    uppercase: true,
    number: true,
    excludes: getKeys(data),
  );

  var insert =
      '$id /* GoogleService-Info.plist in Resources */ = {isa = PBXBuildFile; fileRef = $fileRef /* GoogleService-Info.plist */; };';
  contents = contents.replaceFirst(
    '/* End PBXBuildFile section */',
    '    $insert\n/* End PBXBuildFile section */',
  );

  return _WriteResult(id, contents);
}

String addPBXGroup(String fileRef, String contents) {
  var reg = RegExp(
      r'\/\* Begin PBXGroup section \*\/([\s\S]*)/* End PBXGroup section \*\/');
  var data = reg.firstMatch(contents)?.group(1) ?? '';
  if (data.isEmpty) {
    throw 'Error';
  }
  reg = RegExp(r'\/\* Runner \*\/ = {[\s\S]*?children = \(\s([\s\S]*?)\s*\);');

  var dataRunner = reg.firstMatch(contents)?.group(1) ?? '';
  if (dataRunner.isEmpty) {
    throw 'Error';
  }

  contents = contents.replaceFirst(
    dataRunner,
    '        $fileRef /* GoogleService-Info.plist */,\n$dataRunner',
  );
  return contents;
}

String addPBXResourcesBuildPhase(String fileRef, String contents) {
  var reg = RegExp(
      r'\/\* Begin PBXResourcesBuildPhase section \*\/([\s\S]*)/* End PBXResourcesBuildPhase section \*\/');
  var data = reg.firstMatch(contents)?.group(1) ?? '';
  if (data.isEmpty) {
    throw 'Error';
  }
  reg = RegExp(r'files = \(\s*([\s\S]*?)\s*\);');
  var dataFiles = reg.firstMatch(data)?.group(1) ?? '';
  contents = contents.replaceFirst(
    dataFiles,
    '$dataFiles\n        $fileRef /* GoogleService-Info.plist in Resources */',
  );
  return contents;
}

class _WriteResult {
  String id;
  String contents;

  _WriteResult(this.id, this.contents);
}
