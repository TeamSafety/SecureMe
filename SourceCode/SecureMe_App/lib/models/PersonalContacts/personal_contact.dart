import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:my_app/models/AppVars.dart';
import 'package:my_app/pages/chat_page.dart';
import 'package:my_app/pages/map_page.dart';

class PersonalContact extends StatefulWidget {
  final String contactName;
  final String imagePath; // TODO: WILL CHANGE LATER
  final String addedContactUid;
  final String currentUserId;
  final double lat;
  final double long;

  const PersonalContact({
    super.key,
    required this.contactName,
    required this.imagePath,
    required this.addedContactUid,
    required this.currentUserId,
    required this.lat,
    required this.long,
  });
  @override
  _PersonalContactState createState() => _PersonalContactState();
}

class _PersonalContactState extends State<PersonalContact> {
  @override
  Widget build(BuildContext context) {
    // CONTACT ROW
    return Container(
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
                clipBehavior: Clip.hardEdge,
                height: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: AppVars.secondary.withOpacity(0.5),
                  ),
                  borderRadius: const BorderRadius.all(
                    Radius.circular(100),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppVars.secondary.withOpacity(0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 2.0),
                    ),
                  ],
                ),
                child: Transform.scale(
                  scale: 1.1,
                  child: Image.network(
                    widget.imagePath,
                    fit: BoxFit.fill,
                    height: double.infinity,
                    width: double.infinity,
                    alignment: Alignment.center,
                  ),
                )),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  widget.contactName,
                  style: TextStyle(
                    color: AppVars.secondary,
                    fontSize: AppVars.textTitle,
                  ),
                ),
                const SizedBox(
                  height: 3,
                ),
                Expanded(
                  child: Row(
                    children: [
                      // LOCATE BUTTON
                      GestureDetector(
                        onTap: () {
                        if (widget.lat != 0 && widget.long != 0) {
                          if(widget.imagePath == ''){
                            placeMarker(
                              widget.lat,
                              widget.long,
                              widget.contactName,
                              "https://firebasestorage.googleapis.com/v0/b/she-1acd0.appspot.com/o/avatar_default.jpg?alt=media&token=395337cf-96ee-49a8-84cb-e8e40537cde8", 
                            );
                          }
                          placeMarker(
                            widget.lat,
                            widget.long,
                            widget.contactName,
                            widget.imagePath, 
                          );
                        }
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MyMapOSM2(),
                            ),
                          );
                          // }
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
                              Icons.map,
                              color: AppVars.primary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // CONTACT BUTTON
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChatScreen(
                                  userId: widget.currentUserId,
                                  recipientUserId: widget.addedContactUid),
                            ),
                          );
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
                              Icons.message,
                              color: AppVars.accent,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // CALL BUTTON
                      GestureDetector(
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
      DocumentReference userRef = FirebaseFirestore.instance
          .collection('Users')
          .doc(widget.currentUserId);
      DocumentSnapshot userSnapshot = await userRef.get();

      if (userSnapshot.exists) {
        CollectionReference communityContactsRef =
            userRef.collection("contacts");

        QuerySnapshot querySnapshot = await communityContactsRef
            .where('contactName', isEqualTo: widget.contactName)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          DocumentReference contactDocRef = querySnapshot.docs.first.reference;
          await contactDocRef.delete();
          // Rebuild the widget to reflect the changes
          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Contact has been removed from your personal contacts successfully.',
                style: TextStyle(color: Colors.white),
              ),
              backgroundColor: AppVars.accent,
              behavior: SnackBarBehavior.floating,
              duration: Duration(seconds: 3),
            ),
          );
        } else {
          print('Contact not found in personal contacts.');
        }
      } else {
        print('User does not exist.');
      }
    } catch (error) {
      print('Error removing contact from personal contacts: $error');
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
