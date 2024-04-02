import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';
//import 'package:geolocator_apple/geolocator_apple.dart';
//import 'package:geolocator_android/geolocator_android.dart';
import 'dart:async';
import 'package:my_app/models/AppVars.dart';

Future<Position> _determinePosition() async {
  bool serviceEnabled;
  LocationPermission permission;
  // Test if location services are enabled.
  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    // Location services are not enabled don't continue
    // accessing the position and request users of the
    // App to enable the location services.
    return Future.error('Location services are disabled.');
  }
  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      // Permissions are denied, next time you could try
      // requesting permissions again (this is also where
      // Android's shouldShowRequestPermissionRationale
      // returned true. According to Android guidelines
      // your App should show an explanatory UI now.
      return Future.error('Location permissions are denied');
    }
  }
  if (permission == LocationPermission.deniedForever) {
    // Permissions are denied forever, handle appropriately.
    return Future.error(
        'Location permissions are permanently denied, we cannot request permissions.');
  }
  // When we reach here, permissions are granted and we can
  // continue accessing the position of the device.

  return await Geolocator.getCurrentPosition();
}

Future<Position?> grabLastLocation() async {
  Position? position = await Geolocator.getLastKnownPosition();
  return position;
}
// List<dynamic> contactlist2 = [['Salvation Army', 50.416950, -104.623500],
//                     ['Souls Harbour Mens Shelter', 50.452810, -104.619690]];
List<dynamic> contactlist = []; 
Future<String?> getCurrentUserId() async {
  FirebaseAuth auth = FirebaseAuth.instance;
  User? user = auth.currentUser;

  if (user != null) {
    return user.uid;
  } else {
    return null; // User is not logged in
  }
}


Future<void> fetchUserLocations() async {
  try {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user = auth.currentUser;
    String userId = '';  
    if (user != null) {
      userId =  user.uid;
    }
    print("User id is "); 
    print(userId); 
    DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('Users').doc(userId).get();

    if (userDoc.exists) {
      QuerySnapshot contactsSnapshot = await userDoc.reference.collection('contacts').get();

      contactsSnapshot.docs.forEach((contactDoc) async {
        String contactId = contactDoc['contactUid']; 

        DocumentSnapshot contactUserDoc = await FirebaseFirestore.instance.collection('Users').doc(contactId).get();

        if (contactUserDoc.exists) {
          String contactName = contactUserDoc['username'] ?? 'Unknown';
          double? latitude = contactUserDoc['latitude'] as double?;
          double? longitude = contactUserDoc['longitude'] as double?;

          if (latitude != null && longitude != null) {
            contactlist.add([contactName, latitude, longitude]);
          } else {
            print('Latitude or longitude is missing for contact: $contactName');
          }
        } else {
          print('Contact document with ID $contactId does not exist.');
        }
      });
    } else {
      print('User document with ID $userId does not exist.');
    }
  } catch (e) {
    print('Error fetching user locations: $e');
  }
}


// demo list
//List contactlist = [{'name': 'Salvation Army', 'lat':50.416950, 'long':-104.623500},
//                    {'name': 'Souls Harbour Mens Shelter', 'lat':50.452810, 'long':-104.619690}];
//var marker = <Marker>[];

class MyMapOSM2 extends StatefulWidget {
  @override
  _MyMapOSMState createState() => _MyMapOSMState();
}

class _MyMapOSMState extends State<MyMapOSM2> {

  @override

  /*var marker = <Marker>[
    Marker(
      point: LatLng(50.416950, -104.623500),
      child: Wrap(
        children:
          getMarker('Salvation Army'),
      ),
    ),
    Marker(
      point: LatLng(50.452810, -104.619690),
      child: Wrap(
        children:
          getMarker('Souls Harbour Mens Shelter'),
      ),
    ),
  ];*/

  var marker = placeContacts(contactlist);

  Widget build(BuildContext context) {
    return FlutterMap(
      options: const MapOptions(
        initialCenter: LatLng(50.4488, -104.6178),
        initialZoom: 9.2,
        interactiveFlags: InteractiveFlag.all & ~InteractiveFlag.rotate,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.app',
        ),
        MarkerLayer(
          markers: marker,
        ),
        CurrentLocationLayer(),
        CurrentLocationLayer(
          followOnLocationUpdate: FollowOnLocationUpdate.never,
          turnOnHeadingUpdate: TurnOnHeadingUpdate.never,
          style: LocationMarkerStyle(
            marker: DefaultLocationMarker(
              color: AppVars.accent, //(0xffFF8D83),
              child: Icon(
                Icons.navigation,
                color: Colors.white,
              ),
            ),
            markerSize: const Size(40, 40),
            markerDirection: MarkerDirection.heading,
          ),
        ), //CurrentLocationLayer
        RichAttributionWidget(
          attributions: [
            TextSourceAttribution(
              'OpenStreetMap contributors',
              onTap: () =>
                  launchUrl(Uri.parse('https://openstreetmap.org/copyright')),
            ),
          ],
        ),
      ],
    );
  }
}

getMarker(name) {
  //child:
  return <Widget>[
      Icon(Icons.location_on,
          color: AppVars.accent,
          shadows: <Shadow>[
            Shadow(color: Colors.white, blurRadius: 15.0)
          ],
          size:30.0),
      FittedBox(
        fit: BoxFit.cover,
        child: Text(name, style: TextStyle(fontWeight:FontWeight.w700, fontSize:20)),
      ),
    ];
}

placeMarker(lat, long, name) {
  if (contactlist.contains(name)) {
    contactlist.remove(name);
  }
  contactlist.add([name, lat, long]);
}

List<Marker> placeContacts(contactlist) {
  var marker = <Marker>[];
  for (var i = 0; i < (contactlist.length); i++) {
    if (contactlist[i][0] != null) {
      marker.add(new Marker(
        point: LatLng(contactlist[i][1], contactlist[i][2]),
        child: Wrap(
          children:
          getMarker(contactlist[i][0]),
        ),
      ),);
    };
  };
  return marker;
}