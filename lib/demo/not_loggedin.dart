import 'package:flutter/material.dart';
import 'package:homura/flutter_homura/user_data.dart';

typedef Callback = void Function(UserData? userData);

class NotLoggedInSection extends StatelessWidget {
  final Callback onLoginFormClosed;

  const NotLoggedInSection({
    Key? key,
    required this.onLoginFormClosed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: 30),
          child: Text(
            'You are not signed in.',
            style: Theme.of(context).textTheme.headline5,
          ),
        ),
        ElevatedButton(
          onPressed: () async {
            var result =
                await Navigator.pushNamed(context, '/login') as UserData?;
            onLoginFormClosed(result);
          },
          child: const Text('Sign in'),
        ),
      ],
    );
  }
}
