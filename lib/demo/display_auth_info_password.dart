import 'package:flutter/material.dart';
import 'package:homura/flutter_homura/enum.dart';
import 'package:homura/flutter_homura/flutter_homura.dart';

class DisplayAuthInfoPassword extends StatefulWidget {
  const DisplayAuthInfoPassword({Key? key}) : super(key: key);

  @override
  _DisplayAuthInfoPasswordState createState() =>
      _DisplayAuthInfoPasswordState();
}

class _DisplayAuthInfoPasswordState extends State<DisplayAuthInfoPassword> {
  bool isConnected = false;
  var homura = Homura.instance;

  @override
  void initState() {
    isConnected = Homura.i.isConnectedTo(AuthWith.password);
    super.initState();
  }

  showSnackbar(String content) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(content),
    ));
  }

  connect() async {
    try {
      await homura.resetPassword();
      showSnackbar(
          'Email sent. Please check your inbox and follow the instruction to enable password');
    } on HomuraError catch (error) {
      showSnackbar(error.name);
    }
  }

  disconnect() async {
    try {
      await homura.disconnectFrom(AuthWith.password);
      setState(() {
        isConnected = false;
      });
    } on HomuraError catch (error) {
      showSnackbar(error.name);
    }
  }

  resetPassword() async {
    try {
      await homura.resetPassword();
      showSnackbar('Email sent. Please check your inbox');
    } on HomuraError catch (error) {
      showSnackbar(error.name);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: isConnected
          ? [
              Container(
                margin: const EdgeInsets.only(bottom: 15),
                child: const Text('signin with password: Enabled'),
              ),
              Container(
                margin: const EdgeInsets.only(bottom: 10),
                child: ElevatedButton(
                  onPressed: resetPassword,
                  child: const Text('Reset password'),
                ),
              ),
              ElevatedButton(
                onPressed: disconnect,
                child: const Text('Disable password'),
              ),
            ]
          : [
              Container(
                margin: const EdgeInsets.only(bottom: 15),
                child: const Text('signin with password: Disabled'),
              ),
              ElevatedButton(
                onPressed: connect,
                child: const Text('Enable password'),
              )
            ],
    );
  }
}
