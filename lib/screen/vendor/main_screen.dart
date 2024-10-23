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
