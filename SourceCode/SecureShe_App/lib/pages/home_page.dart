import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:my_app/models/AppVars.dart';
import 'package:my_app/models/UserLocation/share_locationButton.dart';
import 'package:my_app/models/sos_button.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;
final FirebaseFirestore _firestore = FirebaseFirestore.instance;

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        width: double.infinity,
        child: Column(
          children: [
            SizedBox(
              height: AppVars.elementMargin,
            ),
            Text(
              'SecureMe',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: AppVars.bigHeader,
                  fontWeight: FontWeight.bold,
                  color: AppVars.accent),
            ),
            SizedBox(
              height: AppVars.elementMargin,
            ),
            ShareLocationButton(),
            Expanded(
              child: Container(child: const SOSButton()),
            ),
            // const Text(
            //   'Privacy Statement:\nYour data is securely stored in our database.',
            //   style: TextStyle(fontSize: 16),
            // ),
          ],
        ),
      ),
    );
  }
}
