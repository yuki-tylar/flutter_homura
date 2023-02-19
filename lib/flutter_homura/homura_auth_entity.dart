import 'dart:convert';
import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:homura/flutter_homura/enum.dart';
import 'package:http/http.dart' as http;

class HomuraAuthEntity {
  /// logged in user using HomuraAuth
  User? get currentUser => _firebaseAuth.currentUser;

  /// currentUser's uid
  String? get uid => _firebaseAuth.currentUser?.uid;

  /// if currentUser is logged in or not
  bool get signedIn => currentUser != null;

  /// if currentUser's email is verified or not
  bool get verified => currentUser != null && currentUser!.emailVerified;

  /// name of HomuraAuthEntity
  String get name => _name;

  /// uri to entry point of authserver
  String get authServer => _authServer;

  FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  GoogleSignIn _googleSignin = GoogleSignIn();

  late String _name;
  late String _authServer;

  HomuraAuthEntity(
    String name, {
    FirebaseAuth? firebaseAuthInstance,
    GoogleSignIn? googleSignIn,
    String? authServer,
  }) {
    _name = name;
    _authServer = authServer ?? '';
    _firebaseAuth = firebaseAuthInstance ?? _firebaseAuth;
    _googleSignin = googleSignIn ?? _googleSignin;
    // TODO: add facebookAuth
  }

  Future<void> signOut() async {
    await Future.wait([
      _googleSignin.signOut(),
      _firebaseAuth.signOut(),
    ]);

    log('HomuraAuth:Logged out');
  }

  /// sign up.
  /// if AuthWith == email, must provide email and password
  /// if not, remap to signInWith()
  Future<void> signUpWith(
    AuthWith signUpWith, {
    String? email,
    String? password,
  }) async {
    switch (signUpWith) {
      case AuthWith.password:
        if (email == null) throw HomuraError.emailEmpty;
        if (password == null) throw HomuraError.passwordEmpty;

        try {
          await _signUpWithPassword(email, password);
        } on HomuraError catch (_) {
          rethrow;
        } catch (error) {
          log(
            "Failed at HomuraAuth.signInWith",
            error: error,
          );
          throw HomuraError.unknown;
        }
        break;

      default:
        await signInWith(signUpWith);
    }
  }

  /// sign in.
  /// if AuthWith == email, must provide email and password
  Future<void> signInWith(
    AuthWith signInWith, {
    String? email,
    String? password,
    String? customToken,
  }) async {
    switch (signInWith) {
      case AuthWith.password:
        if (email == null) throw HomuraError.emailEmpty;
        if (password == null) throw HomuraError.passwordEmpty;
        try {
          await _signInWithPassword(email, password);
        } on HomuraError catch (_) {
          rethrow;
        } catch (error) {
          log(
            "Failed at HomuraAuth.signInWith",
            error: error,
          );
          throw HomuraError.unknown;
        }
        break;

      case AuthWith.google:
        try {
          var credential = await _loginToGoogle();
          await _firebaseAuth.signInWithCredential(credential);
        } catch (error) {
          debugPrint(error.toString());
          log('Failed at HomuraAuth.signInWith.google. '
              'Please see error message above.');
          throw HomuraError.googleLoginFailed;
        }
        break;

      case AuthWith.facebook:
        throw HomuraError.notReadyYet;
      case AuthWith.apple:
        throw HomuraError.notReadyYet;

      case AuthWith.customToken:
        if (customToken == null) throw HomuraError.customTokenEmpty;
        try {
          await _firebaseAuth.signInWithCustomToken(customToken);
        } catch (error) {
          throw HomuraError.customTokenLoginFailed;
        }
    }
  }

  Future<String> getCustomToken(Uri uri) async {
    String customToken = '';
    String? idToken = await currentUser?.getIdToken();
    if (idToken == null) {
      throw HomuraError.userNotSignedIn;
    }

    try {
      var response = await http.post(
        uri,
        body: jsonEncode({'token': idToken}),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        customToken = response.body;
      } else {
        throw HomuraError.customTokenLoginFailed;
      }
    } catch (error) {
      throw HomuraError.customTokenLoginFailed;
    }
    return customToken;
  }

  /// check if given signin method is enabled for current user
  bool connectedTo(AuthWith authWith) {
    return currentUser == null
        ? false
        : currentUser!.providerData.indexWhere((element) =>
                RegExp(authWith.name).hasMatch(element.providerId)) >=
            0;
  }

