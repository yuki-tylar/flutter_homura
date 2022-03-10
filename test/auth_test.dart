// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in_mocks/google_sign_in_mocks.dart';
import 'package:homura/flutter_homura/enum.dart';
import 'package:homura/flutter_homura/flutter_homura.dart';
import 'package:homura/flutter_homura/homura_config.dart';
import 'firebase_mock.dart';

var mockUser = MockUser(
  uid: 'TestUID',
  email: 'test@gmail.com',
  displayName: 'TestName',
);
var firebaseAuth = MockFirebaseAuth(mockUser: mockUser);
var googleAuth = MockGoogleSignIn();
var mockConfig = HomuraConfig();

void main() {
  group('Signin by password before initialization', () {
    setUpAll(() async {
      setupFirebaseAuthMocks();
    });

    test('check if homura is not on fire', () {
      var onFire = Homura.i.onFire;
      expect(onFire, false);
    });

    test('check if signin with password NOT works', () async {
      bool res;
      try {
        await Homura.i.signInWith(
          AuthWith.password,
          email: 'test@gmail.com',
          password: 'anypasswordd',
        );
        res = true;
      } catch (_) {
        res = false;
      }
      expect(res, false);
    });
  });

  group('Signin by password after initialization', () {
    setUpAll(() async {
      setupFirebaseAuthMocks();
      await Homura.i.fire(
        mockConfig,
        firebaseAuthInstance: firebaseAuth,
        googleSignIn: googleAuth,
      );
    });

    test('check if homura is on fire', () {
      var onFire = Homura.i.onFire;
      expect(onFire, true);
    });

    test('check if signin with password works', () async {
      var res = await Homura.i.signInWith(
        AuthWith.password,
        email: 'test@gmail.com',
        password: 'anypasswordd',
      );
      expect(res.email, 'test@gmail.com');
    });
  });
}
