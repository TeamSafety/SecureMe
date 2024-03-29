import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:my_app/models/AppVars.dart';
import 'package:my_app/pages/osm_page.dart';
import 'package:url_launcher/url_launcher.dart';

class CommunityContact extends StatelessWidget {
  final String contactName;
  final String phoneNumber;
  final double lat; 
  final double long; 
  const CommunityContact({
    super.key,
    required this.contactName,
    required this.phoneNumber,
    required this.lat, 
    required this.long, 
  });
  @override
  Widget build(BuildContext context) {
    return // CONTACT ROW
        Container(
      width: double.infinity,
      height: 80,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      decoration: BoxDecoration(
        color: AppVars.primary,
        borderRadius: const BorderRadius.all(Radius.circular(10)),
        boxShadow: [
          BoxShadow(
            color: AppVars.secondary.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2.0),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          // PROFILE PIC
          AspectRatio(
            aspectRatio: 1,
            child: Container(
              height: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey,
                borderRadius: const BorderRadius.all(
                  Radius.circular(10),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppVars.secondary.withOpacity(0.3),
                    blurRadius: 4,
                    offset: const Offset(0, 2.0),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  contactName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppVars.secondary,
                    fontSize: AppVars.textTitle,
                  ),
                ),
                const SizedBox(
                  height: 2,
                ),
                Expanded(
                  child: Row(
                    children: [
                      // CONTACT BUTTON
                      GestureDetector(
                        onTap: () {
                          //TODO: pass the user ID!!! - for Kawthar
                          addCommunityToPersonal("userId", contactName); 
                        },
                        child: AspectRatio(
                          aspectRatio: 1,
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppVars.accent,
                              borderRadius: const BorderRadius.all(
                                Radius.circular(10),
                              ),
                              border: Border.all(color: Colors.white),
                              boxShadow: [
                                BoxShadow(
                                  color: AppVars.secondary.withOpacity(0.3),
                                  blurRadius: 2,
                                  offset: const Offset(0, 2.0),
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.add,
                              color: AppVars.primary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8), // CONTACT BUTTON
                      GestureDetector(
                        onTap: () {
                          _makePhoneCall(phoneNumber);
                        },
                        child: AspectRatio(
                          aspectRatio: 1,
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppVars.primary,
                              borderRadius: const BorderRadius.all(
                                Radius.circular(10),
                              ),
                              border: Border.all(
                                  color: AppVars.secondary.withOpacity(0.2)),
                              boxShadow: [
                                BoxShadow(
                                  color: AppVars.secondary.withOpacity(0.2),
                                  blurRadius: 2,
                                  offset: const Offset(0, 2.0),
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.phone_callback,
                              color: AppVars.accent,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // CONTACT BUTTON
                      GestureDetector(
                        onTap: () {
                          placeMarker(lat, long, contactName);
                        },
                        child: AspectRatio(
                          aspectRatio: 1,
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppVars.primary,
                              borderRadius: const BorderRadius.all(
                                Radius.circular(10),
                              ),
                              border: Border.all(
                                  color: AppVars.secondary.withOpacity(0.2)),
                              boxShadow: [
                                BoxShadow(
                                  color: AppVars.secondary.withOpacity(0.2),
                                  blurRadius: 2,
                                  offset: const Offset(0, 2.0),
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.map,
                              color: AppVars.accent,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  Future<void> addCommunityToPersonal(String userId, String conatctName) async {
    String contactID = await getContactID(conatctName); 

  try {
    DocumentReference userRef =
        FirebaseFirestore.instance.collection('Users').doc(userId);
    DocumentSnapshot userSnapshot = await userRef.get();
    if (userSnapshot.exists) {
      await userRef.collection('communityContacts').doc(contactID).set({
        'contactName': contactName, 
        'phoneNumber': phoneNumber, 
        'lat': lat,
        'long': long, 
      });

      print('Community contact added to personal contacts successfully.');
    } 
    else {
      print('User does not exist.');
    }
  } catch (error) {
    print('Error adding community contact to personal contacts: $error');
  }
  }
  Future<String> getContactID(String conatctName) async{
    try{
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await FirebaseFirestore.instance
              .collection('localContacts')
              .where('organization', isEqualTo: conatctName)
              .get();
      if(querySnapshot.docs.isNotEmpty){
        return querySnapshot.docs.first.id; 
      }
      else{
        return " "; 
      }
    }
    catch(e){
      print("Error preventing adding community conatcts"); 
      return " "; 
    }
  }

}

Future<void> _makePhoneCall(String phoneNumber) async {
  final Uri launchUri = Uri(
    scheme: 'tel',
    path: phoneNumber,
  );
  await launchUrl(launchUri);
}