  /// connect account to given provider
  Future<void> connectTo(AuthWith to) async {
    if (currentUser == null) throw HomuraError.userNotSignedIn;

    OAuthCredential credential;
    try {
      switch (to) {
        case AuthWith.google:
          credential = await _loginToGoogle();
          break;

        case AuthWith.facebook:
          throw HomuraError.notReadyYet;
        case AuthWith.apple:
          throw HomuraError.notReadyYet;
        default:
          throw HomuraError.unknown;
      }
      await currentUser!.linkWithCredential(credential);
    } on HomuraError catch (_) {
      rethrow;
    } catch (error) {
      debugPrint(error.toString());
      log('Failed at HomuraAuth.connectTo. '
          'Please see error message above.');
      throw HomuraError.connectFailed;
    }
  }

  /// disconnect account from given provider
  Future<void> disconnectFrom(AuthWith from) async {
    if (currentUser == null) throw HomuraError.userNotSignedIn;
    if (currentUser!.providerData.length <= 1) {
      throw HomuraError.needAtLeastOneProvider;
    }

    var providerData = currentUser!.providerData.firstWhere(
      (element) => RegExp(from.name).hasMatch(element.providerId),
      orElse: () => throw HomuraError.disconnectFailed,
    );

    try {
      await currentUser!.unlink(providerData.providerId);
    } catch (error) {
      throw HomuraError.disconnectFailed;
    }
  }

  /// send verification email
  Future<void> sendVerification() async {
    if (currentUser == null) throw HomuraError.userNotFound;
    if (currentUser!.email == null) throw HomuraError.emailNotFound;
    if (currentUser!.emailVerified) throw HomuraError.emailAlreadyVerified;

    await currentUser!.sendEmailVerification();
  }

  /// send  reset password email
  /// if email is not provided and currentUser doesn't exist, throw error
  Future<void> resetPassword(String email) async {
    if (email.isEmpty) {
      if (currentUser?.email == null || currentUser!.email!.isEmpty) {
        throw HomuraError.emailEmpty;
      }
      email = currentUser!.email!;
    }
    try {
      _firebaseAuth.sendPasswordResetEmail(email: email);
    } catch (error) {
      throw HomuraError.unknown;
    }
  }

  Future<void> _signInWithPassword(
    String email,
    String password,
  ) async {
    if (email.isEmpty) throw HomuraError.emailEmpty;
    if (password.isEmpty) throw HomuraError.passwordEmpty;

    try {
      var userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (userCredential.user == null) {
        throw HomuraError.unknown;
      }
    } on FirebaseAuthException catch (error) {
      switch (error.code) {
        case 'user-not-found':
          throw HomuraError.userNotFound;
        case 'invalid-email':
          throw HomuraError.emailInvalid;
        case 'wrong-password':
          throw HomuraError.passwordInvalid;
        case 'email-already-in-use':
          throw HomuraError.emailAlreadyInUse;
        default:
          throw HomuraError.unknown;
      }
    }
  }

  Future<void> _signUpWithPassword(
    String email,
    String password,
  ) async {
    if (email.isEmpty) throw HomuraError.emailEmpty;
    if (password.isEmpty) throw HomuraError.passwordEmpty;

    try {
      var result = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (result.user == null) throw HomuraError.unknown;
      await result.user!.sendEmailVerification();
    } on FirebaseAuthException catch (error) {
      switch (error.code) {
        case 'weak-password':
          throw HomuraError.passwordTooWeak;
        case 'email-already-in-use':
          throw HomuraError.emailAlreadyInUse;
        case 'invalid-email':
          throw HomuraError.emailInvalid;
        default:
          throw HomuraError.unknown;
      }
    } catch (error) {
      throw HomuraError.unknown;
    }
  }

  /// login to google using credential
  Future<OAuthCredential> _loginToGoogle() async {
    GoogleSignInAccount? account;

    try {
      account = await _googleSignin.signIn();
    } catch (error) {
      debugPrint(error.toString());
      log("Failed at HomuraAuth._loginToGoogle. "
          "Please see error message above.");
      throw (HomuraError.googleLoginFailed);
    }

    if (account == null) throw HomuraError.googleLoginFailed;

    var auth = await account.authentication;
    var credential = GoogleAuthProvider.credential(
      accessToken: auth.accessToken,
      idToken: auth.idToken,
    );
    return credential;
  }
}
