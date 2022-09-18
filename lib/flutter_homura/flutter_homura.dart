import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart' show debugPrint, kIsWeb;
import 'package:homura/flutter_homura/homura_config.dart';
import 'enum.dart';
import 'user_data.dart';
import '../firebase_options.dart';

final _authFB = FacebookAuth.instance;

class Homura {
  Homura._(); // private constructor for singletons

  static Homura instance = Homura._();
  static Homura i = Homura._();

  late FirebaseAuth _auth = FirebaseAuth.instance;
  late GoogleSignIn _authGoogle = GoogleSignIn();
  late FirebaseStorage _storage = FirebaseStorage.instance;
  final Map<String, String> _fileURLCache = {};

  bool get onFire => Firebase.apps.isNotEmpty;

  bool get signedIn {
    return _auth.currentUser != null;
  }

  String? get uid {
    return _auth.currentUser?.uid;
  }

  User? get currentUser {
    return _auth.currentUser;
  }

  bool get isUserVerified {
    return currentUser != null && currentUser!.emailVerified;
  }

  bool isConnectedTo(AuthWith authWith) {
    return currentUser == null
        ? false
        : currentUser!.providerData.indexWhere((element) =>
                RegExp(authWith.name).hasMatch(element.providerId)) >=
            0;
  }

  Future<bool> fire(
    HomuraConfig config, {
    FirebaseAuth? firebaseAuthInstance,
    GoogleSignIn? googleSignIn,
    FirebaseStorage? storage,
  }) async {
    if (firebaseAuthInstance != null) _auth = firebaseAuthInstance;
    if (googleSignIn != null) _authGoogle = googleSignIn;
    if (storage != null) _storage = storage;

    if (kIsWeb) {
      var fb = config.signinFacebook;
      if (fb.enabled && !_authFB.isWebSdkInitialized) {
        _authFB.webInitialize(
          appId: fb.appId,
          cookie: fb.cookie,
          xfbml: fb.xfbml,
          version: fb.version,
        );
      }
    }

    if (Firebase.apps.isEmpty) {
      try {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
        return true;
      } on FirebaseException catch (e) {
        if (RegExp(r'core/duplicate-app').hasMatch(e.toString())) {
          return true;
        } else {
          throw HomuraError.notInitialized;
        }
      } catch (error) {
        debugPrint(''
            'Fatal error: Could not initialized firebase by homura\n'
            'errcode: HOMURA_FIRE_01\n'
            '$error');
        throw HomuraError.notInitialized;
      }
    } else {
      Firebase.app();
    }
    return true;
  }

  void signOut() {
    _authFB.logOut();
    _authGoogle.signOut();
    _auth.signOut();
  }

  Future<UserData> signInWith(
    AuthWith signInWith, {
    String? email,
    String? password,
  }) async {
    late Future<UserData> req;
    switch (signInWith) {
      case AuthWith.password:
        if (email == null) {
          throw HomuraError.emailEmpty;
        } else if (password == null) {
          throw HomuraError.passwordEmpty;
        }
        req = _signInWithPassword(_auth, email, password);
        break;
      case AuthWith.google:
        req = _signInWithGoogle(_auth, _authGoogle);
        break;
      case AuthWith.facebook:
        req = _signInWithFacebook(_auth);
        break;
      case AuthWith.apple:
        throw HomuraError.notReadyYet;
    }

    return await req;
  }

  Future<UserData> signUpWith(
    AuthWith signUpWith, {
    String? email,
    String? password,
  }) async {
    late Future<UserData> req;
    switch (signUpWith) {
      case AuthWith.password:
        if (email == null) {
          throw HomuraError.emailEmpty;
        } else if (password == null) {
          throw HomuraError.passwordEmpty;
        }
        req = _signUpWithPassword(_auth, email, password);
        break;
      default:
        req = signInWith(signUpWith);
    }

    return await req;
  }

  Future<bool> connectTo(AuthWith to) async {
    if (currentUser == null) {
      throw HomuraError.userNotSignedIn;
    }

    late Future<Map<_AuthDataItem, dynamic>> req;
    switch (to) {
      case AuthWith.google:
        req = _loginToGoogle(_authGoogle);
        break;
      case AuthWith.facebook:
        req = _loginToFacebook();
        break;
      case AuthWith.apple:
        throw HomuraError.notReadyYet;
      default:
    }
    try {
      var res = await req;
      await currentUser!.linkWithCredential(res[_AuthDataItem.credential]);
      return true;
    } catch (error) {
      throw HomuraError.connectFailed;
    }
  }

  Future<bool> disconnectFrom(AuthWith from) async {
    if (currentUser == null) {
      throw HomuraError.userNotSignedIn;
    } else if (currentUser!.providerData.length <= 1) {
      throw HomuraError.needAtLeastOneProvider;
    }

    var providerData = currentUser!.providerData.firstWhere(
      (element) => RegExp(from.name).hasMatch(element.providerId),
      orElse: () => throw HomuraError.disconnectFailed,
    );

    try {
      await currentUser!.unlink(providerData.providerId);
      return true;
    } catch (error) {
      throw HomuraError.disconnectFailed;
    }
  }

  Future<void> sendVerification() async {
    if (currentUser == null) {
      throw HomuraError.userNotFound;
    } else if (currentUser!.email == null) {
      throw HomuraError.emailNotFound;
    } else if (currentUser!.emailVerified) {
      throw HomuraError.emailAlreadyVerified;
    } else {
      await currentUser!.sendEmailVerification();
    }
  }

