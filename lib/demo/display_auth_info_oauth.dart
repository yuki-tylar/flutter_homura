import 'package:flutter/material.dart';
import 'package:homura/flutter_homura/enum.dart';
import 'package:homura/flutter_homura/flutter_homura.dart';

class DisplayAuthInfoOAuth extends StatefulWidget {
  final AuthWith authWith;

  const DisplayAuthInfoOAuth({
    Key? key,
    required this.authWith,
  }) : super(key: key);

  @override
  _DisplayAuthInfoOAuthState createState() => _DisplayAuthInfoOAuthState();
}

class _DisplayAuthInfoOAuthState extends State<DisplayAuthInfoOAuth> {
  bool isConnected = false;
  var homura = Homura.instance;

  @override
  void initState() {
    isConnected = Homura.i.isConnectedTo(widget.authWith);
    super.initState();
  }

  showSnackbar(String content) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(content),
    ));
  }

  connect() async {
    try {
      await homura.connectTo(widget.authWith);
      setState(() {
        isConnected = true;
      });
    } on HomuraError catch (error) {
      showSnackbar(error.name);
    }
  }

  disconnect() async {
    try {
      await homura.disconnectFrom(widget.authWith);
      setState(() {
        isConnected = false;
      });
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
                child: Text('signin with ${widget.authWith.name}: Enabled'),
              ),
              ElevatedButton(
                onPressed: disconnect,
                child: Text('Disconnect from ${widget.authWith.name} account'),
              )
            ]
          : [
              Container(
                margin: const EdgeInsets.only(bottom: 15),
                child: Text('signin with ${widget.authWith.name}: Disabled'),
              ),
              ElevatedButton(
                onPressed: connect,
                child: Text('Connect to ${widget.authWith.name} account'),
              )
            ],
    );
  }
}
