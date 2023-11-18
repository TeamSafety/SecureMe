import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'login.dart';
import 'signup.dart'; 


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false, // Add this line
      home: MyHomePage(title: 'SecureShe',),
    ),
  );
}


class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const SizedBox(height: 20),
            Center(
              child:Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children:[
                  Row(
                    children: [
                      const Text("You have an account? "),  
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => LoginPage()),
                          );
                        },
                        child: const Text("Login", style: TextStyle(color: Color.fromARGB(255, 239, 163, 69)),)
                      ),
                    ],
                  ),
                  const SizedBox(height: 50),
                  Column(
                    children:[
                      Row(
                        children: [
                          const Text(
                            "If you are a new user to the app "
                          ), 
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => Signup()),
                              );
                            },
                            child: const Text("Sign up", style: TextStyle(color: Color.fromARGB(255, 239, 163, 69)),)
                          ),
                        ],
                      ), 
                    ]
                  ), 
                  const SizedBox(height: 10),
                ],
              )
            ) 
          ],
        ),
      ),
    );
  }
}
