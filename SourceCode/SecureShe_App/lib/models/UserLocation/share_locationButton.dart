import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:my_app/models/AppVars.dart';
import 'package:my_app/pages/osm_page.dart';

//variables declaration
final FirebaseAuth _auth = FirebaseAuth.instance;
bool isLocationSharing = false;
Timer? locationTimer;
bool shouldSaveLocation = false;

class ShareLocationButton extends StatefulWidget {
  @override
  _ShareLocationButtonState createState() => _ShareLocationButtonState();
}

class _ShareLocationButtonState extends State<ShareLocationButton> {
  @override
  void dispose() {
    stopLocationUpdates();
    super.dispose();
  }

  Future<void> stopLocationUpdates() async {
    shouldSaveLocation = false;
    locationTimer?.cancel();
  }

  void toggleLocationSharing() {
    User? user = _auth.currentUser;
    setState(() {
      if (isLocationSharing) {
        // Stop location sharing
        stopLocationUpdates();
      } else {
        // Start location sharing
        if (user != null) {
          shouldSaveLocation = true;
          startLocationUpdates(user.uid);
        }
      }
      isLocationSharing = !isLocationSharing;
    });
  }

  @override
  Widget build(BuildContext context) {
    final ButtonStyle unSelectedStyle = ElevatedButton.styleFrom(
      foregroundColor: AppVars.accent,
      backgroundColor: AppVars.primary,
      shadowColor: AppVars.secondary.withOpacity(0.8),
      side: BorderSide(
        color: AppVars.accent,
        width: 0.5,
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
    );

    final ButtonStyle selectedStyle = ElevatedButton.styleFrom(
      foregroundColor: AppVars.primary,
      backgroundColor: AppVars.accent,
      shadowColor: AppVars.accent.withOpacity(0.8),
      side: BorderSide(
        color: AppVars.accent,
        width: 0.5,
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
    );

    return Container(
      alignment: Alignment.topCenter,
      child: ElevatedButton(
        style: isLocationSharing ? selectedStyle : unSelectedStyle,
        onPressed: toggleLocationSharing,
        child: Text(isLocationSharing
            ? 'Stop Location Sharing'
            : 'Start Location Sharing'),
      ),
    );
  }
}

Future<void> saveToDatabase(Position position, String userID) async {
  CollectionReference usersCollection =
      FirebaseFirestore.instance.collection('Users');
  DocumentReference userDocRef = usersCollection.doc(userID);

  Map<String, dynamic> data = {
    'latitude': position.latitude,
    'longitude': position.longitude,
    'timestamp': FieldValue.serverTimestamp(),
  };
  await userDocRef.update(data);
}

Future<void> startLocationUpdates(String userID) async {
  // Initial save
  Position? initialPosition = await grabLastLocation();
  if (initialPosition != null) {
    await saveToDatabase(initialPosition, userID);
  }

  // Periodic updates
  const Duration updateInterval = Duration(seconds: 10);

  locationTimer = Timer.periodic(updateInterval, (timer) async {
    if (shouldSaveLocation) {
      Position? currentPosition = await grabLastLocation();
      if (currentPosition != null) {
        await saveToDatabase(currentPosition, userID);
      }
    } else {

      timer.cancel(); // Stop the timer if saving location updates is disabled
      await clearLocationData(userID); // set location data to null
    }
  });
}
Future<void> clearLocationData(String userID) async{
  CollectionReference usersCollection =
      FirebaseFirestore.instance.collection('Users');
  DocumentReference userDocRef = usersCollection.doc(userID);
  Map<String, dynamic> data = {
    'latitude': null,
    'longitude': null,
    'timestamp': FieldValue.serverTimestamp(),
  };
  await userDocRef.update(data); 

}
