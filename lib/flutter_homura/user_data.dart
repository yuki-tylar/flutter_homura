import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_homura/flutter_homura/enum.dart';
import 'package:google_sign_in/google_sign_in.dart';

class UserData {
  late String uid;
  String? name;
  String? profileImage;
  String? email;
  String? phone;
  late AuthWith authWith;

  UserData();
  UserData.fromPassword(User user) {
    uid = user.uid;
    email = user.email;
    authWith = AuthWith.password;
  }

  UserData.fromGoogle(
    this.uid,
    GoogleSignInAccount user,
  ) {
    name = user.displayName;
    email = user.email;
    authWith = AuthWith.google;
    profileImage = user.photoUrl;
  }
  UserData.fromFacebook(
    this.uid,
    Map<String, dynamic> user,
  ) {
    name = user['name'];
    email = user['email'];
    profileImage = user['picture']?['data']?['url'];
    authWith = AuthWith.facebook;
  }
}
