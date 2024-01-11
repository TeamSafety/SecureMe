import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
final FirebaseAuth _auth = FirebaseAuth.instance;
// fetching the user's data to display in the profile page. 
void fetchUserProfile() async {
  User? user = _auth.currentUser;

  if (user != null) {
    DocumentSnapshot<Map<String, dynamic>> snapshot =
        await FirebaseFirestore.instance.collection('Users').doc(user.uid).get();

    // Check if the document exists before accessing its fields
    if (snapshot.exists) {
      // Access user profile data
      String userEmail = snapshot['email'];
      print(userEmail); 
      // Access more fields as needed
      // You can now use userEmail and other fields as needed
    } else {
      print('Document does not exist.');
    }
  }
}


class MyProfile extends StatelessWidget {
  const MyProfile({super.key});

  @override
  Widget build(BuildContext context) {
    fetchUserProfile(); 
    return const Text(
      "My Profile",
      textAlign: TextAlign.center,
    );
    
  }
}

