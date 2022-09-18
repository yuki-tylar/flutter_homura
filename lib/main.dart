import 'package:flutter/material.dart';
import 'package:homura/demo/login_form.dart';
import 'package:homura/demo/user_page.dart';
import 'package:homura/flutter_homura/homura_app.dart';
import 'package:homura/homura_config.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return HomuraApp(
      config: homuraConfig,
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
