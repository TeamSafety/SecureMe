import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:my_app/models/AppVars.dart';

class EmergencyConfiguration{
  final String message;
  final List<String> contacts;
  BuildContext context; 

  EmergencyConfiguration({
    required this.message,
    required this.contacts,
    required this.context, 
  });
  final FirebaseAuth _auth = FirebaseAuth.instance;  

  Future<void> emergencySOSUpdate() async {
    User? user = _auth.currentUser;
    if (user != null) {
      for (String contact in contacts){
        String emergencyContactName = contact;
        bool isContactInList = await isEmergencyContactInList(user.uid, emergencyContactName);

        if (isContactInList) {
          try {
            // Fetch the user ID of the emergency contact using their name
            String emergencyContactId = await getEmergencyContactUserId(emergencyContactName);

            await FirebaseFirestore.instance
              .collection('Users')
              .doc(user.uid)
              .collection('EmergencyInfo')
              .doc(emergencyContactId)
              .set({
                'emergencyContact': emergencyContactName,
                'emergencyContactId': emergencyContactId, // Save the contact's user ID
                'emergencyMessage': message,
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    "SOS emergency info updated successfully",
                    style: TextStyle(color: Colors.white), 
                  ),
                  backgroundColor: AppVars.accent, 
                  behavior: SnackBarBehavior.floating, 
                  duration: Duration(seconds: 3), 
                ),
              );
            print("SOS emergency info updated successfully"); 
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    "Error updating SOS button info",
                    style: TextStyle(color: Colors.white), 
                  ),
                  backgroundColor: AppVars.accent, 
                  behavior: SnackBarBehavior.floating, 
                  duration: Duration(seconds: 3), 
                ),
            );

          }
        } else {
          print('Error: Emergency contact is not in your contact list');
        }
        }
    }
  }

  Future<String> getEmergencyContactUserId(String emergencyContactName) async {
    try {
      QuerySnapshot<Map<String, dynamic>> contactSnapshot =
          await FirebaseFirestore.instance
              .collection('Users')
              .where('username', isEqualTo: emergencyContactName)
              .get();

      if (contactSnapshot.docs.isNotEmpty) {
        return contactSnapshot.docs[0].id; // Return the user ID of the emergency contact
      } else {
        // Handle the case where the emergency contact is not found
        return '';
      }
    } catch (e) {
      // Handle the error appropriately, e.g., log it and return an empty string
      print('Error getting emergency contact user ID: $e');
      return '';
    }
}


  Future<bool> isEmergencyContactInList(
      String userId, String emergencyContact) async {
    try {
      QuerySnapshot<Map<String, dynamic>> contactsSnapshot =
          await FirebaseFirestore.instance
              .collection('Users')
              .doc(userId)
              .collection('contacts')
              .get();

      if (contactsSnapshot.docs.isNotEmpty) {
        // Check if the emergency contact is in the user's contacts subcollection
        return contactsSnapshot.docs
            .any((contact) => contact['contactName'] == emergencyContact);
      } else {
        //print('User contacts subcollection is empty.');
        return false;
      }
    } catch (e) {
      //print('Error checking emergency contact: $e');
      return false;
    }
  }
}


