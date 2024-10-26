import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:vendor/controller/organizer/main_controller.dart';
import 'package:vendor/screen/organizer/tabs/organizer_tabs.dart';

class OrganizerMainScreen extends StatelessWidget {
  OrganizerMainScreen({super.key});
  final OrganizerMainController controller = Get.put(OrganizerMainController());

  @override
  Widget build(BuildContext context) {
    var tabs = [
      OrganizerEventsTab(),
      OrganizerVendorsTab(),
      OrganizerNotificationsTab(),
      OrganizerProfileTab(),
    ];
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Events & Bazaars',
          style: TextStyle(
            color: Colors.blueGrey,
          ),
        ),
        backgroundColor: Colors.amber,
        centerTitle: true,
      ),
      body: Obx(() {
        return tabs[controller.selectedIndex.value];
      }),
      bottomNavigationBar: Obx(() {
        return GNav(
          rippleColor: Colors.amber[500]!,
          hoverColor: Colors.grey[100]!,
          gap: 8,
          activeColor: Colors.blueGrey[700]!,
          iconSize: 24,
          tabBorderRadius: 8,
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 18),
          duration: Duration(milliseconds: 200),
          tabBackgroundColor: Colors.grey[100]!,
          color: Colors.black,
          onTabChange: (index) => controller.selectedIndex.value = index,
          tabs: const [
            GButton(
              icon: Icons.home,
              text: 'Home',
            ),
            GButton(
              icon: Icons.people,
              text: 'Vendor',
            ),
            GButton(
              icon: Icons.notifications,
              text: 'Notifications',
            ),
            GButton(
              icon: Icons.person,
              text: 'Profile',
            )
          ],
        );
        // return BottomNavigationBar(
        //   currentIndex: controller.selectedIndex.value,
        //   onTap: (index) => controller.changeTab(index),
        //   items: [
        //     BottomNavigationBarItem(
        //       icon: Icon(Icons.event),
        //       label: 'Events',
        //     ),
        //     BottomNavigationBarItem(
        //       icon: Icon(Icons.people),
        //       label: 'Vendors',
        //     ),
        //     BottomNavigationBarItem(
        //       icon: Icon(Icons.notifications),
        //       label: 'Notifications',
        //     ),
        //     BottomNavigationBarItem(
        //       icon: Icon(Icons.person),
        //       label: 'Profile',
        //     ),
        //   ],
        // );
      }),
    );
  }
}
