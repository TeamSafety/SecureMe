import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:my_app/models/AppVars.dart';
import 'package:my_app/pages/map_page.dart';
import 'package:url_launcher/url_launcher.dart';

class CommunityContact extends StatelessWidget {
  final String contactName;
  final String phoneNumber;
  final double lat;
  final double long;
  final String userId;
  const CommunityContact({
    super.key,
    required this.contactName,
    required this.phoneNumber,
    required this.lat,
    required this.long,
    required this.userId,
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
          // Image
          AspectRatio(
            aspectRatio: 1,
            child: Container(
              height: double.infinity,
              decoration: BoxDecoration(
                color: AppVars.secondary.withOpacity(0.5),
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
                      // Add BUTTON
                      GestureDetector(
                        onTap: () {
                          addCommunityToPersonal(userId, contactName, context);
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
                          if (phoneNumber != 'N/A') {
                            _makePhoneCall(phoneNumber);
                          }
                          ;
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
                              color: (phoneNumber == 'N/A')
                                  ? AppVars.secondary.withOpacity(0.1)
                                  : AppVars.accent,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // CONTACT BUTTON
                      GestureDetector(
                        onTap: () {
                          if (lat != 0.0 && long != 0.0) {
                            placeMarker(lat, long, contactName);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MyMapOSM2(),
                              ),
                            );
                          }
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
                              color: (lat == 0.0 && long == 0.0)
                                  ? AppVars.secondary.withOpacity(0.1)
                                  : AppVars.accent,
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

  Future<void> addCommunityToPersonal(
      String userId, String conatctName, BuildContext context) async {
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Community contact added to personal contacts successfully.',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: AppVars.accent,
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 3),
          ),
        );
      } else {
        print('User does not exist.');
      }
    } catch (error) {
      print('Error adding community contact to personal contacts: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error adding community contact to personal contacts',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: AppVars.accent,
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  Future<String> getContactID(String conatctName) async {
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await FirebaseFirestore.instance
              .collection('localContacts')
              .where('organization', isEqualTo: conatctName)
              .get();
      if (querySnapshot.docs.isNotEmpty) {
        return querySnapshot.docs.first.id;
      } else {
        return " ";
      }
    } catch (e) {
      print("Error preventing adding community conatcts");
      return " ";
    }
  }

  void _removeContact(BuildContext context) async {
    try {
      DocumentReference userRef =
          FirebaseFirestore.instance.collection('Users').doc(userId);
      await userRef.collection('communityContacts').doc(contactName).delete();

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Community contact removed from personal contacts successfully.',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: AppVars.accent,
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 3),
        ),
      );
    } catch (error) {
      print('Error removing community contact from personal contacts: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error removing community contact from personal contacts',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: AppVars.accent,
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 3),
        ),
      );
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
