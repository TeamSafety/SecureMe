import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_app/models/UserLocation/share_locationButton.dart';
import 'package:my_app/models/community_contact.dart';
import 'package:my_app/models/AppVars.dart';

class ContactPage extends StatefulWidget {
  const ContactPage({super.key});

  @override
  _ContactPageState createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  late List<DocumentSnapshot> contacts = [];
  late List<DocumentSnapshot> originalContacts = [];
  late String _userId = '';
  TextEditingController searchController = TextEditingController();
  @override
  void initState() {
    super.initState();
    getCurrentUserId();
    loadContactData();
  }

  Future<void> getCurrentUserId() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      setState(() {
        _userId = user.uid;
      });
    }
  }

  Future<void> loadContactData() async {
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('localContacts').get();
    setState(() {
      contacts = originalContacts = querySnapshot.docs;
    });
  }

  Widget buildContactList(List<DocumentSnapshot> contacts) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: contacts.map((contact) {
        // Check if latitude and longitude are not null
        double? latitude = (contact['latitude'] as num?)?.toDouble();
        double? longitude = (contact['longitude'] as num?)?.toDouble();

        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: CommunityContact(
            contactName: contact['organization'],
            phoneNumber: '${contact['phone'] ?? 'N/A'}',
            lat: latitude ?? 0.0, // Use 0.0 as a default value
            long: longitude ?? 0.0, // Use 0.0 as a default value
            userId: _userId,
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    // ignore: unnecessary_null_comparison
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
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            children: [
              SizedBox(
                height: AppVars.elementMargin,
              ),
              ShareLocationButton(),
              SizedBox(
                height: AppVars.elementMargin,
              ),
              TextField(
                controller: searchController,
                onChanged: (value) {
                  filterContacts(value);
                },
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppVars.primary,
                  prefixIcon: Icon(Icons.search),
                  iconColor: AppVars.secondary.withOpacity(0.8),
                  labelText: 'Search Community',
                  labelStyle: TextStyle(
                    color: AppVars.secondary.withOpacity(0.8),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppVars.borderRadius),
                    borderSide: BorderSide(
                        width: 0.5, color: AppVars.secondary.withOpacity(0.5)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppVars.borderRadius),
                    borderSide: BorderSide(
                        width: 0.5, color: AppVars.secondary.withOpacity(0.5)),
                  ),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 1, vertical: 0),
                ),
                style: TextStyle(
                  color: AppVars.secondary.withOpacity(0.9),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView(
                  children: [
                    buildCategory(
                        "HelpLines",
                        contacts
                            .where((contact) => contact['type'] == 'helpLines')
                            .toList()),
                    buildCategory(
                        "Shelters",
                        contacts
                            .where((contact) => contact['type'] == 'shelters')
                            .toList()),
                    buildCategory(
                        "Emergency Contacts",
                        contacts
                            .where((contact) =>
                                contact['type'] == 'emergencyContacts')
                            .toList()),
                    buildCategory(
                        "Counselling Services",
                        contacts
                            .where((contact) =>
                                contact['type'] ==
                                'counsellingAndSupportServices')
                            .toList()),
                  ],
                ),
              ),
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
            fontSize: AppVars.textHeader,
            color: AppVars.secondary,
          ),
        ),
        const SizedBox(height: 8),
        if (contacts.isNotEmpty)
          buildContactList(contacts)
        else
          const Text('No contacts available.'),
        const SizedBox(height: 24),
      ],
    );
  }

  void filterContacts(String searchTerm) {
    setState(() {
      contacts = originalContacts
          .where((contact) =>
              contact['organization']
                  .toLowerCase()
                  .contains(searchTerm.toLowerCase()) ||
              contact['type'].toLowerCase().contains(searchTerm.toLowerCase()))
          .toList();
    });
  }
}
