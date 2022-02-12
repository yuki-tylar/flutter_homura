import 'package:homura/flutter_homura/homura_config.dart';

final homuraConfig = HomuraConfig(
  signinGoogle: GoogleSigninConfig(
    webClientId:
        '1003220743691-k3mpmea3ns1feprkgt541obh6cfbbkmm.apps.googleusercontent.com',
  ),
  signinFacebook: FacebookSigninConfig(
    appName: 'flutter homura test',
    appId: '1139752049798678',
    version: 'v12.0',
    clientToken: '37c863c02adf7fc22a3938b4bd56cde3',
  ),
);
