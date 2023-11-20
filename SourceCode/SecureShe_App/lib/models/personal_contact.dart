import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:my_app/models/AppColors.dart';

class PersonalContact extends StatelessWidget {
  final String initialsTemp;
  final String contactName;
  const PersonalContact({
    super.key,
    required this.contactName,
    required this.initialsTemp,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: AppColors.secondary.withOpacity(0.10),
            blurRadius: 4,
            offset: const Offset(0, 2),
          )
        ],
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 25,
            backgroundColor: Colors.brown.shade800,
            child: Text(initialsTemp),
          ),
          const SizedBox(
            width: 8,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                contactName,
                style: TextStyle(
                  color: AppColors.secondary.withOpacity(0.8),
                  fontSize: 14,
                ),
              ),
              const SizedBox(
                height: 5,
                width: 8,
              ),
              Row(
                children: [
                  contactButton("assets/icons/locate_icon.svg", "Locate"),
                  const SizedBox(width: 8),
                  contactButton("assets/icons/send_icon.svg", "Quick SMS"),
                  const SizedBox(width: 8),
                  contactButton("assets/icons/Phone_light.svg", "Call"),
                  const SizedBox(width: 8),
                ],
              )
            ],
          ),
        ],
      ),
    );
  }

  GestureDetector contactButton(iconPath, caption) {
    return GestureDetector(
      child: Container(
        height: 35,
        width: 35,
        decoration: BoxDecoration(
          color: AppColors.accent.withOpacity(0.09),
          borderRadius: BorderRadius.circular(5),
        ),
        child: Column(
          children: [
            SvgPicture.asset(
              iconPath,
              height: 25,
              width: 25,
            ),
            Text(
              caption,
              style: TextStyle(
                  fontSize: 6, color: AppColors.secondary.withOpacity(0.8)),
            )
          ],
        ),
      ),
    );
  }
}
