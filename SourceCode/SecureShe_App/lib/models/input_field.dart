import 'package:flutter/material.dart';
import 'package:my_app/models/AppColors.dart';

class InputField extends StatelessWidget {
  final controller;
  final String hintText;
  final String headerText;
  final bool obscureText;

  const InputField({
    super.key,
    required this.controller,
    required this.headerText,
    required this.hintText,
    required this.obscureText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          headerText,
          style: TextStyle(
            color: AppColors.secondary.withOpacity(0.6),
            fontSize: 24,
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        Container(
          height: 30,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: AppColors.primary,
            boxShadow: [
              BoxShadow(
                  color: AppColors.accent.withOpacity(0.8),
                  blurRadius: 2,
                  offset: const Offset(0, 4))
            ],
          ),
          child: TextField(
            controller: controller,
            obscureText: obscureText,
            style: const TextStyle(
              color: Color.fromARGB(255, 47, 44, 35),
              fontSize: 12,
            ),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: const TextStyle(
                color: Color.fromARGB(127, 47, 44, 35),
              ),
              contentPadding: const EdgeInsets.symmetric(
                vertical: 8,
                horizontal: 15,
              ),
              border: const OutlineInputBorder(
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
