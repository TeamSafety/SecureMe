import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:my_app/models/AppVars.dart';
import 'package:my_app/models/PersonalContacts/personalContact.dart';
import 'package:my_app/models/PersonalContacts/personal_contact.dart';
import 'package:my_app/models/user_active_location.dart';

class PanelWidget extends StatefulWidget {
  final ScrollController controller;

  const PanelWidget({super.key, required this.controller});

  @override
  State<PanelWidget> createState() => _PanelWidgetState();
}

class _PanelWidgetState extends State<PanelWidget> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<PersonalContactModel> personalContacts = [];

  @override
  void initState() {
    super.initState();
    getPersonalContacts();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20),
      child: ListView(
        controller: widget.controller,
        padding: EdgeInsets.zero,
        children: <Widget>[
          SizedBox(height: AppVars.elementMargin),
          buildPanelTitle(),
          SizedBox(height: AppVars.elementMargin),
          buildListUser(),
        ],
      ),
    );
  }

  Future<void> getPersonalContacts() async {
    User? user = _auth.currentUser;
    if (user != null) {
      QuerySnapshot<Map<String, dynamic>> querySnapshot = await _firestore
          .collection('Users')
          .doc(user.uid)
          .collection('contacts')
          .get();
      setState(() {
        // Update the personalContacts list with fetched data
        personalContacts = querySnapshot.docs
            .map((doc) => PersonalContactModel.fromMap(doc.data()))
            .toList();
      });
    }
  }

  Widget buildPanelTitle() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(
          child: Container(
            height: 30,
            alignment: Alignment.centerLeft,
            child: Text(
              'Active Location Sharing',
              style: TextStyle(
                  color: AppVars.secondary.withOpacity(0.9), fontSize: 16),
            ),
          ),
        ),
        Container(
          child: Icon(
            Icons.expand_less,
            size: 35,
            color: AppVars.accent,
          ),
        ),
      ],
    );
  }

  Widget buildListUser() {
    return personalContactsBuilder();
  }

  Column personalContactsBuilder() {
    return Column(
      children: [
        for (PersonalContactModel contact in personalContacts)
          (contact.lat == 0 && contact.long == 0)
              ? Column(
                  children: [
                    UserSharingLoc(
                      contactName: contact.contactName,
                      imagePath: contact.profile_image,
                      addedContactUid: contact.addedContactUid,
                      currentUserId: _auth.currentUser!.uid,
                      lat: contact.lat,
                      long: contact.long,
                    ),
                    const SizedBox(height: 8),
                  ],
                )
              : Column(),
      ],
    );
  }
}
