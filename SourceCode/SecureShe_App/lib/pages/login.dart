import 'package:flutter/material.dart';
import 'package:my_app/models/AppVars.dart';
import 'package:my_app/models/background_wave.dart';
import 'package:my_app/models/input_field.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:my_app/pages/main_page.dart';
import 'package:my_app/pages/signup.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

class LoginPage extends StatefulWidget {
  LoginPage({Key? key}) : super(key: key);
  @override
  // ignore: library_private_types_in_public_api
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // text editing controllers
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  String errorMessage = '';
  double errorFontSize = 0;
  bool hidePassword = true;

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
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const MainPage(),
        ),
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = "Couldn't find your SecureMe account";
        errorFontSize = AppVars.smallText;
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
                    color: AppVars.secondary,
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
                  obscureText: hidePassword,
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
                        color: AppVars.accent,
                        fontSize: 12,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 16,
              ),
              //ERROR MESSAGE
              Container(
                alignment: Alignment.centerRight,
                margin: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                height: (errorMessage != '') ? 16 : 0,
                child: (errorMessage == '')
                    ? Row()
                    : Row(
                        children: [
                          Icon(
                            Icons.error,
                            size: 16,
                            color: Colors.red,
                          ),
                          SizedBox(
                            width: 2,
                          ),
                          Text(
                            errorMessage,
                            style: TextStyle(
                                color: Colors.red, fontSize: errorFontSize),
                          ),
                        ],
                      ),
              ),
              Container(
                height: 35,
                alignment: Alignment.center,
                margin: const EdgeInsets.symmetric(
                  horizontal: 20,
                ),
                child: SizedBox.expand(
                  child: ElevatedButton(
                    style: AppVars.primaryButtonStyle,
                    onPressed: signUserIn,
                    child: const Text('Login'),
                  ),
                ),
              ),
              const SizedBox(
                height: 24,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Divider(
                  color: AppVars.secondary.withOpacity(0.6),
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
                    color: AppVars.secondary.withOpacity(0.5),
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
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                SignUpPage(context: context)));
                  },
                  child: Text(
                    "Sign Up",
                    style: TextStyle(
                      fontSize: 16,
                      color: AppVars.accent,
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
