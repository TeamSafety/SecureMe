import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:my_app/models/AppColors.dart';
import 'package:my_app/pages/contacts_list.dart';
import 'package:my_app/pages/home_page.dart';
import 'package:my_app/pages/map_page.dart';
import 'package:my_app/pages/my_contacts.dart';
import 'package:my_app/pages/my_profile.dart';
import 'package:my_app/pages/osm_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  List pages = [
    ContactsPage(),
    MyContacts(),
    HomePage(),
    MyMapOSM(),
    MyProfile(),  
  ];

  int _currentIndex = 2;
  void onTap(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: pages[_currentIndex],
        backgroundColor: AppColors.primary,
        bottomNavigationBar: _bottomNavigationBar(),
      ),
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
          height: 65,
          child: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            backgroundColor: AppColors.primary,
            onTap: onTap,
            unselectedFontSize: 0,
            selectedFontSize: 0,
            currentIndex: _currentIndex,
            showSelectedLabels: false,
            showUnselectedLabels: false,
            enableFeedback: false,
            elevation: 0,
            items: [
              BottomNavigationBarItem(
                label: 'Group',
                icon: Container(
                  child: SvgPicture.asset(
                    'assets/icons/group.svg',
                    width: 30,
                    height: 30,
                    colorFilter: ColorFilter.mode(
                        _currentIndex == 0
                            ? AppColors.accent
                            : AppColors.secondary.withOpacity(0.6),
                        BlendMode.srcIn),
                  ),
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
                          ? AppColors.accent
                          : AppColors.secondary.withOpacity(0.6),
                      BlendMode.srcIn),
                ),
              ),
              BottomNavigationBarItem(
                label: 'Home',
                icon: Container(
                  decoration: BoxDecoration(
                      color: AppColors.accent, shape: BoxShape.circle),
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: SvgPicture.asset(
                      'assets/icons/home.svg',
                      width: 30,
                      height: 30,
                      colorFilter: ColorFilter.mode(
                        AppColors.primary,
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
                          ? AppColors.accent
                          : AppColors.secondary.withOpacity(0.6),
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
                          ? AppColors.accent
                          : AppColors.secondary.withOpacity(0.6),
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
