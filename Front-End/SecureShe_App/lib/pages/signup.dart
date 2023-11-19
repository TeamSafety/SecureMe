import 'package:flutter/material.dart';
import 'package:my_app/models/AppColors.dart';
import 'package:my_app/models/background_wave.dart';
import 'package:my_app/models/input_field.dart';

class SignUpPage extends StatelessWidget {
  SignUpPage({super.key});

  // text editing controllers
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final rptPasswordController = TextEditingController();

  void signUpUser() {}

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const BackgroundWave(height: 200),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  "Sign Up",
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
                height: 24,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: InputField(
                  controller: rptPasswordController,
                  headerText: "Repeat Password",
                  hintText: "*************",
                  obscureText: true,
                ),
              ),
              const SizedBox(
                height: 48,
              ),
              Container(
                height: 40,
                alignment: Alignment.center,
                margin: const EdgeInsets.symmetric(
                  horizontal: 20,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.accent),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.secondary.withOpacity(0.25),
                      blurRadius: 4,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: GestureDetector(
                  onTap: signUpUser,
                  child: Text(
                    "Sign Up",
                    style: TextStyle(
                      color: AppColors.accent,
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
                  "Already have an account?",
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
                  "Sign In",
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
