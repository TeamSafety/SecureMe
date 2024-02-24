import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_app/models/community_contact.dart';
//import 'package:url_launcher/url_launcher.dart';
import 'package:my_app/models/AppVars.dart';

/*
TODO: 
1. format the page correctly (ALMOST DONE)
2. add more cotacts (DONE)
3. search method to search the local resources in different ways like 
according to the type of the contact, the urgency of your matter, type 
of help you are looking for (DONE)
4. add the ability to add the contacts to your own list of contacts (Next up)
5. admin and user roles (Next up)
*/
class ContactPage extends StatefulWidget {
  @override
  _ContactPageState createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  late List<DocumentSnapshot> contacts = [];
  late List<DocumentSnapshot> originalContacts = [];
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadContactData();
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
      children: contacts
          .map((contact) => Padding(
                padding: const EdgeInsets.all(8.0),
                child: CommunityContact(
                    contactName: contact['organization'],
                    phoneNumber: '${contact['phone'] ?? 'N/A'}'),
              ))
          .toList(),
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
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                controller: searchController,
                onChanged: (value) {
                  filterContacts(value);
                },
                decoration: const InputDecoration(
                  labelText: 'Search contacts',
                  prefixIcon: Icon(Icons.search),
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
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: AppVars.accent,
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
