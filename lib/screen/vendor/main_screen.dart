import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vendor/controller/vendor/main_controller.dart';
import 'package:vendor/screen/vendor/tabs/vendor_tabs.dart';

class VendorMainScreen extends StatelessWidget {
  VendorMainScreen({super.key});

  final VendorMainController controller = Get.put(VendorMainController());

  @override
  Widget build(BuildContext context) {
    var tabs = [
      VendorEventsTab(mainController: controller),
      VendorVendorsTab(mainController: controller),
      VendorNotificationsTab(mainController: controller),
      VendorProfileTab(mainController: controller),
    ];
    return Scaffold(
      body: Obx(() {
        return tabs[controller.selectedIndex.value];
      }),
      bottomNavigationBar: Obx(() {
        return BottomNavigationBar(
          currentIndex: controller.selectedIndex.value,
          onTap: (index) => controller.changeTab(index),
          items: [
            BottomNavigationBarItem(
              icon: Icon(
                Icons.event,
                color: Colors.amber,
              ),
              label: 'Events',
              activeIcon: Icon(
                Icons.event,
                color: Colors.orange,
              ),
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.people,
                color: Colors.amber,
              ),
              label: 'Vendors',
              activeIcon: Icon(
                Icons.people,
                color: Colors.orange,
              ),
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.notifications,
                color: Colors.amber,
              ),
              label: 'Notifications',
              activeIcon: Icon(
                Icons.notifications,
                color: Colors.orange,
              ),
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.person,
                color: Colors.amber,
              ),
              label: 'Profile',
              activeIcon: Icon(
                Icons.person,
                color: Colors.orange,
              ),
            ),
          ],
        );
      }),
    );
  }
}
