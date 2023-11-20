import 'package:flutter/material.dart';
import 'package:my_app/models/AppColors.dart';
import 'package:my_app/models/personal_contact.dart';
import 'package:my_app/models/preset_message_widget.dart';

class MyContacts extends StatelessWidget {
  const MyContacts({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                const SizedBox(
                  height: 24,
                ),
                personalContactsBuilder(),
                const SizedBox(
                  height: 24,
                ),
                communityContactsBuilder(),
                const SizedBox(
                  height: 24,
                ),
                presetMessagesBuilder(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Column presetMessagesBuilder() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Preset Messages',
          style: TextStyle(color: AppColors.secondary, fontSize: 16),
        ),
        const SizedBox(
          height: 16,
        ),
        const PresetMessage(
            message:
                "Hey I'm feeling unsafe right now! Please give me a call!"),
        const SizedBox(
          height: 8,
        ),
        const PresetMessage(
            message:
                "I'm lost! I'm sharing my location with you! Please let me know where to go!"),
        const SizedBox(
          height: 8,
        ),
      ],
    );
  }

  Column communityContactsBuilder() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Community Contacts',
          style: TextStyle(color: AppColors.secondary, fontSize: 16),
        ),
        const SizedBox(
          height: 16,
        ),
        Container(
          alignment: Alignment.center,
          child: Text(
            "No contacts found.",
            style: TextStyle(
              color: AppColors.secondary.withOpacity(0.6),
              fontSize: 11,
            ),
          ),
        ),
        Container(
          alignment: Alignment.center,
          child: Text(
            "Start adding by going to the Community Page.",
            style: TextStyle(
              color: AppColors.secondary.withOpacity(0.6),
              fontSize: 11,
            ),
          ),
        ),
      ],
    );
  }

  Column personalContactsBuilder() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Personal Contacts',
          style: TextStyle(color: AppColors.secondary, fontSize: 16),
        ),
        const SizedBox(
          height: 16,
        ),
        const PersonalContact(
          contactName: "Charles Samonte",
          initialsTemp: "CS",
        ),
        const SizedBox(
          height: 16,
        ),
        const PersonalContact(
          contactName: "Kawthar Alkhateeb",
          initialsTemp: "KA",
        ),
        const SizedBox(
          height: 16,
        ),
        const PersonalContact(
          contactName: "Kristina Langgard",
          initialsTemp: "KL",
        ),
        const SizedBox(
          height: 8,
        ),
        Container(
          alignment: Alignment.center,
          child: Container(
            height: 15,
            width: 50,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.secondary.withOpacity(0.08),
            ),
            child: Text(
              "View All",
              style: TextStyle(
                color: AppColors.secondary.withOpacity(0.8),
                fontSize: 7,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
