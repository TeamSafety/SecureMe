import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:my_app/pages/login.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

class MyProfile extends StatefulWidget {
  const MyProfile({Key? key}) : super(key: key);

  @override
  _MyProfileState createState() => _MyProfileState();
}

class _MyProfileState extends State<MyProfile> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchUserProfile();
  }

  void fetchUserProfile() async {
    User? user = _auth.currentUser;

    if (user != null) {
      DocumentSnapshot<Map<String, dynamic>> snapshot =
          await FirebaseFirestore.instance.collection('Users').doc(user.uid).get();

      // Check if the document exists before accessing its fields
      if (snapshot.exists) {
        setState(() {
          _usernameController.text = snapshot['username'];
          _emailController.text = snapshot['email'];
        });
      } else {
        print('Document does not exist.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // Display user information here (username, email, etc.)
            Text('Username: ${_usernameController.text}'),
            Text('Email: ${_emailController.text}'),

            // A button to navigate to the Edit Info screen
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditInfoScreen(
                      usernameController: _usernameController,
                      emailController: _emailController,
                      onUpdate: () {
                        // Update the profile information after editing
                        fetchUserProfile();
                      },
                    ),
                  ),
                );
              },
              child: const Text('Edit Info'),
            ),
            // A Logout button
            ElevatedButton(
              onPressed: () async {
                // Sign out the user
                await _auth.signOut();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LoginPage(), 
                  ),
                );
              },
              child: const Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }
}

class EditInfoScreen extends StatelessWidget {
  final TextEditingController usernameController;
  final TextEditingController emailController;
  final VoidCallback onUpdate;

  const EditInfoScreen({
    Key? key,
    required this.usernameController,
    required this.emailController,
    required this.onUpdate,
  }) : super(key: key);

   void updateProfile() async {
    User? user = _auth.currentUser;

    if (user != null) {
      await FirebaseFirestore.instance.collection('Users').doc(user.uid).update({
        'username': usernameController.text,
        'email': emailController.text,
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Info'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: usernameController,
              decoration: const InputDecoration(labelText: 'Username'),
            ),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            ElevatedButton(
              onPressed: () async {
                // Update the profile information
                onUpdate();
                updateProfile();
                // Navigate back to the MyProfile screen
                Navigator.pop(context);
              },
              child: const Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }
}
