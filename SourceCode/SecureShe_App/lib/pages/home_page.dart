import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:my_app/models/AppVars.dart';
import 'package:my_app/pages/my_profile.dart';

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
            await FirebaseFirestore.instance
                .collection('Users')
                .doc(user.uid)
                .get();

        if (snapshot.exists) {
          bool isConfigured = snapshot['SOSConfigured'] ?? false;
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
    // we need to navigate to a page where it allows the user to send an I'm safe message when they are save
  }

  void _showConfigurationGuidance(BuildContext context) {
    // Display a message guiding the user to the profile page for SOS button setup
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('SOS Button Setup'),
          content: Text(
              'To use the SOS button, please set up your emergency contacts and message in the profile page.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const MyProfile()),
                );
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
      body: SizedBox(
        width: double.infinity,
        child: Column(
          children: [
            Text(
              'Welcome to SecureMe',
              style: TextStyle(
                  fontSize: AppVars.bigHeader,
                  fontWeight: FontWeight.bold,
                  color: AppVars.accent),
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    child: Container(
                      alignment: Alignment.center,
                      width: 114,
                      height: 114,
                      decoration: BoxDecoration(
                        color: AppVars.accent,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppVars.secondary.withOpacity(0.25),
                            blurRadius: 4,
                            offset: const Offset(4.0, 4.0),
                          ),
                          BoxShadow(
                            color: AppVars.primary,
                            blurRadius: 4,
                            spreadRadius: 1,
                            offset: const Offset(-4.0, -4.0),
                          ),
                        ],
                        gradient: LinearGradient(
                          begin: Alignment.bottomRight,
                          end: Alignment.topLeft,
                          colors: [
                            AppVars.accent,
                            AppVars.accent,
                            AppVars.accent,
                            AppVars.accent,
                            AppVars.accent.withOpacity(0.9),
                            AppVars.accent.withOpacity(0.8),
                          ],
                        ),
                      ),
                      child: Text(
                        "SOS",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: AppVars.primary,
                            fontSize: AppVars.bigHeader),
                      ),
                    ),
                  )
                ],
              ),
            ),
            // const Text(
            //   'Privacy Statement:\nYour data is securely stored in our database.',
            //   style: TextStyle(fontSize: 16),
            // ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                _handleSOSButtonPress(context); 
              },
              child: const Text('SOS'),
            ),
          ],
        ),
      ),
    );
  }
}
