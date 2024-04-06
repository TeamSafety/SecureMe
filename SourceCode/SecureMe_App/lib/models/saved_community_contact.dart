import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:my_app/models/AppVars.dart';
import 'package:my_app/pages/map_page.dart';
import 'package:url_launcher/url_launcher.dart';

class SavedCommunityContact extends StatelessWidget {
  final String contactName;
  final String phoneNumber;
  final String userId;
  final double lat;
  final double long;
  const SavedCommunityContact({
    super.key,
    required this.contactName,
    required this.phoneNumber,
    required this.userId,
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
                      // MAP BUTTON
                      (lat != 0 && long != 0)
                          ? GestureDetector(
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
                                    color: AppVars.accent,
                                    borderRadius: const BorderRadius.all(
                                      Radius.circular(10),
                                    ),
                                    border: Border.all(color: AppVars.primary),
                                    boxShadow: [
                                      BoxShadow(
                                        color:
                                            AppVars.secondary.withOpacity(0.2),
                                        blurRadius: 2,
                                        offset: const Offset(0, 2.0),
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    Icons.map,
                                    color: AppVars.primary,
                                  ),
                                ),
                              ),
                            )
                          : GestureDetector(
                              onTap: () {},
                              child: AspectRatio(
                                aspectRatio: 1,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: AppVars.secondary.withOpacity(0.2),
                                    borderRadius: const BorderRadius.all(
                                      Radius.circular(10),
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.map,
                                    color: AppVars.secondary.withOpacity(0.5),
                                  ),
                                ),
                              ),
                            ),
                      const SizedBox(width: 8),
                      // CONTACT BUTTON
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
                      GestureDetector(
                        onTap: () {
                          _removeContact(context);
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
                              Icons.remove_circle,
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

  void _removeContact(BuildContext context) async {
    try {
      DocumentReference userRef =
          FirebaseFirestore.instance.collection('Users').doc(userId);
      DocumentSnapshot userSnapshot = await userRef.get();

      if (userSnapshot.exists) {
        CollectionReference communityContactsRef =
            userRef.collection("communityContacts");

        QuerySnapshot querySnapshot = await communityContactsRef
            .where('contactName', isEqualTo: contactName)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          DocumentReference contactDocRef = querySnapshot.docs.first.reference;
          await contactDocRef.delete();

          // Show success message
          // ignore: unnecessary_null_comparison
          if (context != null) {
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
          }
        } else {
          print('Contact not found in personal contacts.');
        }
      } else {
        print('User does not exist.');
      }
    } catch (error) {
      print('Error removing community contact from personal contacts: $error');
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(
      //     content: Text(
      //       'Error removing community contact from personal contacts',
      //       style: TextStyle(color: Colors.white),
      //     ),
      //     backgroundColor: AppVars.accent,
      //     behavior: SnackBarBehavior.floating,
      //     duration: Duration(seconds: 3),
      //   ),
      // );
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
