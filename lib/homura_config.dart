import 'package:flutter_homura/flutter_homura/enum.dart';

final homuraConfig = HomuraConfig(
  signinGoogle: GoogleSigninConfig(
    webClientId:
        '1003220743691-k3mpmea3ns1feprkgt541obh6cfbbkmm.apps.googleusercontent.com',
  ),
  signinFacebook: FacebookSigninConfig(
    appId: '1139752049798678',
    version: 'v12.0',
  ),
);

class HomuraConfig {
  final String firebaseVersion;
  late GoogleSigninConfig signinGoogle;
  late FacebookSigninConfig signinFacebook;

  HomuraConfig({
    this.firebaseVersion = '8.10.0',
    signinGoogle,
    signinFacebook,
  }) {
    this.signinGoogle = signinGoogle ??
        GoogleSigninConfig(
          enabled: false,
        );
    this.signinFacebook = signinFacebook ??
        FacebookSigninConfig(
          enabled: false,
        );
  }
}

class GoogleSigninConfig extends OAuthSigninConfig {
  String webClientId;
  GoogleSigninConfig({
    enabled = true,
    this.webClientId = '',
  }) : super(
          enabled: enabled,
          provider: AuthWith.google,
        ) {
    if (enabled && webClientId.isEmpty) {
      throw 'google-signin-config-initialize-failed';
    }
  }
}

class FacebookSigninConfig extends OAuthSigninConfig {
  String appId;
  String version;
  bool cookie;
  bool xfbml;

  FacebookSigninConfig({
    this.appId = '',
    this.version = '',
    this.cookie = true,
    this.xfbml = true,
    enabled = true,
  }) : super(
          enabled: enabled,
          provider: AuthWith.facebook,
        ) {
    if (enabled) {
      if (appId.isEmpty || version.isEmpty) {
        throw 'facebook-signin-config-initilize-failed';
      }
    }
  }
}

abstract class OAuthSigninConfig {
  bool enabled;
  AuthWith provider;

  OAuthSigninConfig({
    required this.provider,
    this.enabled = true,
  });
}
