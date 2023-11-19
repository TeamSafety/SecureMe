import 'package:flutter/material.dart';
import 'package:my_app/pages/login.dart';
import 'package:my_app/pages/signup.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(fontFamily: "ArbutusSlab"),
      debugShowCheckedModeBanner: false,
      home: LoginPage(),
    );
  }
}
