import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/*TODO: add a welcome message to the user with maybe a 
privacy statement about saving data in the firestore DB, 
plus maybe a guide on how to use the app 
and a quick way to access the messages and send them, 
plus maybe an SOS button */
final FirebaseAuth _auth = FirebaseAuth.instance;
final FirebaseFirestore _firestore = FirebaseFirestore.instance; 

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  Future<void> _handleSOSButtonPress(BuildContext context) async {
    bool isConfigured = await _checkSOSConfiguration();

    if (isConfigured) {
      // Proceed with sending the emergency message
      _sendEmergencyMessage();
    } else {
      // Guide the user to the profile page for configuration
      _showConfigurationGuidance(context);
    }
  }

  Future<bool> _checkSOSConfiguration() async {
    User? user = _auth.currentUser;

    if (user != null) {
      try {
        DocumentSnapshot<Map<String, dynamic>> snapshot =
            await FirebaseFirestore.instance.collection('Users').doc(user.uid).get();

        if (snapshot.exists) {
          bool isConfigured = snapshot['SOSConfigured'] ?? false;

          if (isConfigured) {
            List<String> emergencyContacts = List<String>.from(snapshot['emergencyContact'] ?? []);
            String emergencyMessage = snapshot['emergencyMessage'] ?? '';

            // For debugging purposes 
            print('Emergency Contacts: $emergencyContacts');
            print('Emergency Message: $emergencyMessage');
          }
          return isConfigured;
        }
      } catch (e) {
        print('Error checking SOS configuration: $e');
      }
    }
    return false;
  }


  void _sendEmergencyMessage() {
    // Implement logic to send the emergency message
    // This can involve using the user's configured emergency contacts and message
    // Make sure to handle security and privacy considerations
  }

  void _showConfigurationGuidance(BuildContext context) {
    // Display a message guiding the user to the profile page for SOS button setup
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('SOS Button Setup'),
          content: Text('To use the SOS button, please set up your emergency contacts and message in the profile page.'),
          actions: [
            TextButton(
              onPressed: () {
                // Navigate the user to the profile page
                Navigator.pushNamed(context, 'package:my_app/pages/my_profile.dart'); 
              },
              child: Text('Go to Profile'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Welcome to SecureShe',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            // const Text(
            //   'Privacy Statement:\nYour data is securely stored in our database.',
            //   style: TextStyle(fontSize: 16),
            // ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // TODO: Navigate to the SOS page or trigger SOS action
              },
              child: const Text('SOS'),
            ),
            ElevatedButton(
              onPressed: () {
                // TODO: Navigate to the Messages page
              },
              child: const Text('View Messages'),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

