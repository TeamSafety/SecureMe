import 'dart:io';
import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_app/models/AppVars.dart';
import 'package:my_app/models/Profile/SOS_configuration.dart';
import 'package:my_app/models/UserLocation/share_locationButton.dart';
import 'package:my_app/models/custom_dropdown.dart';
import 'package:my_app/pages/login.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

class MyProfile extends StatefulWidget {
  const MyProfile({super.key});

  @override
  _MyProfileState createState() => _MyProfileState();
}

class _MyProfileState extends State<MyProfile> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  List<String> userContacts = [""];
  List<String> userMessages = [""];
  String? selectedEmergencyContact;
  String? selectedEmergencyMessage;

  late Future<void> userProfileFuture;
  Uint8List? _image;
  String profileImageURL = " ";

  String username = 'default';

  @override
  void initState() {
    super.initState();
    userProfileFuture = fetchUserProfile();
    updateUsername();
    getProfileImageURL(username);
  }

  void selectImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final File file = File(image.path);
      setState(() {
        _image = file.readAsBytesSync();
        // updateUsername();
        uploadImageToFirebaseStorage(file);
        // getProfileImageURL(username) ;
      });
      // uploadImageToFirebaseStorage(file);
    }
  }

  Future<dynamic> updateUsername() async {
    User? user = _auth.currentUser;
    if (user != null) {
      try {
        DocumentSnapshot<Map<String, dynamic>> userSnapshot =
            await FirebaseFirestore.instance
                .collection('Users')
                .doc(user.uid)
                .get();

        if (userSnapshot.exists) {
          String username1 = userSnapshot.get('username');
          if (username1 != '') {
            username = username1;
            print(username);
          } else {
            username = "default";
            print(username);
          }
        } else {
          print('User document does not exist');
        }
      } catch (e) {
        print('Error retrieving username: $e');
      }
    }
  }

  Future<void> uploadImageToFirebaseStorage(File file) async {
    User? user = _auth.currentUser;

    if (user != null) {
      try {
        final Reference storageReference = FirebaseStorage.instance
            .ref()
            .child('profile_images')
            .child(user.uid + '_profile.jpg');
        await storageReference.putFile(file);

        final String downloadURL = await storageReference.getDownloadURL();

        await FirebaseFirestore.instance
            .collection('Users')
            .doc(user.uid)
            .update({
          'profile_image': downloadURL,
        });
        showSnackbar('Profile picture updated successfully');
      } catch (e) {
        print('Error uploading image to Firebase Storage: $e');
        showSnackbar('Error updating profile picture');
      }
    }
  }

  Future<void> getProfileImageURL(String username) async {
    try {
      if (username == "default") {
        profileImageURL =
            "https://firebasestorage.googleapis.com/v0/b/she-1acd0.appspot.com/o/avatar_default.jpg?alt=media&token=395337cf-96ee-49a8-84cb-e8e40537cde8";
      }
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await FirebaseFirestore.instance
              .collection('Users')
              .where('username', isEqualTo: username)
              .get();
      if (querySnapshot.docs.isNotEmpty) {
        String fetchedProfileImageUrl =
            querySnapshot.docs.first.data()['profile_image'];
        setState(() {
          profileImageURL = fetchedProfileImageUrl;
        });
        if (profileImageURL == '') {
          profileImageURL =
              "https://firebasestorage.googleapis.com/v0/b/she-1acd0.appspot.com/o/avatar_default.jpg?alt=media&token=395337cf-96ee-49a8-84cb-e8e40537cde8";
        }
        print(profileImageURL);
      } else {
        profileImageURL =
            'https://firebasestorage.googleapis.com/v0/b/she-1acd0.appspot.com/o/profile_images%2Fc5tJaFhUeBQV84slbA5oUD0b5tA3_profile.jpg?alt=media&token=2602e9fb-813e-4cb0-9b44-de9a6cc511cc';
      }
    } catch (error) {
      print('Error retrieving profile image URL: $error');
      profileImageURL =
          'https://firebasestorage.googleapis.com/v0/b/she-1acd0.appspot.com/o/profile_images%2Fc5tJaFhUeBQV84slbA5oUD0b5tA3_profile.jpg?alt=media&token=2602e9fb-813e-4cb0-9b44-de9a6cc511cc';
    }
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
        print("can't find doc");
      }

      QuerySnapshot<Map<String, dynamic>> contactsSnapshot =
          await FirebaseFirestore.instance
              .collection('Users')
              .doc(user.uid)
              .collection('contacts')
              .get();

      userContacts = contactsSnapshot.docs
          .map((doc) => doc['contactName'] as String)
          .toList();

      // Fetch user messages
      QuerySnapshot<Map<String, dynamic>> messagesSnapshot =
          await FirebaseFirestore.instance
              .collection('Users')
              .doc(user.uid)
              .collection('messages')
              .get();

      userMessages =
          messagesSnapshot.docs.map((doc) => doc['message'] as String).toList();
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
                  height: AppVars.elementMargin,
                ),
                ShareLocationButton(),
                SizedBox(
                  height: AppVars.sectionPadding,
                ),
                SizedBox(
                  width: double.infinity,
                  height: 120,
                  child: Row(
                    children: [
                      // PROFILE PIC
                      Stack(
                        children: [
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
                              child: Image.network(
                                profileImageURL,
                                fit: BoxFit.scaleDown,
                                height: double.infinity,
                                width: double.infinity,
                                alignment: Alignment.center,
                              ),
                            ),
                          ),
                          Positioned(
                            top: 0,
                            left: 85,
                            bottom: -100,
                            child: IconButton(
                              icon: Icon(
                                Icons.add_a_photo,
                                size: 20,
                                color: AppVars.accent,
                              ),
                              onPressed: selectImage,
                            ),
                          ),
                        ],
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
                              onTap: () {
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
                        FutureBuilder(
                          future: userProfileFuture,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Text(" ");
                            } else if (snapshot.hasError) {
                              return Text('Error: ${snapshot.error}');
                            } else {
                              return CustomDropdown(
                                title: "Select from contacts",
                                listItems: userContacts,
                                dropdownValue: (String? value) {
                                  setState(() {
                                    selectedEmergencyContact = value;
                                    print(selectedEmergencyContact); 
                                  });
                                },
                              );
                            }
                          },
                        )
                      ]),
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
                        FutureBuilder(
                          future: userProfileFuture,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Text(" ");
                            } else if (snapshot.hasError) {
                              return Text('Error: ${snapshot.error}');
                            } else {
                              return CustomDropdown(
                                title: "Select from preset messages",
                                listItems: userMessages,
                                dropdownValue: (String? value) {
                                  setState(() {
                                    selectedEmergencyMessage = value;
                                    print(selectedEmergencyMessage); 
                                  });
                                },
                              );
                            }
                          },
                        )
                      ]),
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
                      message: selectedEmergencyMessage ?? 'Help ME!!',
                      contacts: [selectedEmergencyContact ?? ''],
                      context: context,
                    );
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
        backgroundColor: AppVars.accent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
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
