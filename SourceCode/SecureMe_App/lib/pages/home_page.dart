import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:my_app/models/AppVars.dart';
import 'package:my_app/models/UserLocation/share_locationButton.dart';
import 'package:my_app/models/sos_button.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:my_app/pages/chat_page.dart';
import 'package:rxdart/rxdart.dart';

late String routeToGo = '/';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _firebaseMessaging = FirebaseMessaging.instance;
  final _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  final _messageStreamController = BehaviorSubject<RemoteMessage>();
  bool _isNewMessage = false; // Flag to track new messages

  @override
  void initState() {
    super.initState();
    _registerNotification();
    // _configLocalNotification();
  }

  void _registerNotification() {
    // FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    //   print('onMessage: $message');
    //   if (message.notification != null) {
    //     _showNotification(message.notification!);
    //   }
    //   return;
    // });
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (kDebugMode) {
        print('Handling a foreground message: ${message.messageId}');
        print('Message data: ${message.data}');
        print('Message notification: ${message.notification?.title}');
        print('Message notification: ${message.notification?.body}');
        _handleForegroundMessage(message); 
      }
      if (mounted) {
          _messageStreamController.sink.add(message);

          setState(() {
            _isNewMessage = true;
          });
        }
      });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('onMessageOpenedApp: $message');
      // Handle notification when the app is in the background but opened by the user.
      if (message.notification != null) {
        print("Sender ID ");
        print(message.data['sender']);
        final senderId = message.data['sender'];
        final receiverId = message.data['receiver'];
        print("receiver ID: "); 
        print(receiverId);
        if (mounted) {
          Navigator.push(context,
            MaterialPageRoute(
              builder: (context) => ChatScreen(
                userId: senderId,
                recipientUserId: receiverId
              ),
            ),
          );
        }
      }
    });
    Future<void> _firebaseMessagingBackgroundHandler(
    RemoteMessage message) async {
      await Firebase.initializeApp();
      print("Handling a background message: ${message.messageId}");
      print('Message data: ${message.data}');
      if (kDebugMode) {
        print("Handling a background message: ${message.messageId}");
        print('Message data: ${message.data}');
        print('Message notification: ${message.notification?.title}');
        print('Message notification: ${message.notification?.body}');
      }
    }

    // callback is triggered when the app is terminated and the user taps on a notification.
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
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
  void _handleForegroundMessage(RemoteMessage message) {
  // Extract necessary data from the message
    final senderId = message.data['sender'];
    final receiverId = message.data['receiver'];

    // Add your logic here to handle foreground messages
    print('Foreground message received:');
    print('Sender ID: $senderId');
    print('Receiver ID: $receiverId');
    if (mounted) {
      Navigator.push(context,
            MaterialPageRoute(
              builder: (context) => ChatScreen(
                userId: senderId,
                recipientUserId: receiverId
              ),
            ),
          );
    }
    
}
  @override
  void dispose() {
    // Make sure to dispose any resources when the widget is disposed
    super.dispose();
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
    final initializationSettingsAndroid =
        AndroidInitializationSettings('assets/images/avatar_default.jpg');
    final initializationSettingsIOS = DarwinInitializationSettings();
    final initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );
    _flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  void _showNotification(RemoteNotification remoteNotification) async {
    final androidPlatformChannelSpecifics = AndroidNotificationDetails(
      Platform.isAndroid
          ? 'com.example.my_app'
          : 'com.example.flutter_application1',
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

    // await _flutterLocalNotificationsPlugin.show(
    //   0,
    //   remoteNotification.title,
    //   remoteNotification.body,
    //   platformChannelSpecifics,
    //   payload: null,
    // );
  }
  void _resetNewMessageFlag() {
    // Reset the flag after handling the notification
    setState(() {
      _isNewMessage = false;
    });
  }
  @override
  Widget build(BuildContext context) {
    if (_isNewMessage) {
      // Reset the flag if the widget is rebuilt
      _resetNewMessageFlag();
    }
    return Scaffold(
      appBar: _isNewMessage ? AppBar(title: Text('')) : null,
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