  Future<void> resetPassword({String email = ''}) async {
    if (email.isNotEmpty) {
      await _auth.sendPasswordResetEmail(email: email);
    } else if (currentUser == null) {
      throw HomuraError.userNotFound;
    } else if (currentUser!.email == null) {
      throw HomuraError.emailNotFound;
    } else {
      await _auth.sendPasswordResetEmail(email: currentUser!.email!);
    }
  }

  FutureOr<String?> getFileURL(String? image) {
    if (image == null || image.isEmpty) return null;
    if (image.startsWith('http')) return image;
    if (_fileURLCache[image] != null) return _fileURLCache[image];

    return _storage.ref(image).getDownloadURL().then((String res) {
      _fileURLCache[image] = res;
      return res;
    }).onError((error, stackTrace) {
      debugPrint('warning: could not get downloadURL.\n'
          'errcode: HOMURA_GFU_01\n'
          '$error');
      throw HomuraError.getFileURLFailed;
    });
  }
}

Future<UserData> _signInWithPassword(
  FirebaseAuth auth,
  String email,
  String password,
) async {
  if (email.isEmpty) {
    throw HomuraError.emailEmpty;
  } else if (password.isEmpty) {
    throw HomuraError.passwordEmpty;
  }
  try {
    var userCredential = await auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    if (userCredential.user != null) {
      return UserData.fromPassword(userCredential.user!);
    } else {
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

Future<UserData> _signUpWithPassword(
  FirebaseAuth auth,
  String email,
  String password,
) async {
  if (email.isEmpty) {
    throw HomuraError.emailEmpty;
  } else if (password.isEmpty) {
    throw HomuraError.passwordEmpty;
  }
  try {
    var result = await auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    if (result.user == null) {
      throw HomuraError.unknown;
    } else {
      await result.user!.sendEmailVerification();
      return UserData.fromPassword(result.user!);
    }
  } on FirebaseAuthException catch (error) {
    switch (error.code) {
      case 'weak-password':
        throw HomuraError.passwordTooWeak;
      case 'email-already-in-use':
        throw HomuraError.emailAlreadyInUse;
      case 'invalid-email':
        throw HomuraError.emailInvalid;
      default:
        // print(error.code);
        throw HomuraError.unknown;
    }
  } catch (error) {
    // print(error);
    throw HomuraError.unknown;
  }
}

Future<UserData> _signInWithGoogle(
  FirebaseAuth auth,
  GoogleSignIn authGoogle,
) async {
  Map<_AuthDataItem, dynamic> result;
  try {
    result = await _loginToGoogle(authGoogle);
    await auth.signInWithCredential(result[_AuthDataItem.credential]);
  } catch (error) {
    throw HomuraError.googleLoginFailed;
  }

  return UserData.fromGoogle(
    auth.currentUser!.uid,
    result[_AuthDataItem.account],
  );
}

Future<UserData> _signInWithFacebook(FirebaseAuth auth) async {
  Map<_AuthDataItem, dynamic> result;
  try {
    result = await _loginToFacebook();
    await auth.signInWithCredential(result['credential']);
  } on HomuraError {
    rethrow;
  } on FirebaseException catch (error) {
    switch (error.code) {
      case 'account-exists-with-different-credential':
        throw HomuraError.emailAlreadyInUse;
      default:
        debugPrint(''
            'Could not signin with facebook.\n'
            'errcode: HOMURA_SIWF_01\n'
            '$error');
        throw HomuraError.facebookLoginFailed;
    }
  } catch (error) {
    debugPrint(''
        'Could not signin with facebook.\n'
        'errcode: HOMURA_SIWF_02\n'
        '$error');

    throw HomuraError.facebookLoginFailed;
  }

  return UserData.fromFacebook(
    auth.currentUser!.uid,
    result['account'],
  );
}

Future<Map<_AuthDataItem, dynamic>> _loginToGoogle(
  GoogleSignIn authGoogle,
) async {
  GoogleSignInAccount? account;
  try {
    account = await authGoogle.signIn();
  } catch (error) {
    debugPrint(''
        'Warning: Could not loginin to google\n'
        'errcode: HOMURA_LTG_01');
    throw (HomuraError.googleLoginFailed);
  }

  if (account == null) {
    throw HomuraError.googleLoginFailed;
  }

  var auth = await account.authentication;
  var credential = GoogleAuthProvider.credential(
    accessToken: auth.accessToken,
    idToken: auth.idToken,
  );

  return {
    _AuthDataItem.account: account,
    _AuthDataItem.credential: credential,
  };
}

Future<Map<_AuthDataItem, dynamic>> _loginToFacebook() async {
  LoginResult loginResult;
  Map<String, dynamic> userData;

  try {
    loginResult = await _authFB.login();
    userData = await _authFB.getUserData();
  } catch (error) {
    throw HomuraError.facebookLoginFailed;
  }

  if (loginResult.accessToken == null) {
    throw HomuraError.facebookLoginGetAccessTokenFailed;
  }

  var credential =
      FacebookAuthProvider.credential(loginResult.accessToken!.token);

  return {
    _AuthDataItem.account: userData,
    _AuthDataItem.credential: credential,
  };
}

enum _AuthDataItem {
  account,
  credential,
}
