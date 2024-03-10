import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:my_app/models/AppVars.dart';
import 'package:my_app/models/Profile/SOS_configuration.dart';
import 'package:my_app/pages/login.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;
final FirebaseFirestore _firestore = FirebaseFirestore.instance;

class MyProfile extends StatefulWidget {
  const MyProfile({Key? key}) : super(key: key);

  @override
  _MyProfileState createState() => _MyProfileState();
}

class _MyProfileState extends State<MyProfile> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _emergencyContactController = TextEditingController(); 
  final TextEditingController _emergencyMessageController = TextEditingController(); 
  final List<String> contacts = ['KawtharKH']; 
  @override
  void initState() {
    super.initState();
    fetchUserProfile();
  }

  void fetchUserProfile() async {
    User? user = _auth.currentUser;

    if (user != null) {
      DocumentSnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
          .instance
          .collection('Users')
          .doc(user.uid)
          .get();

      if (snapshot.exists) {
        setState(() {
          _usernameController.text = snapshot['username'];
          _emailController.text = snapshot['email'];
        });
      } else {
        //print('Document does not exist.');
      }
    }
  }

  Future<void> updateProfile() async {
    User? user = _auth.currentUser;

    if (user != null) {
      try {
        await FirebaseFirestore.instance
            .collection('Users')
            .doc(user.uid)
            .update({
          'username': _usernameController.text,
          'email': _emailController.text,
        });
      } catch (e) {
        //print('Error updating profile: $e');
        showSnackbar("Error fetching data from the database");
      }
    }
  }

  Future<void> updateEmail() async {
    User? user = _auth.currentUser;

    if (user != null) {
      try {
        await user.updateEmail(_emailController.text);
      } catch (e) {
        //print('Error updating email: $e');
        showSnackbar('Error updating email');
      }
    }
  }

  void showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppVars.primary,
      // body: Container(
      //   padding: EdgeInsets.symmetric(
      //     horizontal: AppVars.pagePadding,
      //     vertical: 0,
      //   ),
      //   width: double.infinity,
      //   child: Column(
      //     children: [
      //       SizedBox(
      //         height: AppVars.sectionPadding,
      //       ),
      //       SizedBox(
      //         // color: Colors.red,
      //         width: double.infinity,
      //         height: 120,
      //         child: Row(
      //           children: [
      //             // PROFILE PIC
      //             AspectRatio(
      //               aspectRatio: 1,
      //               child: Container(
      //                 clipBehavior: Clip.hardEdge,
      //                 height: double.infinity,
      //                 decoration: BoxDecoration(
      //                   borderRadius: const BorderRadius.all(
      //                     Radius.circular(100),
      //                   ),
      //                   color: AppVars.secondary,
      //                   boxShadow: [
      //                     BoxShadow(
      //                       color: AppVars.secondary.withOpacity(0.4),
      //                       blurRadius: 4,
      //                       offset: const Offset(0, 2.0),
      //                     ),
      //                   ],
      //                 ),
      //                 child: const Image(
      //                   fit: BoxFit.scaleDown,
      //                   image: AssetImage("assets/images/profile_charles.png"),
      //                   height: double.infinity,
      //                   width: double.infinity,
      //                   alignment: Alignment.center,
      //                 ),
      //               ),
      //             ),
      //             const SizedBox(
      //               width: 16,
      //             ),
      //             // NAME AND Edit button
      //             Expanded(
      //               child: Column(
      //                 crossAxisAlignment: CrossAxisAlignment.start,
      //                 children: [
      //                   SizedBox(
      //                     height: AppVars.elementMargin,
      //                   ),
      //                   // NAME
      //                   Text(
      //                     "Charles Kenneth Samonte",
      //                     textAlign: TextAlign.start,
      //                     maxLines: 2,
      //                     overflow: TextOverflow.ellipsis,
      //                     style: TextStyle(
      //                       fontSize: 20,
      //                       color: AppVars.secondary,
      //                     ),
      //                   ),
      //                   SizedBox(
      //                     height: AppVars.elementMargin,
      //                   ),
      //                   InkWell(
      //                     onTap: null,
      //                     child: Text(
      //                       "Edit profile",
      //                       style: TextStyle(
      //                           color: AppVars.accent,
      //                           decoration: TextDecoration.underline,
      //                           fontSize: AppVars.textHref),
      //                     ),
      //                   )
      //                 ],
      //               ),
      //             )
      //           ],
      //         ),
      //       ),
      //     ],
      //   ),
      // ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text("Welcome ${_usernameController.text} "),
            const SizedBox(height: 20),
            Text('Username: ${_usernameController.text}'),
            Text('Email: ${_emailController.text}'),

            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditInfoScreen(
                      usernameController: _usernameController,
                      emailController: _emailController,
                      onUpdate: () {
                        fetchUserProfile();
                      },
                    ),
                  ),
                );
              },
              child: const Text('Edit Info'),
            ),
            const SizedBox(
              height: 20,
            ),
            // SOS Button Configuration UI
            TextField(
              controller: _emergencyContactController,
              decoration: const InputDecoration(labelText: 'Emergency Contact'),
            ),
            TextField(
              controller: _emergencyMessageController,
              decoration: const InputDecoration(labelText: 'Emergency Message'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await updateProfile();
                EmergencyConfiguration emergencyClass = EmergencyConfiguration(message: 'Help me', contacts: contacts );
                emergencyClass.emergencySOSUpdate(); 
              },
              child: const Text('Update SOS Emergency info'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await _auth.signOut();
                // ignore: use_build_context_synchronously
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

// ignore: non_constant_identifier_names
class EditInfoScreen extends StatelessWidget {
  final TextEditingController usernameController;
  final TextEditingController emailController;
  final VoidCallback onUpdate;

  const EditInfoScreen({
    super.key,
    required this.usernameController,
    required this.emailController,
    required this.onUpdate,
  });

  void updateProfile() async {
    User? user = _auth.currentUser;

    if (user != null) {
      await FirebaseFirestore.instance
          .collection('Users')
          .doc(user.uid)
          .update({
        'username': usernameController.text,
        'email': emailController.text,
      });
    }
  }

  Future<void> updateEmail() async {
    User? user = _auth.currentUser;
    if (user != null) {
      await user.updateEmail(emailController.text);
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
                //updateEmail();
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
