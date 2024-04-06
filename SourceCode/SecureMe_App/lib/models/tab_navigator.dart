import 'package:flutter/material.dart';
import 'package:my_app/pages/community_list.dart';
import 'package:my_app/pages/home_page.dart';
import 'package:my_app/pages/map_page.dart';
import 'package:my_app/pages/my_contacts.dart';
import 'package:my_app/pages/my_profile.dart';

class TabNavigatorRoutes {
  static const String root = '/';
  static const String detail = '/detail';
}

class TabNavigator extends StatelessWidget {
  final GlobalKey<NavigatorState> navigatorKey;
  final String tabItem;
  TabNavigator({required this.navigatorKey, required this.tabItem});

  @override
  Widget build(BuildContext context) {
    Widget child = HomePage();
    if (tabItem == "Community") {
      child = ContactPage();
    } else if (tabItem == "Contacts") {
      child = MyContacts();
    } else if (tabItem == "Home") {
      child = HomePage();
    } else if (tabItem == "Map") {
      child = MyMapOSM2();
    } else if (tabItem == "Profile") {
      child = MyProfile();
    }

    return Navigator(
      key: navigatorKey,
      onGenerateRoute: (routeSettings) {
        return MaterialPageRoute(builder: (context) => child);
      },
    );
  }
}
