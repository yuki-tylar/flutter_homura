import 'package:flutter/material.dart';
import 'package:flutter_homura/demo/display_auth_info_oauth.dart';
import 'package:flutter_homura/demo/display_auth_info_password.dart';
import 'package:flutter_homura/demo/display_auth_info_verification.dart';
import 'package:flutter_homura/flutter_homura/enum.dart';

class DisplayAuthInfo extends StatelessWidget {
  const DisplayAuthInfo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: 30),
          child: Text(
            'You are currently logged in.',
            style: Theme.of(context).textTheme.headline5,
          ),
        ),
        Container(
          margin: const EdgeInsets.only(bottom: 30),
          child: const DisplayAuthInfoVerification(),
        ),
        Container(
          margin: const EdgeInsets.only(bottom: 30),
          child: const DisplayAuthInfoPassword(),
        ),
        Container(
          margin: const EdgeInsets.only(bottom: 30),
          child: const DisplayAuthInfoOAuth(
            authWith: AuthWith.google,
          ),
        ),
        Container(
          margin: const EdgeInsets.only(bottom: 30),
          child: const DisplayAuthInfoOAuth(
            authWith: AuthWith.facebook,
          ),
        ),
      ],
    );
  }
}
