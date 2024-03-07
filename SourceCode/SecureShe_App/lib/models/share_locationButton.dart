import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:my_app/models/save_location.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;
final FirebaseFirestore _firestore = FirebaseFirestore.instance;


class LocationPage extends StatefulWidget {
  @override
  _LocationPageState createState() => _LocationPageState();
}

class _LocationPageState extends State<LocationPage> {
  bool isLocationSharing = false;
  Timer? locationTimer;

  @override
  void dispose() {
    locationTimer?.cancel();
    super.dispose();
  }

  Future<void> stopLocationUpdates() async {
    locationTimer?.cancel();
  }

  void toggleLocationSharing() {
    setState(() {
      if (isLocationSharing) {
        // Stop location sharing
        stopLocationUpdates();
      } else {
        // Start location sharing
        startLocationUpdates();
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
