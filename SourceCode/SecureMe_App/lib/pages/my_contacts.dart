import 'package:flutter/material.dart';
import 'package:my_app/models/AppVars.dart';
import 'package:my_app/models/Chat/message_chat.dart';
import 'package:my_app/models/Chat/message_service.dart';
import 'package:my_app/models/PersonalContacts/personal_contact.dart';
import 'package:my_app/models/UserLocation/share_locationButton.dart';
import 'package:my_app/models/preset_message_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_app/models/PersonalContacts/personalContact.dart';
import 'package:my_app/models/saved_community_contact.dart';

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
  late String _userId = '';
  final MessageService _messageService = MessageService();

  @override
  void initState() {
    super.initState();
    getPersonalContacts();
    getCurrentUserId();
    getExistingMessages();
  }

  Future<void> getCurrentUserId() async {
    // Retrieve the current user from Firebase Authentication
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // If user is not null, set the userId variable
      setState(() {
        _userId = user.uid;
      });
    }
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

  Future<void> addContact(
      String contactUid, String contactName, String profileImage) async {
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
        'profile_image': profileImage,
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
                  SizedBox(
                    height: AppVars.elementMargin,
                  ),
                  ShareLocationButton(),
                  SizedBox(
                    height: AppVars.sectionPadding,
                  ),
                  personalContactsBuilder(),
                  SizedBox(
                    height: AppVars.sectionPadding,
                  ),
                  communityContactsBuilder(_userId),
                  SizedBox(
                    height: AppVars.sectionPadding,
                  ),
                  presetMessagesBuilder(),
                  SizedBox(
                    height: AppVars.sectionPadding,
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
          style:
              TextStyle(color: AppVars.secondary, fontSize: AppVars.textHeader),
        ),
        const SizedBox(
          height: 16,
        ),
        // Display existing preset messages
        FutureBuilder<List<String>>(
          future: getExistingMessages(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Text(" ");
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else {
              // Display existing messages
              return Column(
                children: [
                  for (String message in snapshot.data ?? [])
                    PresetMessage(
                      message: message,
                      onSendPressed: (message) {
                        _selectContactAndSendMessage(context, message);
                      },
                    ),
                  const SizedBox(height: 8),
                ],
              );
            }
          },
        ),
        // Allow the user to add more messages
        Container(
          alignment: Alignment.center,
          child: ElevatedButton(
            style: AppVars.primaryButtonStyle,
            onPressed: _showAddMessageDialog,
            child: const Text('Add Message'),
          ),
        ),
        const SizedBox(
          height: 8,
        ),
      ],
    );
  }

  Future<void> _selectContactAndSendMessage(
      BuildContext context, String message) async {
    final userContacts = await _getUserContactsFromFirestore();
    final selectedContact = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Select Contact'),
          content: SingleChildScrollView(
            child: ListBody(
              children: userContacts.map((contact) {
                return ListTile(
                  title: Text(contact['contactName']),
                  onTap: () {
                    Navigator.of(context).pop(contact['contactName']);
                  },
                );
              }).toList(),
            ),
          ),
        );
      },
    );

    // If a contact was selected, send the message
    if (selectedContact != null) {
      String contactId = await getUidFromUsername(selectedContact);
      String chatroomId = _messageService.getChatroomId(_userId, contactId);
      MessageChat emergencyMessageObj = MessageChat(
        fromUserId: _userId,
        toUserId: contactId,
        content: message,
        timestamp: DateTime.now(),
      );

      await _messageService.sendMessage(emergencyMessageObj, chatroomId);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Successfully sent message to selected contact!',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: AppVars.accent,
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 3),
        ),
      );

      print('Sending message: $message to $selectedContact');
    }
  }

  Future<List<Map<String, dynamic>>> _getUserContactsFromFirestore() async {
    // Retrieve user's contacts from Firestore subcollection
    final userId = _userId; // Replace with actual user ID
    final querySnapshot = await FirebaseFirestore.instance
        .collection('Users')
        .doc(userId)
        .collection('contacts')
        .get();

    // Convert query snapshot to list of maps
    final contacts = querySnapshot.docs.map((doc) => doc.data()).toList();
    return contacts;
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

  Column communityContactsBuilder(String userId) {
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
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('Users')
              .doc(userId)
              .collection('communityContacts')
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Text("  "); // Placeholder for loading
            }
            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Container(
                margin: EdgeInsets.symmetric(horizontal: 30),
                child: Text(
                  'You have not saved any community contacts.',
                  textAlign: TextAlign.center,
                  maxLines: 2,
                ),
              );
            }
            // If data is available, build the list of community contacts
            return Column(
              children: snapshot.data!.docs.map((doc) {
                var contactData = doc.data() as Map<String, dynamic>;
                return Column(
                  children: [
                    SavedCommunityContact(
                      contactName: contactData['contactName'],
                      phoneNumber: contactData['phoneNumber'],
                      userId: _userId,
                      lat: contactData['lat'],
                      long: contactData['long'],
                    ),
                    SizedBox(
                      height: AppVars.elementMargin,
                    )
                  ],
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }

  Column personalContactsBuilder() {
    return Column(
      children: [
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
                imagePath: contact.profile_image,
                addedContactUid: contact.addedContactUid,
                currentUserId: _auth.currentUser!.uid,
                lat: contact.lat,
                long: contact.long,
              ),
              const SizedBox(height: 8),
            ],
          ),
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
                    String profileImageURL = await getProfileImageURL(username);
                    if (contactUid.isNotEmpty) {
                      // Check if the contact is not already in the personal contacts list
                      if (!personalContacts
                          .any((contact) => contactUid == contact.uid)) {
                        addContact(contactUid, username, profileImageURL);
                        Navigator.pop(context);
                        _usernameController.clear();
                      } else {
                        // Case where the contact is already in the list
                        errorMessage = "You have already added this contact";
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'You have already added this contact',
                              style: TextStyle(color: Colors.white),
                            ),
                            backgroundColor: AppVars.accent,
                            behavior: SnackBarBehavior.floating,
                            duration: Duration(seconds: 3),
                          ),
                        );
                      }
                    } else {
                      errorMessage = "Cannot find the username";
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Cannot find the username',
                            style: TextStyle(color: Colors.white),
                          ),
                          backgroundColor: AppVars.accent,
                          behavior: SnackBarBehavior.floating,
                          duration: Duration(seconds: 3),
                        ),
                      );
                    }
                  } else {
                    errorMessage =
                        "You are trying to add yourself as a contact";
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          "You are trying to add yourself as a contact",
                          style: TextStyle(color: Colors.white),
                        ),
                        backgroundColor: AppVars.accent,
                        behavior: SnackBarBehavior.floating,
                        duration: Duration(seconds: 3),
                      ),
                    );
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

  Future<String> getProfileImageURL(String username) async {
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await FirebaseFirestore.instance
              .collection('Users')
              .where('username', isEqualTo: username)
              .get();
      if (querySnapshot.docs.isNotEmpty) {
        return querySnapshot.docs.first.data()['profile_image'];
      } else {
        return " ";
      }
    } catch (error) {
      print('Error retrieving profile image URL: $error');
      return " ";
    }
  }
}
