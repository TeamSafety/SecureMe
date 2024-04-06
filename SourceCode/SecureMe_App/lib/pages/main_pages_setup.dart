// ignore_for_file: prefer_const_constructors
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:my_app/models/AppVars.dart';
import 'package:my_app/models/tab_navigator.dart';
import 'package:my_app/pages/community_list.dart';
import 'package:my_app/pages/home_page.dart';
import 'package:my_app/pages/map_page.dart';
import 'package:my_app/pages/my_contacts.dart';
import 'package:my_app/pages/my_profile.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  List _pages = [
    ContactPage(),
    MyContacts(),
    HomePage(),
    MyMapOSM2(),
    MyProfile(),
  ];

  String _currentPage = "Home";
  List<String> pageKeys = ["Community", "Contacts", "Home", "Map", "Profile"];
  Map<String, GlobalKey<NavigatorState>> _navigatorKeys = {
    "Community": GlobalKey<NavigatorState>(),
    "Contacts": GlobalKey<NavigatorState>(),
    "Home": GlobalKey<NavigatorState>(),
    "Map": GlobalKey<NavigatorState>(),
    "Profile": GlobalKey<NavigatorState>(),
  };

  int _currentIndex = 2;

  void _selectTab(String tabItem, int index) {
    if (tabItem == _currentPage) {
      _navigatorKeys[tabItem]?.currentState?.popUntil((route) => route.isFirst);
    } else {
      setState(() {
        _currentPage = pageKeys[index];
        _currentIndex = index;
      });
    }
  }

  Widget build(BuildContext context) {
    return SafeArea(
      child: WillPopScope(
        onWillPop: () async {
          final isFirstRouteInCurrentTab =
              await _navigatorKeys[_currentPage]!.currentState!.maybePop();
          if (isFirstRouteInCurrentTab) {
            if (_currentPage != "Home") {
              _selectTab("Home", 2);
              return false;
            }
          }
          // let system handle back button if we're on the first route
          return isFirstRouteInCurrentTab;
        },
        child: Scaffold(
          body: _buildOffstageNavigator(_currentPage),
          // body: Stack(
          //   children: <Widget>[
          //     _buildOffstageNavigator("Community"),
          //     _buildOffstageNavigator("Contacts"),
          //     _buildOffstageNavigator("Home"),
          //     _buildOffstageNavigator("Map"),
          //     _buildOffstageNavigator("Profile"),
          //   ],
          // ),
          bottomNavigationBar: _bottomNavigationBar(),
        ),
      ),
    );
  }

  Widget _buildOffstageNavigator(String tabItem) {
    return TabNavigator(
      navigatorKey: _navigatorKeys[tabItem]!,
      tabItem: tabItem,
    );
  }

  Theme _bottomNavigationBar() {
    return Theme(
      data: ThemeData(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
      ),
      child: Container(
        decoration: const BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Color.fromARGB(40, 47, 44, 35),
              offset: Offset(0, 4),
              blurRadius: 4,
              spreadRadius: 4,
            )
          ],
        ),
        child: SizedBox(
          height: 86,
          child: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            fixedColor: AppVars.accent,
            showUnselectedLabels: true,
            showSelectedLabels: true,
            selectedFontSize: AppVars.smallText,
            unselectedFontSize: AppVars.smallText,
            backgroundColor: AppVars.primary,
            onTap: (int index) {
              _selectTab(pageKeys[index], index);
            },
            currentIndex: _currentIndex,
            elevation: 0,
            items: [
              BottomNavigationBarItem(
                label: 'Community',
                tooltip: "Community Page",
                icon: SvgPicture.asset(
                  'assets/icons/group.svg',
                  width: 30,
                  height: 30,
                  colorFilter: ColorFilter.mode(
                      _currentIndex == 0
                          ? AppVars.accent
                          : AppVars.secondary.withOpacity(0.6),
                      BlendMode.srcIn),
                ),
              ),
              BottomNavigationBarItem(
                label: 'Contacts',
                icon: SvgPicture.asset(
                  'assets/icons/book.svg',
                  width: 30,
                  height: 30,
                  colorFilter: ColorFilter.mode(
                      _currentIndex == 1
                          ? AppVars.accent
                          : AppVars.secondary.withOpacity(0.6),
                      BlendMode.srcIn),
                ),
              ),
              BottomNavigationBarItem(
                label: '',
                icon: Container(
                  decoration: BoxDecoration(
                    color: AppVars.accent,
                    shape: BoxShape.circle,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: SvgPicture.asset(
                      'assets/icons/home.svg',
                      width: 30,
                      height: 30,
                      colorFilter: ColorFilter.mode(
                        AppVars.primary,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ),
              ),
              BottomNavigationBarItem(
                label: 'Map',
                icon: SvgPicture.asset(
                  'assets/icons/map.svg',
                  width: 30,
                  height: 30,
                  colorFilter: ColorFilter.mode(
                      _currentIndex == 3
                          ? AppVars.accent
                          : AppVars.secondary.withOpacity(0.6),
                      BlendMode.srcIn),
                ),
              ),
              BottomNavigationBarItem(
                label: 'Profile',
                icon: SvgPicture.asset(
                  'assets/icons/myprofile.svg',
                  width: 30,
                  height: 30,
                  colorFilter: ColorFilter.mode(
                      _currentIndex == 4
                          ? AppVars.accent
                          : AppVars.secondary.withOpacity(0.6),
                      BlendMode.srcIn),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
