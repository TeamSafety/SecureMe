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

// demo list
List contactlist = [['Salvation Army', 50.416950, -104.623500],
                    ['Souls Harbour Mens Shelter', 50.452810, -104.619690]];
//List contactlist = [{'name': 'Salvation Army', 'lat':50.416950, 'long':-104.623500},
//                    {'name': 'Souls Harbour Mens Shelter', 'lat':50.452810, 'long':-104.619690}];
var marker = <Marker>[];

class MyMapOSM extends StatelessWidget {
  @override

  var marker = <Marker>[
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
  ];

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
        //placeContacts(contactlist),
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
  return marker.add(
    Marker(
      point: LatLng(lat, long),
      child: Wrap(
        children:
          getMarker(name),
      ),
    ),
  );
}

placeContacts(contactlist) {
  for (var i = 0; i < contactlist.length; i++) {
    if (contactlist[i][0] != null) {
      placeMarker(contactlist[i][1], contactlist[i][2], contactlist[i][0]);
    };
  };
}