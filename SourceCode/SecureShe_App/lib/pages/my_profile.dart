import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

//TODO: please format the page! 

final FirebaseAuth _auth = FirebaseAuth.instance;
final FirebaseFirestore _firestore = FirebaseFirestore.instance;

class MyProfile extends StatefulWidget {
  const MyProfile({super.key});

  @override
  _MyProfileState createState() => _MyProfileState();
}

class _MyProfileState extends State<MyProfile> {
  String userEmail = "";
  String username = "";

  @override
  void initState() {
    super.initState();
    fetchUserProfile();
  }

  void fetchUserProfile() async {
    User? user = _auth.currentUser;

    if (user != null) {
      DocumentSnapshot<Map<String, dynamic>> snapshot =
          await _firestore.collection('Users').doc(user.uid).get();

      if (snapshot.exists) {
        setState(() {
          userEmail = snapshot['email'];
          username = snapshot['username'] ?? ''; // Get username if exists
        });
      } else {
        print('Document does not exist.');
      }
    }
  }

  Future<void> updateUserProfile(String newUsername) async {
    User? user = _auth.currentUser;

    if (user != null) {
      // Update user profile in Firestore
      await _firestore.collection('Users').doc(user.uid).update({
        'username': newUsername,
      });

      // Update local state
      setState(() {
        username = newUsername;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Email: $userEmail',
              style: const TextStyle(fontSize: 18.0),
            ),
            const SizedBox(height: 16.0),
            Text(
              'Username: $username',
              style: const TextStyle(fontSize: 18.0),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                _editUsernameDialog(context);
              },
              child: const Text('Edit Username'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _editUsernameDialog(BuildContext context) async {
    TextEditingController usernameController = TextEditingController();

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Username'),
          content: TextField(
            controller: usernameController,
            decoration: const InputDecoration(hintText: 'Enter new username'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                String newUsername = usernameController.text.trim();
                if (newUsername.isNotEmpty) {
                  updateUserProfile(newUsername);
                }
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
}
