// ignore_for_file: use_super_parameters, library_private_types_in_public_api
import 'package:flutter/material.dart';
import 'package:my_app/models/AppColors.dart';
import 'package:my_app/models/personal_contact.dart';
import 'package:my_app/models/preset_message_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_app/models/personalContact.dart'; 

//TODO: Please display the errorMessage to users

class MyContacts extends StatefulWidget {
  const MyContacts({Key? key}) : super(key: key);
  @override
  _MyContactsState createState() => _MyContactsState();
}

class _MyContactsState extends State<MyContacts> {
  final TextEditingController _usernameController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<PersonalContactModel> personalContacts = [];
  String errorMessage = "";
  @override
  void initState(){
    super.initState();
    getPersonalContacts(); 
  }
  Future<void> getPersonalContacts() async {
    User? user = _auth.currentUser;
    if (user != null) {
      QuerySnapshot<Map<String, dynamic>> querySnapshot = await _firestore
          .collection('Users')
          .doc(user.uid)
          .collection('contacts')
          .get();
      setState(() {
        // Update the personalContacts list with fetched data
        personalContacts = querySnapshot.docs
            .map((doc) => PersonalContactModel.fromMap(doc.data()))
            .toList();
      });
    }
  }

  Future<void> addContact(String contactUid, String contactName) async {
    User? user = _auth.currentUser;
    if (user != null) {
      await _firestore
          .collection('Users')
          .doc(user.uid)
          .collection('contacts')
          .doc(contactUid)
          .set({
        'contactName': contactName,
      });
    }
    getPersonalContacts(); 
  }

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
        for (var contact in personalContacts)
          PersonalContact(
            contactName: contact.contactName,
            initialsTemp: contact.initialsTemp,
          ),
        const SizedBox(
          height: 16,
        ),
        ElevatedButton(
          onPressed: () => _showAddContactDialog(),
          child: Text('Add Contact'),
        ),
      ],
    );
  }

  void _showAddContactDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add Contact'),
          content: TextField(
            controller: _usernameController,
            decoration: const InputDecoration(labelText: 'Enter username'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                String username = _usernameController.text.trim();
                if (username.isNotEmpty) {
                  User? currentUser = _auth.currentUser;
                  if (currentUser != null && username != currentUser.displayName) {
                    String contactUid = await getUidFromUsername(username);
                    if (contactUid.isNotEmpty) {
                      // Check if the contact is not already in the personal contacts list
                      if (!personalContacts.any((contact) => contactUid == contact.uid)) {
                        addContact(contactUid, username);
                        Navigator.pop(context);
                        _usernameController.clear();
                      } else {
                        // Case where the contact is already in the list
                        errorMessage = "You have alread added  this contact"; 
                      }
                    } else {
                      errorMessage = "Cannot find the username"; 
                    }
                  } else {
                    errorMessage = "You are trying to add yourself as a contact"; 
                  }
                }
                print (errorMessage); 
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }
  Future<String> getUidFromUsername(String username) async {
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot = await FirebaseFirestore.instance
          .collection('Users')
          .where('username', isEqualTo: username)
          .get();
      // If there is a user with the given username, return their UID
      if (querySnapshot.docs.isNotEmpty) {
        return querySnapshot.docs.first.id;
      } else {
        return '';
      }
    } catch (e) {
      print('Error retrieving UID: $e');
      return '';
    }
  }
}