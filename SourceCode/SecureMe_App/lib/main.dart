import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:my_app/models/AppVars.dart';
import 'package:my_app/pages/login.dart';
import 'package:my_app/pages/main_pages_setup.dart';
import 'firebase_options.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:rxdart/rxdart.dart';

// used to pass messages from event handler to the UI
final _messageStreamController = BehaviorSubject<RemoteMessage>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );  // Request permission
  final messaging = FirebaseMessaging.instance;
  final settings = await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );
  if (kDebugMode) {
    print('Permission granted: ${settings.authorizationStatus}');
  }
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        fontFamily: "ArbutusSlab",
        colorScheme: ThemeData().colorScheme.copyWith(
              primary: AppVars.secondary.withOpacity(0.5),
            ),
      ),
      debugShowCheckedModeBanner: false,
      home: LoginPage(),
      //home: MainPage(),
    );
  }
}
