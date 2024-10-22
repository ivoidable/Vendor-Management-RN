import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vendor/controller/organizer/main_controller.dart';

class OrganizerMainScreen extends StatelessWidget {
  const OrganizerMainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Events & Bazaars'),
        centerTitle: true,
      ),
      body: Obx(() {
        final controller = Get.find<OrganizerMainController>();
        return controller.tabs[controller.selectedIndex.value];
      }),
      bottomNavigationBar: Obx(() {
        final controller = Get.find<OrganizerMainController>();
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
