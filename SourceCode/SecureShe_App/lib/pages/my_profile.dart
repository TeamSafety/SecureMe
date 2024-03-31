import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:my_app/models/AppVars.dart';
import 'package:my_app/models/Profile/SOS_configuration.dart';
import 'package:my_app/models/drop_downList.dart';
import 'package:my_app/pages/login.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;
//final FirebaseFirestore _firestore = FirebaseFirestore.instance;

class MyProfile extends StatefulWidget {
  const MyProfile({super.key});

  @override
  _MyProfileState createState() => _MyProfileState();
}

class _MyProfileState extends State<MyProfile> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  List<String> userContacts = ["KawtharKH"]; 
  List<String> userMessages = ["Help please"]; 
  String? selectedEmergencyContact;
  String? selectedEmergencyMessage;

  late Future<void> userProfileFuture;

  @override
  void initState() {
    super.initState();
    userProfileFuture = fetchUserProfile();  
  }

  Future<void> fetchUserProfile() async {
    User? user = _auth.currentUser;

    if (user != null) {
      // Fetch user profile data
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
        // Handle the case where the document does not exist.
      }

      // Fetch user contacts
      QuerySnapshot<Map<String, dynamic>> contactsSnapshot = await FirebaseFirestore
          .instance
          .collection('Users')
          .doc(user.uid)
          .collection('contacts')
          .get();

      userContacts = contactsSnapshot.docs.map((doc) => doc['contactName'] as String).toList();

      // Fetch user messages
      QuerySnapshot<Map<String, dynamic>> messagesSnapshot = await FirebaseFirestore
          .instance
          .collection('Users')
          .doc(user.uid)
          .collection('messages')
          .get();

      userMessages = messagesSnapshot.docs.map((doc) => doc['message'] as String).toList();
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
    return SafeArea(
      child: Scaffold(
        backgroundColor: AppVars.primary,
        body: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: AppVars.pagePadding,
              vertical: 0,
            ),
            width: double.infinity,
            child: Column(
              children: [
                SizedBox(
                  height: AppVars.sectionPadding,
                ),
                SizedBox(
                  // color: Colors.red,
                  width: double.infinity,
                  height: 120,
                  child: Row(
                    children: [
                      // PROFILE PIC
                      AspectRatio(
                        aspectRatio: 1,
                        child: Container(
                          clipBehavior: Clip.hardEdge,
                          height: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.all(
                              Radius.circular(100),
                            ),
                            color: AppVars.secondary,
                            boxShadow: [
                              BoxShadow(
                                color: AppVars.secondary.withOpacity(0.4),
                                blurRadius: 4,
                                offset: const Offset(0, 2.0),
                              ),
                            ],
                          ),
                          child: const Image(
                            fit: BoxFit.scaleDown,
                            image:
                                AssetImage("assets/images/profile_charles.png"),
                            height: double.infinity,
                            width: double.infinity,
                            alignment: Alignment.center,
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 16,
                      ),
                      // NAME AND Edit button
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              height: AppVars.elementMargin,
                            ),
                            // NAME
                            Text(
                              _usernameController.text,
                              textAlign: TextAlign.start,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 20,
                                color: AppVars.secondary,
                              ),
                            ),
                            Text(
                              _emailController.text,
                              textAlign: TextAlign.start,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: AppVars.textHref,
                                color: AppVars.secondary.withOpacity(0.8),
                              ),
                            ),
                            SizedBox(
                              height: AppVars.elementMargin,
                            ),
                            InkWell(
                              onTap:(){
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
                              child: Text(
                                "Edit profile",
                                style: TextStyle(
                                    color: AppVars.accent,
                                    decoration: TextDecoration.underline,
                                    fontSize: AppVars.textHref),
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: AppVars.sectionPadding,
                ),
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                  decoration: BoxDecoration(
                    color: AppVars.primary,
                    border: Border.all(
                      color: AppVars.secondary.withOpacity(0.1),
                    ),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: AppVars.secondary.withOpacity(0.3),
                        blurRadius: 4,
                        offset: const Offset(0, 2.0),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Emergency Contact",
                        style: TextStyle(
                          fontSize: AppVars.textTitle,
                          color: AppVars.secondary.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: AppVars.elementMargin,
                ),
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                  decoration: BoxDecoration(
                    color: AppVars.primary,
                    border: Border.all(
                      color: AppVars.secondary.withOpacity(0.1),
                    ),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: AppVars.secondary.withOpacity(0.3),
                        blurRadius: 4,
                        offset: const Offset(0, 2.0),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Emergency Message",
                        style: TextStyle(
                          fontSize: AppVars.textTitle,
                          color: AppVars.secondary.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: AppVars.elementMargin,
                ),
                ElevatedButton(
                  style: AppVars.primaryButtonStyle,
                  onPressed: () async {
                    await updateProfile();
                    EmergencyConfiguration emergencyClass =
                        EmergencyConfiguration(
                            message: 'Help me', contacts: userContacts);
                    emergencyClass.emergencySOSUpdate();
                  },
                  child: const Text('Update SOS Emergency info'),
                ),
                SizedBox(
                  height: AppVars.sectionPadding,
                ),
                ElevatedButton(
                  style: AppVars.primaryButtonStyle,
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
