import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
        title: const Text('Events & Bazaars'),
        centerTitle: true,
      ),
      body: Obx(() {
        return tabs[controller.selectedIndex.value];
      }),
      bottomNavigationBar: Obx(() {
        return BottomNavigationBar(
          currentIndex: controller.selectedIndex.value,
          onTap: (index) => controller.changeTab(index),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.event),
              label: 'Events',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.people),
              label: 'Vendors',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.notifications),
              label: 'Notifications',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        );
      }),
    );
  }
}
