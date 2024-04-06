import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:my_app/models/AppVars.dart';
import 'package:my_app/models/Chat/message_chat.dart';
import 'package:my_app/models/Chat/message_service.dart';
import 'package:my_app/models/UserLocation/share_locationButton.dart';
import 'package:my_app/pages/my_profile.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;
final FirebaseFirestore _firestore = FirebaseFirestore.instance;
final MessageService _messageService = MessageService();

class SOSButton extends StatefulWidget {
  const SOSButton({super.key});

  @override
  State<SOSButton> createState() => _SOSButtonState();
}

class _SOSButtonState extends State<SOSButton> {
  double _sizeTmp = 115;

  final ShareLocationButton loc = new ShareLocationButton();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _handleSOSButtonPress(context);
      },
      child: Container(
        alignment: Alignment.center,
        width: _sizeTmp,
        height: _sizeTmp,
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
          style: TextStyle(color: AppVars.primary, fontSize: AppVars.bigHeader),
        ),
      ),
    );
  }

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
        // Check if the EmergencyInfo collection has any documents for the user
        QuerySnapshot<Map<String, dynamic>> emergencyInfoSnapshot =
            await FirebaseFirestore.instance
                .collection('Users')
                .doc(user.uid)
                .collection('EmergencyInfo')
                .get();
        bool isConfigured = emergencyInfoSnapshot.docs.isNotEmpty;
        return isConfigured;
      } catch (e) {
        print('Error checking SOS configuration: $e');
      }
    }
    return false;
  }

  void _showConfigurationGuidance(BuildContext context) {
    // Display a message guiding the user to the profile page for SOS button setup
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('SOS Button Setup'),
          content: const Text(
              'To use the SOS button, please set up your emergency contacts and message in the profile page.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const MyProfile()),
                );
              },
              child: const Text('Go to Profile'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _sendEmergencyMessage() async {
    User? user = _auth.currentUser;
    if (user != null) {
      try {
        // Retrieve the emergency contact information from the EmergencyInfo collection
        QuerySnapshot<Map<String, dynamic>> emergencyInfoSnapshot =
            await FirebaseFirestore.instance
                .collection('Users')
                .doc(user.uid)
                .collection('EmergencyInfo')
                .get();

        if (emergencyInfoSnapshot.docs.isNotEmpty) {
          // Extract emergency contact IDs, names, and messages from the snapshot
          List<String> emergencyContactIds = [];
          List<String> emergencyContactNames = [];
          List<String> emergencyMessages = [];

          emergencyInfoSnapshot.docs.forEach((emergencyDoc) {
            emergencyContactIds.add(emergencyDoc.id);
            emergencyContactNames.add(emergencyDoc['emergencyContact']);
            emergencyMessages.add(emergencyDoc['emergencyMessage']);
          });

          for (int i = 0; i < emergencyContactIds.length; i++) {
            String contactId = emergencyContactIds[i];
            String chatroomId =
                _messageService.getChatroomId(user.uid, contactId);
            print(user.uid);

            String formattedMessage =
                'EMERGENCY Message: ${emergencyMessages[i]}';

            MessageChat emergencyMessageObj = MessageChat(
              fromUserId: user.uid,
              toUserId: contactId,
              content: formattedMessage,
              timestamp: DateTime.now(),
            );

            await _messageService.sendMessage(emergencyMessageObj, chatroomId);
          }
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Your EMERGENCY message was sent',
                style: TextStyle(color: Colors.white),
              ),
              backgroundColor: AppVars.accent,
              behavior: SnackBarBehavior.floating,
              duration: Duration(seconds: 3),
            ),
          );
          // Navigate to a page where the user can send an "I'm safe" message or a timer
        }
      } catch (e) {
        print('Error sending emergency message: $e');
      }
    }
  }
}
