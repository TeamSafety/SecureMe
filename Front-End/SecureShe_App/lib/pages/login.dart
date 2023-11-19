import 'package:flutter/material.dart';
import 'package:my_app/models/AppColors.dart';
import 'package:my_app/models/background_wave.dart';
import 'package:my_app/models/input_field.dart';

class LoginPage extends StatelessWidget {
  LoginPage({super.key});

  // text editing controllers
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  void signUserIn() {}

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
                child: Text(
                  "Sign Up",
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.accent,
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
