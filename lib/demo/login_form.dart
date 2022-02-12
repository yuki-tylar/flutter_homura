import 'package:flutter/material.dart';
import 'package:homura/flutter_homura/enum.dart';
import 'package:homura/flutter_homura/flutter_homura.dart';
import 'package:homura/flutter_homura/user_data.dart';

class LoginForm extends StatelessWidget {
  const LoginForm({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    double width = size.width > 600 ? 500 : (size.width - 30);

    var email = TextEditingController();
    var password = TextEditingController();

    showSnackbar(String content) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(content),
      ));
    }

    showSnackbarWithUserData(UserData data) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
            '${data.authWith.name},\nuid: ${data.uid} \nname: ${data.name} \nemail: ${data.email ?? ''}'),
      ));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('FlutterHomura test'),
      ),
      body: Container(
        margin: const EdgeInsets.only(top: 100),
        alignment: Alignment.center,
        child: SizedBox(
          width: width,
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(bottom: 50),
                child: TextFormField(
                  decoration: const InputDecoration(
                    label: Text('Email'),
                  ),
                  controller: email,
                ),
              ),
              Container(
                margin: const EdgeInsets.only(bottom: 50),
                child: TextField(
                  controller: password,
                  obscureText: true,
                  decoration: const InputDecoration(
                    label: Text('Password'),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      try {
                        var result = await Homura.i.signUpWith(
                          AuthWith.password,
                          email: email.text,
                          password: password.text,
                        );
                        Navigator.pop<UserData?>(context, result);
                      } on HomuraError catch (error) {
                        showSnackbar(error.name);
                      }
                    },
                    child: const Text('Try Signup'),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      try {
                        var result = await Homura.i.signInWith(
                          AuthWith.password,
                          email: email.text,
                          password: password.text,
                        );
                        Navigator.pop<UserData?>(context, result);

                        showSnackbarWithUserData(result);
                      } on HomuraError catch (error) {
                        showSnackbar(error.name);
                      }
                    },
                    child: const Text('Try login'),
                  ),
                ],
              ),
              Container(
                margin: const EdgeInsets.only(top: 100),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        try {
                          var result =
                              await Homura.i.signInWith(AuthWith.google);
                          Navigator.pop<UserData?>(context, result);

                          showSnackbarWithUserData(result);
                        } on HomuraError catch (error) {
                          showSnackbar(error.name);
                        }
                      },
                      child: const Text('Google'),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        try {
                          var result =
                              await Homura.i.signInWith(AuthWith.facebook);
                          Navigator.pop<UserData?>(context, result);
                        } on HomuraError catch (error) {
                          showSnackbar(error.name);
                        }
                      },
                      child: const Text('Facebook'),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        try {
                          await Homura.i.signInWith(AuthWith.apple);
                        } on HomuraError catch (error) {
                          showSnackbar(error.name);
                        }
                      },
                      child: const Text('Apple'),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
