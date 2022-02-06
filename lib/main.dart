import 'package:flutter/material.dart';
import 'package:flutter_homura/demo/login_form.dart';
import 'package:flutter_homura/demo/user_page.dart';
import 'package:flutter_homura/flutter_homura/homura_app.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return HomuraApp(
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        initialRoute: '/',
        routes: {
          '/login': (BuildContext context) => const LoginForm(),
          '/': (BuildContext context) => const UserPage(),
        },
      ),
    );
  }
}
