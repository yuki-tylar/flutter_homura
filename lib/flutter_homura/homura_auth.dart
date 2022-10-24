import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:homura/flutter_homura/enum.dart';
import 'package:homura/flutter_homura/homura_auth_entity.dart';

class HomuraAuth {
  final Map<String, HomuraAuthEntity> _entities = {};

  HomuraAuth._();
  static HomuraAuth instance = HomuraAuth._();
  static HomuraAuth i = HomuraAuth._();

  HomuraAuthEntity get entity => entityOf('Default');

  HomuraAuthEntity entityOf(String name) {
    if (!_entities.containsKey(name)) {
      throw HomuraError.notReadyYet;
    } else {
      return _entities[name]!;
    }
  }

  void configure({
    String name = 'Default',
    FirebaseAuth? firebaseAuthInstance,
    GoogleSignIn? googleSignIn,
    // GoogleSigninConfig? googleSigninConfig,
    // FacebookSigninConfig? facebookSigninConfig,
  }) {
    if (!_entities.containsKey(name)) {
      _entities[name] = HomuraAuthEntity(
        firebaseAuthInstance: firebaseAuthInstance,
        googleSignIn: googleSignIn,
      );
    }
  }
}
