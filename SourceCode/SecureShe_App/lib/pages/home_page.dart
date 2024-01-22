import 'package:flutter/material.dart';
// TODO: add a welcome message to the user with maybe a privacy statement about saving data in the firestore DB, plus maybe a guide on how to use the page 
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Text(
      "My Home Page",
      textAlign: TextAlign.center,
    );
  }
}
