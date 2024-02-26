import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:my_app/models/AppVars.dart';
import 'package:my_app/models/save_location.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;
final FirebaseFirestore _firestore = FirebaseFirestore.instance;

class SOSButton extends StatelessWidget {
  const SOSButton({super.key});

  @override
  Widget build(BuildContext context) {
    return const ElevatedButton(
      onPressed: startLocationUpdates, 
      child: Text("Share location"),  
    ); 
  }
}