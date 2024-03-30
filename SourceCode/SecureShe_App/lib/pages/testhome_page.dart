import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:my_app/models/AppVars.dart';
import 'package:my_app/models/UserLocation/share_locationButton.dart';
import 'package:my_app/models/sos_button.dart';


class TestHomePage extends StatefulWidget {
  const TestHomePage({super.key});

  @override
  State createState() => HomePageState();
}

class HomePageState extends State<TestHomePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _firebaseMessaging = FirebaseMessaging.instance;
  final _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  @override
  void initState() {
    super.initState();
    _registerNotification();
    _configLocalNotification();
  }
  
  void _registerNotification() {
    FirebaseMessaging.onMessage.listen((message) {
      print('onMessage: $message');
      if (message.notification != null) {
        _showNotification(message.notification!);
      }
      return;
    });

    _firebaseMessaging.getToken().then((token) {
      print('push token: $token');
      if (token != null) {
        // save the token in the user's collection
        saveTokenForCurrentUser(token); 
        return; 
      }
    }).catchError((err) {
        return;     
    });
    
  }
  void saveTokenForCurrentUser(String token) async {
    User? user = _auth.currentUser;

    if (user != null) {
    CollectionReference users = _firestore.collection('Users');
    await users
        .doc(user.uid)
        .set({'token': token}, SetOptions(merge: true))
        .then((value) => print("Token added to user's document"))
        .catchError((error) => print("Failed to add token: $error"));
    } else {
      print('No user signed in');
    }
  }
  
  void _configLocalNotification() {
    final initializationSettingsAndroid = AndroidInitializationSettings('app_icon');
    final initializationSettingsIOS = DarwinInitializationSettings();
    final initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );
    _flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }
  void _showNotification(RemoteNotification remoteNotification) async {
    final androidPlatformChannelSpecifics = AndroidNotificationDetails(
      Platform.isAndroid ? 'com.example.my_app' : 'com.example.flutter_application1',
      'SecureMe app',
      playSound: true,
      enableVibration: true,
      importance: Importance.max,
      priority: Priority.high,
    );
    final iOSPlatformChannelSpecifics = DarwinNotificationDetails();
    final platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    print(remoteNotification);

    await _flutterLocalNotificationsPlugin.show(
      0,
      remoteNotification.title,
      remoteNotification.body,
      platformChannelSpecifics,
      payload: null,
    );
  }
  
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