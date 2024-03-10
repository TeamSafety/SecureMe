import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:my_app/pages/osm_page.dart';


final FirebaseAuth _auth = FirebaseAuth.instance;
final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool isLocationSharing = false;
  Timer? locationTimer;
  bool shouldSaveLocation = false;
class LocationPage extends StatefulWidget {
  @override
  _LocationPageState createState() => _LocationPageState();
}

class _LocationPageState extends State<LocationPage> {

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

Future<void> saveToDatabase(Position position, String userID) async {
  CollectionReference usersCollection = FirebaseFirestore.instance.collection('Users');
  DocumentReference userDocRef = usersCollection.doc(userID);

  Map<String, dynamic> data = {
    'latitude': position.latitude,
    'longitude': position.longitude,
    'timestamp': FieldValue.serverTimestamp(),
  };
  await userDocRef.update(data);

  print('Saved to Firestore: ${position.latitude}, ${position.longitude}');
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
    }
  });
}
