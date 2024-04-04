import 'dart:async';

import 'package:geolocator/geolocator.dart';
import 'package:my_app/pages/map_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> saveToDatabase(Position position, String userID) async {
  CollectionReference usersCollection = FirebaseFirestore.instance.collection('Users');
  DocumentReference userDocRef = usersCollection.doc(userID);

  Map<String, dynamic> data = {
    'latitude': position.latitude,
    'longitude': position.longitude,
    'timestamp': FieldValue.serverTimestamp(), // timestamp for when the data was saved
  };
  // Set the data to the document
  await userDocRef.update(data);
  
  print('Saved to Firestore: ${position.latitude}, ${position.longitude}');
}


Future<void> startLocationUpdates(String userID, bool sharingLocation) async {
  // Get the last known location
  Position? initialPosition = await grabLastLocation();
  if (initialPosition != null) {
    // Save the initial position to the database
    await saveToDatabase(initialPosition, userID);
  }

  // Set up a periodic timer to update the location every few seconds
  const Duration updateInterval = Duration(seconds: 10);
  Timer.periodic(updateInterval, (timer) async {
    if(sharingLocation == true){
      Position? currentPosition = await grabLastLocation();
      if (currentPosition != null) {
        // Save the current position to the database
        await saveToDatabase(currentPosition, userID);
      }
    }
  });
}


