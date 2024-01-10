import 'package:flutter/material.dart';
import 'package:my_app/models/AppColors.dart';
import 'package:my_app/models/background_wave.dart';
import 'package:my_app/models/input_field.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:my_app/pages/home_page.dart';
import 'package:my_app/pages/main_page.dart';
import 'package:my_app/pages/signup.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoginPage extends StatefulWidget {
  LoginPage({Key? key}) : super(key: key);
  @override
  // ignore: library_private_types_in_public_api
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  // text editing controllers
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  String errorMessage = '';
  double errorFontSize = 0;

  void signUserIn() async {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      // Reset error message on successful sign-in
      setState(() {
        errorMessage = '';
        errorFontSize = 0;
      });
         // Navigate to another page (e.g., Home page) on successful sign-in
      // ignore: use_build_context_synchronously
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainPage()), // Replace YourNextPage with the actual page you want to navigate to
      );
    } on FirebaseAuthException catch (e) {
      // Handle errors
      print('Error: $e');
      // Set error message to be displayed
      setState(() {
        errorMessage = e.message ?? 'An error occurred';
        errorFontSize = 12;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const BackgroundWave(height: 250),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  "Sign In",
                  style: TextStyle(
                    color: AppColors.secondary,
                    fontSize: 50,
                  ),
                ),
              ),
              const SizedBox(
                height: 24,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: InputField(
                  controller: emailController,
                  headerText: "Email",
                  hintText: "example@email.com",
                  obscureText: false,
                ),
              ),
              const SizedBox(
                height: 24,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: InputField(
                  controller: passwordController,
                  headerText: "Password",
                  hintText: "*************",
                  obscureText: true,
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      "Forgot Password",
                      style: TextStyle(
                        color: AppColors.accent,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  errorMessage,
                  style: TextStyle(color: Colors.red, fontSize: errorFontSize),
                ),
              ),
              const SizedBox(
                height: 24,
              ),
              Container(
                height: 35,
                alignment: Alignment.center,
                margin: const EdgeInsets.symmetric(
                  horizontal: 20,
                ),
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.secondary.withOpacity(0.25),
                      blurRadius: 4,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: GestureDetector(
                  onTap: signUserIn,
                  child: Text(
                    "Sign In",
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 24,
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 24,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Divider(
                  color: AppColors.secondary.withOpacity(0.6),
                  thickness: 1,
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Container(
                alignment: Alignment.center,
                child: Text(
                  "Don't have an account?",
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.secondary.withOpacity(0.5),
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Container(
                alignment: Alignment.center,
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => SignUpPage(context:context)));
                  },
                  child: Text(
                    "Sign Up",
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.accent,
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
