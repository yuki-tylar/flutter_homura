import 'package:flutter/material.dart';
import 'package:flutter_homura/flutter_homura/enum.dart';
import 'package:flutter_homura/flutter_homura/flutter_homura.dart';

class DisplayAuthInfoVerification extends StatefulWidget {
  const DisplayAuthInfoVerification({Key? key}) : super(key: key);

  @override
  _DisplayAuthInfoVerificationState createState() =>
      _DisplayAuthInfoVerificationState();
}

class _DisplayAuthInfoVerificationState
    extends State<DisplayAuthInfoVerification> {
  var homura = Homura.instance;
  bool isVerified = false;

  @override
  void initState() {
    isVerified = homura.isUserVerified;
    super.initState();
  }

  showSnackbar(String content) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(content),
    ));
  }

  sendVerification() async {
    try {
      await homura.sendVerification();
      showSnackbar(
          'Evmail sent. Please check your inbox and verify your email');
    } on HomuraError catch (error) {
      showSnackbar(error.name);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: homura.isUserVerified
          ? [
              Container(
                margin: const EdgeInsets.only(bottom: 15),
                child: Text(
                  'Your account has been verified.',
                  style: Theme.of(context).textTheme.headline6,
                ),
              ),
            ]
          : [
              Container(
                margin: const EdgeInsets.only(bottom: 15),
                child: Text(
                  'Your account is not verified yet.',
                  style: Theme.of(context).textTheme.headline6,
                ),
              ),
              Container(
                margin: const EdgeInsets.only(bottom: 10),
                child: ElevatedButton(
                  onPressed: sendVerification,
                  child: const Text('Send verification email'),
                ),
              ),
            ],
    );
  }
}
