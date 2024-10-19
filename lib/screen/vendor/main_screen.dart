import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vendor/controller/vendor/main_controller.dart';

class VendorMainScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Events & Bazaars'),
        centerTitle: true,
      ),
      body: Obx(() {
        final controller = Get.find<MainController>();
        return controller.tabs[controller.selectedIndex.value];
      }),
      bottomNavigationBar: Obx(() {
        final controller = Get.find<MainController>();
        return BottomNavigationBar(
          currentIndex: controller.selectedIndex.value,
          onTap: (index) => controller.changeTab(index),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.event),
              label: 'Events',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.message),
              label: 'Messages',
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
