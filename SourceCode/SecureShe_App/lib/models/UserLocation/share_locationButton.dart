import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:my_app/models/UserLocation/save_location.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;
final FirebaseFirestore _firestore = FirebaseFirestore.instance;


class LocationPage extends StatefulWidget {
  @override
  _LocationPageState createState() => _LocationPageState();
}
class _LocationPageState extends State<LocationPage> {
  bool isLocationSharing = false; // taggle the button
  Timer? locationTimer;
  bool shouldSaveLocation = false; // Flag to control saving location updates, false=don't save location


  @override
  void dispose() {
    locationTimer?.cancel();
    super.dispose();
  }

  Future<void> stopLocationUpdates(bool shouldSave) async {
    shouldSaveLocation = shouldSave; 
    locationTimer?.cancel();
    locationTimer = null; // Set the timer to null to indicate it's not running
  }

  void toggleLocationSharing() {
    User? user = _auth.currentUser;
    setState(() {
      if (isLocationSharing) {
        // Stop location sharing
        stopLocationUpdates(shouldSaveLocation);
      } else {
        // Start location sharing
        if(user!=null){
          shouldSaveLocation = true;
          startLocationUpdates(user.uid, shouldSaveLocation);
        }
      }
      isLocationSharing = !isLocationSharing;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Location Sharing'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: toggleLocationSharing,
          child: Text(isLocationSharing
              ? 'Stop Location Sharing'
              : 'Start Location Sharing'),
        ),
      ),
    );
  }
}
