import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:homura/flutter_homura/enum.dart';
import 'package:homura/flutter_homura/homura_config.dart';

abstract class _HomuraAuth {
  /// if HomuraAuth is configured or not
  bool get onFire;

  /// logged in user using HomuraAuth
  User? get currentUser;

  /// currentUser's uid
  String? get uid;

  /// if currentUser is logged in or not
  bool get signedIn;

  /// if currentUser's email is verified or not
  bool get verified;

  /// configure HomuraAuth
  void configure({
    FirebaseAuth? firebaseAuthInstance,
    GoogleSignIn? googleSignIn,
    // GoogleSigninConfig? googleSigninConfig,
    // FacebookSigninConfig? facebookSigninConfig,
  });

  /// sign up.
  /// if AuthWith == email, must provide email and password
  /// if not, remap to signInWith()
  Future<void> signUpWith(
    AuthWith signInWith, {
    String? email,
    String? password,
  });

  /// sign in.
  /// if AuthWith == email, must provide email and password
  Future<void> signInWith(
    AuthWith signInWith, {
    String? email,
    String? password,
  });

  void signOut();

  /// check if given signin method is enabled for current user
  bool connectedTo(AuthWith authWith);

  /// connect account to given provider
  Future<void> connectTo(AuthWith to);

  /// connect account from given provider
  Future<void> disconnectFrom(AuthWith to);

  /// send verification email
  Future<void> sendVerification();

  /// send  reset password email
  /// if email is not provided and currentUser doesn't exist, throw error
  Future<void> resetPassword(String email);
}

class HomuraAuth implements _HomuraAuth {
  FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  GoogleSignIn _googleSignin = GoogleSignIn();
  // GoogleSigninConfig? _googleSigninConfig;
  // FacebookSigninConfig? _facebookSigninConfig;
  bool _onFire = false;

  HomuraAuth._();
  static HomuraAuth instance = HomuraAuth._();
  static HomuraAuth i = HomuraAuth._();

  @override
  bool get onFire => _onFire;

  @override
  User? get currentUser => _firebaseAuth.currentUser;

  @override
  String? get uid => currentUser?.uid;

  @override
  bool get signedIn => currentUser != null;

  @override
  bool get verified => currentUser != null && currentUser!.emailVerified;

  @override
  void configure({
    FirebaseAuth? firebaseAuthInstance,
    GoogleSignIn? googleSignIn,
    // GoogleSigninConfig? googleSigninConfig,
    // FacebookSigninConfig? facebookSigninConfig,
  }) {
    _firebaseAuth = firebaseAuthInstance ?? _firebaseAuth;
    _googleSignin = googleSignIn ?? _googleSignin;
    // _googleSigninConfig = googleSigninConfig;
    // _facebookSigninConfig = facebookSigninConfig;

    // TODO: add facebookAuth
    _onFire = true;
  }

  @override
  void signOut() {
    _googleSignin.signOut();
    _firebaseAuth.signOut();
    // TODO: add facebookAuth

    log('HomuraAuth:Logged out');
  }

  @override
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

  @override
  Future<void> signInWith(
    AuthWith signInWith, {
    String? email,
    String? password,
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
          throw HomuraError.googleLoginFailed;
        }
        break;

      case AuthWith.facebook:
        throw HomuraError.notReadyYet;
      case AuthWith.apple:
        throw HomuraError.notReadyYet;
    }
  }

  @override
  bool connectedTo(AuthWith authWith) {
    return currentUser == null
        ? false
        : currentUser!.providerData.indexWhere((element) =>
                RegExp(authWith.name).hasMatch(element.providerId)) >=
            0;
  }

  @override
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
      throw HomuraError.connectFailed;
    }
  }

  @override
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

  @override
  Future<void> sendVerification() async {
    if (currentUser == null) throw HomuraError.userNotFound;
    if (currentUser!.email == null) throw HomuraError.emailNotFound;
    if (currentUser!.emailVerified) throw HomuraError.emailAlreadyVerified;

    await currentUser!.sendEmailVerification();
  }

  @override
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
      log(
        "Failed at HomuraAuth._loginToGoogle",
        error: error,
      );
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
