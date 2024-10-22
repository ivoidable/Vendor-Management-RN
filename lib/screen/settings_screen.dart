import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vendor/controller/user_controller.dart';
import 'package:vendor/screen/settings_controller.dart';

class SettingsScreen extends StatelessWidget {
  SettingsScreen({super.key});
  final SettingsController controller = Get.put(SettingsController());
  void getData() {
    //TODO: Set Language & isNotified
  }

  @override
  Widget build(BuildContext context) {
    getData();
    return Scaffold(
      body: ListView(
        scrollDirection: Axis.vertical,
        children: [
          buildSwitchTile(),
          // buildDropdownTile(),
          signOutButton(),
        ],
      ),
    );
  }

  Widget signOutButton() {
    return ListTile(
      onTap: () {
        AuthController().signOut();
      },
      leading: const Row(
        children: [
          Icon(Icons.language),
          Text("Sign out"),
        ],
      ),
      trailing: const Icon(Icons.logout),
    );
  }

  Widget buildSwitchTile() {
    return ListTile(
      leading: const Row(
        children: [
          Icon(Icons.language),
          Text("Enable Notifications"),
        ],
      ),
      trailing: Obx(
        () => Switch.adaptive(
          value: controller.isNotified.value,
          onChanged: (newValue) {
            controller.isNotified.value = newValue;
          },
        ),
      ),
    );
  }

  Widget buildDropdownTile() {
    return ListTile(
      onTap: () {
        //TODO: Show language change pop up and then restart app
      },
      leading: const Row(
        children: [
          Icon(Icons.language),
          Text("Change Language"),
        ],
      ),
      trailing: const Icon(Icons.arrow_drop_down),
    );
  }
}
