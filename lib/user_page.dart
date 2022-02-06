import 'package:flutter/material.dart';
import 'package:flutter_homura/display_auth_info.dart';
import 'package:flutter_homura/display_user_data.dart';
import 'package:flutter_homura/flutter_homura/flutter_homura.dart';
import 'package:flutter_homura/flutter_homura/user_data.dart';
import 'package:flutter_homura/not_loggedin.dart';

class UserPage extends StatefulWidget {
  const UserPage({Key? key}) : super(key: key);

  @override
  _UserPageState createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  UserData? userData;

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    double width = size.width > 600 ? 500 : (size.width - 30);
    return Scaffold(
      appBar: AppBar(
        title: const Text('FlutterHomura test'),
      ),
      body: Container(
        margin: const EdgeInsets.only(top: 100),
        alignment: Alignment.center,
        child: SizedBox(
          width: width,
          child: ListView(
            children: [
              if (!Homura.i.signedIn) ...[
                NotLoggedInSection(onLoginFormClosed: (data) {
                  setState(() {
                    userData = data;
                  });
                })
              ],
              if (Homura.i.signedIn) ...[
                if (userData != null) DisplayUserData(userData: userData!),
                const DisplayAuthInfo(),
                Container(
                  margin: const EdgeInsets.only(top: 50),
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        Homura.i.signOut();
                      });
                    },
                    child: const Text('Sign out'),
                  ),
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }
}
