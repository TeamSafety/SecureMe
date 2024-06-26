import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:latlong2/latlong.dart';
import 'package:my_app/models/UserLocation/share_locationButton.dart';
import 'package:my_app/models/contacts_data.dart';
import 'package:my_app/models/panel_widget.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';
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

List<dynamic> contactlist = [];
List<UserData> userList = [];

Future<void> fetchUserLocations() async {
  try {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user = auth.currentUser;
    String userId = user?.uid ?? '';

    DocumentSnapshot userDoc =
        await FirebaseFirestore.instance.collection('Users').doc(userId).get();

    if (userDoc.exists) {
      QuerySnapshot contactsSnapshot =
          await userDoc.reference.collection('contacts').get();
      List<UserData> users = [];
      contactsSnapshot.docs.forEach((contactDoc) async {
        String contactId = contactDoc['contactUid'];

        DocumentSnapshot contactUserDoc = await FirebaseFirestore.instance
            .collection('Users')
            .doc(contactId)
            .get();

        if (contactUserDoc.exists) {
          String contactName = contactUserDoc['username'] ?? 'Unknown';
          double? latitude = contactUserDoc['latitude'] as double?;
          double? longitude = contactUserDoc['longitude'] as double?;
          String profileImageURL = contactUserDoc['profile_image'] ?? "";

          if (latitude != null && longitude != null) {
            contactlist.add([contactName, latitude, longitude, profileImageURL]);
            users.add(
              UserData(
                username: contactName,
                latitude: latitude,
                longitude: longitude,
                profileImageURL: profileImageURL,
                currentUid: userId,
                receiverId: contactId,
              ),
            );
          } else {
            print(
                'Latitude or longitude info is missing for contact: $contactName');
          }
        } else {
          print('Contact document with ID $contactId does not exist.');
        }
      });
      userList = users;
    } else {
      print('User document with ID $userId does not exist.');
    }
  } catch (e) {
    print('Error fetching user locations: $e');
  }
}

class MyMapOSM2 extends StatefulWidget {
  @override
  _MyMapOSMState createState() => _MyMapOSMState();
}

class _MyMapOSMState extends State<MyMapOSM2> {
  @override
  void initState() {
    super.initState();
    fetchUserLocations();
  }

  var marker = placeContacts(contactlist);

  Widget build(BuildContext context) {
    final panelMaxHeight = MediaQuery.of(context).size.height * 0.45;

    _placeMarkers() {
      setState(() {});
    }

    return SlidingUpPanel(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(10),
        topRight: Radius.circular(10),
      ),
      parallaxEnabled: true,
      parallaxOffset: 0.05,
      minHeight: 50,
      maxHeight: panelMaxHeight,
      panelBuilder: (controller) => PanelWidget(
        controller: controller,
      ),
      body: FlutterMap(
        options: const MapOptions(
          initialCenter: LatLng(50.4488, -104.6178),
          initialZoom: 12.2,
        ),
        children: [
          Stack(
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.app',
              ),
              MarkerLayer(
                markers: marker,
              ),
              CurrentLocationLayer(
                followOnLocationUpdate: FollowOnLocationUpdate.never,
                turnOnHeadingUpdate: TurnOnHeadingUpdate.never,
                style: LocationMarkerStyle(
                  marker: DefaultLocationMarker(
                    color: AppVars.accent,
                    child: Icon(
                      Icons.navigation,
                      color: Colors.white,
                    ),
                  ),
                  markerSize: const Size(40, 40),
                  markerDirection: MarkerDirection.heading,
                ),
              ),
              RichAttributionWidget(
                attributions: [
                  TextSourceAttribution(
                    'OpenStreetMap contributors',
                    onTap: () => launchUrl(
                        Uri.parse('https://openstreetmap.org/copyright')),
                  ),
                ],
              ),
              Column(
                children: [
                  SizedBox(
                    height: AppVars.elementMargin,
                  ),
                  ShareLocationButton(),
                ],
              ),
            ],
          )
        ],
      ),
    );
  }
}

getMarker(name, String imageURL) {
  return <Widget>[
    Column(
      children: [
        Stack(
          alignment: Alignment.topCenter,
          children: [
            Container(
              child: Transform.scale(
                scale: 2,
                origin: Offset(0, -6),
                child: Icon(
                  Icons.location_on,
                  color: AppVars.accent,
                ),
              ),
            ),
            Container(
              clipBehavior: Clip.hardEdge,
              height: 25,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppVars.secondary,
                boxShadow: [
                  BoxShadow(color: AppVars.primary, spreadRadius: 0.4),
                ],
              ),
              child:Image.network(imageURL, fit: BoxFit.scaleDown,
                height: double.infinity,
                width: double.infinity,
                alignment: Alignment.center,
              ),
            ),
          ],
        ),
        Transform.scale(
          scale: 3,
          origin: Offset(0, -9),
          child: FittedBox(
            child: Text(
              name,
              style: TextStyle(color: AppVars.secondary.withOpacity(0.8)),
            ),
          ),
        )
      ],
    ),
  ];
}

placeMarker(lat, long, name, String imageURL) {
  if (contactlist.contains(name)) {
    contactlist.remove(name);
  }
  contactlist.add([name, lat, long, imageURL]);
}

List<Marker> placeContacts(contactlist) {
  var marker = <Marker>[];
  for (var i = 0; i < (contactlist.length); i++) {
    if (contactlist[i][0] != null && contactlist[i][1] != null) {
      marker.add(
        new Marker(
          point: LatLng(contactlist[i][1], contactlist[i][2]),
          child: Wrap(
            children: getMarker(contactlist[i][0], contactlist[i][3]),
          ),
        ),
      );
    }
  }
  return marker;
}
