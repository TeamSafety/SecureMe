import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:my_app/models/AppVars.dart';
import 'package:my_app/models/PersonalConatcts/personal_contact.dart';
import 'package:my_app/models/preset_message_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_app/models/PersonalConatcts/personalContact.dart';
import 'package:my_app/models/saved_community_contact.dart';

//TODO: Please display the errorMessage to users

class MyContacts extends StatefulWidget {
  const MyContacts({super.key});
  @override
  _MyContactsState createState() => _MyContactsState();
}

class _MyContactsState extends State<MyContacts> {
  final TextEditingController _usernameController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<PersonalContactModel> personalContacts = [];
  String errorMessage = "";
  final TextEditingController _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    getPersonalContacts();
    getExistingMessages();
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
        'contactUid': contactUid,
      });
    }
    getPersonalContacts();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: DefaultTabController(
        length: 2,
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
                  const SizedBox(
                    height: 24,
                  ),
                ],
              ),
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
          style: TextStyle(color: AppVars.secondary, fontSize: 16),
        ),
        const SizedBox(
          height: 16,
        ),
        // Display existing preset messages
        FutureBuilder<List<String>>(
          future: getExistingMessages(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else {
              // Display existing messages
              return Column(
                children: [
                  for (String message in snapshot.data ?? [])
                    PresetMessage(message: message),
                  const SizedBox(height: 8),
                ],
              );
            }
          },
        ),
        // Allow the user to add more messages
        ElevatedButton(
          style: AppVars.primaryButtonStyle,
          onPressed: _showAddMessageDialog,
          child: const Text('Add Message'),
        ),
        const SizedBox(
          height: 8,
        ),
      ],
    );
  }

// Retrieve existing preset messages from the database
  Future<List<String>> getExistingMessages() async {
    User? user = _auth.currentUser;
    List<String> messages = [];

    if (user != null) {
      QuerySnapshot<Map<String, dynamic>> querySnapshot = await _firestore
          .collection('Users')
          .doc(user.uid)
          .collection('messages')
          .get();

      messages = querySnapshot.docs
          .map((doc) => doc.get('message') as String)
          .toList();
    }

    return messages;
  }

// Method to show a dialog for adding a new preset message
  void _showAddMessageDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add Preset Message'),
          content: TextField(
            controller: _messageController,
            decoration: const InputDecoration(labelText: 'Enter message'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                String message = _messageController.text.trim();
                if (message.isNotEmpty) {
                  await addPresetMessage(message);
                  Navigator.pop(context);
                  _messageController.clear();
                  getExistingMessages();
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

// Method to add a new preset message to the database
  Future<void> addPresetMessage(String message) async {
    User? user = _auth.currentUser;
    if (user != null) {
      await _firestore
          .collection('Users')
          .doc(user.uid)
          .collection('messages')
          .add({
        'message': message,
      });
    }
    getExistingMessages();
  }

  Column communityContactsBuilder() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: Text(
            "Saved Community Contacts",
            style: TextStyle(
              color: AppVars.secondary,
              fontSize: AppVars.textHeader,
            ),
          ),
        ),
        const SizedBox(
          height: 16,
        ),
        const SavedCommunityContact(
          contactName: "Test Community Contact",
          phoneNumber: "123",
        ),
        //     ElevatedButton(
        //       onPressed: () => _showAddContactDialog(),
        //       child: Text('Add Contact'),
      ],
    );
  }

  Column personalContactsBuilder() {
    return Column(
      children: [
        SizedBox(
          height: AppVars.sectionPadding,
        ),
        SizedBox(
          width: double.infinity,
          child: Text(
            "Personal contacts",
            style: TextStyle(
              color: AppVars.secondary,
              fontSize: AppVars.textHeader,
            ),
          ),
        ),
        const SizedBox(
          height: 16,
        ),
        const SizedBox(height: 8),
        for (PersonalContactModel contact in personalContacts)
          Column(
            children: [
              PersonalContact(
                contactName: contact.contactName,
                imagePath: contact.imagePath,
                addedContactUid: contact.addedContactUid,
                currentUserId: _auth.currentUser!.uid,
              ),
              const SizedBox(height: 8),
            ],
          ),
        // const PersonalContact(
        //     contactName: ,
        //     imagePath: "assets/images/profile_kawthar.png"),
        const SizedBox(height: 8),
        ElevatedButton(
          style: AppVars.primaryButtonStyle,
          onPressed: () => _showAddContactDialog(),
          child: const Text('Add Contact'),
        )
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
                  if (currentUser != null &&
                      username != currentUser.displayName) {
                    String contactUid = await getUidFromUsername(username);
                    if (contactUid.isNotEmpty) {
                      // Check if the contact is not already in the personal contacts list
                      if (!personalContacts
                          .any((contact) => contactUid == contact.uid)) {
                        addContact(contactUid, username);
                        Navigator.pop(context);
                        _usernameController.clear();
                      } else {
                        // Case where the contact is already in the list
                        errorMessage = "You have already added this contact";
                      }
                    } else {
                      errorMessage = "Cannot find the username";
                    }
                  } else {
                    errorMessage =
                        "You are trying to add yourself as a contact";
                  }
                }
                // print(errorMessage);
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
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await FirebaseFirestore.instance
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
      //print('Error retrieving UID: $e');
      return '';
    }
  }
}
