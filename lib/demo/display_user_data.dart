import 'package:flutter/material.dart';
import 'package:flutter_homura/flutter_homura/user_data.dart';

class DisplayUserData extends StatelessWidget {
  final UserData userData;
  const DisplayUserData({
    Key? key,
    required this.userData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Container(
        margin: const EdgeInsets.only(bottom: 30),
        child: Text(
          'Logged in successfully!',
          style: Theme.of(context).textTheme.headline5,
        ),
      ),
      Container(
        margin: const EdgeInsets.only(bottom: 10),
        child: Text('uid: ${userData.uid}'),
      ),
      Container(
        margin: const EdgeInsets.only(bottom: 10),
        child: Text('loginType: ${userData.authWith.name}'),
      ),
      Container(
        margin: const EdgeInsets.only(bottom: 10),
        child: Text('email: ${userData.email}'),
      ),
      Container(
        margin: const EdgeInsets.only(bottom: 10),
        child: Text('name: ${userData.name ?? 'No data'}'),
      ),
      Container(
        margin: const EdgeInsets.only(bottom: 10),
        child: Text('phone: ${userData.phone ?? 'No data'}'),
      ),
      if (userData.profileImage != null)
        Container(
          margin: const EdgeInsets.only(bottom: 10),
          child: Image.network(
            userData.profileImage!,
            width: 150,
            height: 150,
            fit: BoxFit.cover,
          ),
        ),
    ]);
  }
}
