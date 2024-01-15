import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:my_app/models/AppColors.dart';

class ContactPage extends StatefulWidget {
  @override
  _ContactPageState createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  late List<DocumentSnapshot> contacts = [];

  @override
  void initState() {
    super.initState();
    loadContactData();
  }

  Future<void> loadContactData() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('localResources').get();
    setState(() {
      contacts = querySnapshot.docs;
    });
  }

  Widget buildContactList(List<DocumentSnapshot> contacts) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: contacts
          .map((contact) => Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      contact['organization'],
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.secondary, 
                      ),
                    ),
                    const SizedBox(height: 4),
                    GestureDetector(
                      onTap: () {
                        _makePhoneCall(contact['phone']);
                      },
                      child: Text(
                        'Phone: ${contact['phone'] ?? 'N/A'}',
                        // style: const TextStyle(
                        //   // color: Colors.blue,
                        //   decoration: TextDecoration.underline,
                        // ),
                      ),
                    ),
                  ],
                ),
              ))
          .toList(),
    );
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    await launchUrl(launchUri);
  }

  @override
  Widget build(BuildContext context) {
    if (contacts == null) {
      // Data is still loading, show a loading message or placeholder
      return const Center(
        child: Text(
          'Loading contacts...',
          style: TextStyle(fontSize: 18),
        ),
      );
    } else {
      // Data has been loaded, you can use it in your UI
      return Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            children: [
              buildCategory("Emergency Contacts", contacts
                  .where((contact) => contact['type'] == 'emergencyContacts')
                  .toList()),
              buildCategory("Shelters", contacts
                  .where((contact) => contact['type'] == 'shelters')
                  .toList()),
            ],
          ),
        ),
      );
    }
  }

  Widget buildCategory(String title, List<DocumentSnapshot> contacts) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 26,
            color: AppColors.accent, 
          ),
        ),
        const SizedBox(height: 8),
        if (contacts.isNotEmpty)
          buildContactList(contacts)
        else
          const Text('No contacts available.'),
      ],
    );
  }
}
