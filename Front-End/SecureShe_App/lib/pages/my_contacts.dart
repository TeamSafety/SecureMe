import 'package:flutter/material.dart';
import 'package:my_app/models/AppColors.dart';
import 'package:my_app/models/personal_contact.dart';

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
                personalContactsBuilder(),
                const SizedBox(
                  height: 24,
                ),
                communityContactsBuilder()
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ignore: non_constant_identifier_names
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
        const Column(
          children: [
            Text("No contacts found."),
            Text("Start adding by going to the Community Page."),
          ],
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
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
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
          ],
        ),
      ],
    );
  }
}
