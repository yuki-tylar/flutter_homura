import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:homura/flutter_homura/enum.dart';
import 'package:homura/flutter_homura/homura_auth_entity.dart';

class HomuraAuth {
  static const _defaultEntityName = 'default';

  final Map<String, HomuraAuthEntity> _entities = {};

  HomuraAuth._();
  static HomuraAuth instance = HomuraAuth._();
  static HomuraAuth i = HomuraAuth._();

  HomuraAuthEntity get entity => entityOf(_defaultEntityName);

  Iterable<HomuraAuthEntity> get entities => _entities.values;
  Iterable<String> get entityNames => _entities.keys;

  HomuraAuthEntity entityOf(String name) {
    if (!_entities.containsKey(name)) {
      throw HomuraError.notReadyYet;
    } else {
      return _entities[name]!;
    }
  }

  void configure({
    String? name,
    FirebaseAuth? firebaseAuthInstance,
    GoogleSignIn? googleSignIn,
    // GoogleSigninConfig? googleSigninConfig,
    // FacebookSigninConfig? facebookSigninConfig,
    bool isDefault = false,
  }) {
    name = isDefault ? _defaultEntityName : name;
    if (name == null) throw HomuraError.homuraAuthNameEmpty;

    if (name == _defaultEntityName && !isDefault) {
      throw HomuraError.homuraAuthNameDisallowed;
    }

    if (!_entities.containsKey(name)) {
      _entities[name] = HomuraAuthEntity(
        name,
        firebaseAuthInstance: firebaseAuthInstance,
        googleSignIn: googleSignIn,
      );
    }
  }
}
