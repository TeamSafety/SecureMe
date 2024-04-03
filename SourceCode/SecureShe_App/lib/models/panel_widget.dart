import 'package:flutter/material.dart';
import 'package:my_app/models/AppVars.dart';
import 'package:my_app/models/PersonalConatcts/personal_contact.dart';
import 'package:my_app/models/user_active_location.dart';

class PanelWidget extends StatelessWidget {
  final ScrollController controller;

  const PanelWidget({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20),
      child: ListView(
        controller: controller,
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
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        UserSharingLoc(
            contactName: "Someone",
            imagePath: "assets/images/avatar_default.jpg",
            addedContactUid: "addedContactUid",
            currentUserId: "currentUserId")
      ],
    );
  }
}
