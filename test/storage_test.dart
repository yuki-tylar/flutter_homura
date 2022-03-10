import 'dart:io';

import 'package:firebase_storage_mocks/firebase_storage_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:homura/flutter_homura/flutter_homura.dart';
import 'package:homura/flutter_homura/homura_config.dart';

import 'firebase_mock.dart';

var mockConfig = HomuraConfig();

// WARNING
// the package 'firebaseStorageMocks' itself is very week. I modified the package by myself.
// so, if the environment has been changed, this package won't work properly.
var mockStorage = MockFirebaseStorage();

void main() {
  group('Get url from storage', () {
    var filepath = '/images/image.png';
    setUpAll(() async {
      setupFirebaseAuthMocks();
      await Homura.i.fire(
        mockConfig,
        storage: mockStorage,
      );

      var file = File('image/image.png');
      await mockStorage.ref(filepath).putFile(file);
    });
    test('get file path with null value', () {
      var res = Homura.i.getFileURL(null);
      expect(res, isNull);
    });

    test('get file path that is actual http request', () {
      var res = Homura.i.getFileURL('https://example.com/path/to/file.png');
      expect(res, 'https://example.com/path/to/file.png');
    });

    test('get file path that does not exist', () async {
      String? res;
      try {
        await Homura.i.getFileURL('/not/exist/file/path.png');
      } catch (_) {
        res = null;
      }

      expect(res, isNull);
    });

    test('get file path', () async {
      // get from storage
      var res = await Homura.i.getFileURL(filepath);
      expect(res, 'fake://images/image.png');

      // get from cache in homura
      var res2 = Homura.i.getFileURL(filepath);
      expect(res2, 'fake://images/image.png');
    });
  });
}
