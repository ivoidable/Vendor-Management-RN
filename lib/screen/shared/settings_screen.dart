import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:vendor/controller/auth_controller.dart';
import 'package:vendor/controller/settings_controller.dart';
import 'package:vendor/main.dart';

class SettingsScreen extends StatelessWidget {
  SettingsScreen({super.key});
  final SettingsController controller = Get.put(SettingsController());
  void getData() async {
    var settingsBox = await Hive.openBox('settings');
    if (settingsBox.containsKey('isNotified')) {
      controller.changeIsNotified(settingsBox.get('isNotified') as bool);
    } else {
      settingsBox.put('isNotified', false);
    }
    // if (settingsBox.containsKey('lang')) {
    //   controller.changeLanguage(settingsBox.get('lang') as Locale);
    // } else {
    //   settingsBox.put('lang', const Locale('en', 'us'));
    // }
  }

  @override
  Widget build(BuildContext context) {
    getData();
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        backgroundColor: Get.theme.colorScheme.primary,
      ),
      body: Center(
        child: Container(
          height: Get.height * 0.88,
          width: Get.width * 0.88,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListView(
            children: [
              buildSwitchTile(),
              buildDropdownTile(),
              signOutButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget signOutButton() {
    return ListTile(
      onTap: () {
        authController.signOut();
      },
      leading: Text(
        "Log Out",
        style: TextStyle(fontSize: 18),
      ),
      trailing: const Icon(Icons.logout),
    );
  }

  Widget buildSwitchTile() {
    return ListTile(
      leading: Text(
        "Notifications",
        style: TextStyle(fontSize: 18),
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
        Get.defaultDialog(
          title: "Choose Language",
        );
      },
      leading: Text(
        "Change Language",
        style: TextStyle(fontSize: 18),
      ),
      trailing: const Icon(Icons.arrow_drop_down),
    );
  }
}
