import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_app/models/AppColors.dart'; 

class ContactPage extends StatefulWidget {
  @override
  _ContactPageState createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  late Map<String, dynamic> contactData;

  @override
  void initState() {
    super.initState();
    contactData = {}; 
    loadContactData();
  }

  Future<void> loadContactData() async {
    ByteData data = await rootBundle.load('localResources.json');
    String jsonString = utf8.decode(data.buffer.asUint8List());
    setState(() {
      contactData = json.decode(jsonString);
    });
  }
  
  Widget buildContactList(List<dynamic> contacts) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: contacts
        .map((contact) => Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    contact['organization'],
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text('Phone: ${contact['phone'] ?? 'N/A'}'),
                ],
              ),
            ))
        .toList(),
  );
}

  @override
  Widget build(BuildContext context) {
    if (contactData.isEmpty) {
      // Data is still loading, show a loading indicator or some other UI
      return CircularProgressIndicator();
    } else {
      // Data has been loaded, you can use it in your UI
      return Scaffold(
        // appBar: AppBar(
        //   title: const Text('Local Resources Contacts'),
        // ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            children: [
              Text("Emergency Contacts", 
                style: TextStyle(
                  color:AppColors.accent, 
                  fontWeight: FontWeight.bold, 
                  fontSize: 26, 
                ), 
              ), 
              buildContactList(contactData['emergencyContacts']['helpLines']),
              Text("Shelters", 
                style: TextStyle(
                  color:AppColors.accent, 
                  fontWeight: FontWeight.bold, 
                  fontSize: 26, 
                ), 
              ), 
              buildContactList(contactData['shelters']),
              // buildContactList(contactData['counsellingAndSupportServices']),

            ],
          ),
        ),
      );
    }
  }
}
