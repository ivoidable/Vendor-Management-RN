import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:vendor/controller/organizer/main_controller.dart';
import 'package:vendor/helper/database.dart';
import 'package:vendor/helper/helper_widgets.dart';
import 'package:vendor/main.dart';
import 'package:vendor/model/user.dart';
import 'package:vendor/screen/organizer/events/schedule_event_screen.dart';
import 'package:vendor/screen/organizer/events/view_event_screen.dart';
import 'package:vendor/screen/organizer/profile/edit_profile_screen.dart';
import 'package:vendor/screen/organizer/vendor/view_profile_screen.dart';
import 'package:vendor/screen/shared/settings_screen.dart';

class OrganizerEventsTab extends StatelessWidget {
  final OrganizerMainController mainController =
      Get.find<OrganizerMainController>();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Stack(
        children: [
          Obx(() {
            return RefreshIndicator(
                onRefresh: mainController.onRefresh,
                child: ListView.builder(
                  padding: const EdgeInsets.all(8.0),
                  itemCount: mainController.events.value.length,
                  itemBuilder: (context, index) {
                    final event = mainController.events[index];
                    return EventCard(
                      name: event.name,
                      images: event.images,
                      vendors: event.registeredVendors.length,
                      maxVendors: event.maxVendors,
                      onClick: () {
                        Get.to(ViewEventScreen(event: event));
                      },
                    );
                  },
                ));
          }),
          Positioned(
            bottom: 10,
            right: 10,
            child: FloatingActionButton(
              backgroundColor: Colors.amber,
              foregroundColor: Colors.blueGrey,
              onPressed: () {
                Get.to(ScheduleEventScreen());
              },
              child: Icon(Icons.add),
            ),
          ),
        ],
      ),
    );
  }
}

class OrganizerVendorsTab extends StatelessWidget {
  final OrganizerMainController mainController =
      Get.find<OrganizerMainController>();
  OrganizerVendorsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: mainController.getVendors(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text(snapshot.error.toString()),
          );
        } else {
          return Obx(
            () => RefreshIndicator(
              onRefresh: mainController.onRefresh,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: ListView.builder(
                  padding: const EdgeInsets.all(8.0),
                  itemCount: mainController.vendors.length,
                  itemBuilder: (context, index) {
                    final vendor = mainController.vendors[index];
                    return VendorCard(
                      vendor: mainController.vendors[index],
                      onClick: () {
                        Get.to(ViewVendorProfileScreen(vendor: vendor));
                        print('Clicked on ${vendor.name}');
                      },
                    );
                  },
                ),
              ),
            ),
          );
        }
      },
    );
  }
}

class OrganizerNotificationsTab extends StatelessWidget {
  OrganizerNotificationsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(child: Text("Notifications Do not work yet"));
  }
}

class OrganizerProfileTab extends StatelessWidget {
  OrganizerProfileTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Helper function to format the date
    String formatDate(DateTime date) {
      return DateFormat.yMMMd().format(date);
    }

    return Scaffold(
      body: FutureBuilder(
        future: DatabaseService().getUser(authController.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          Organizer user =
              Organizer.fromMap(snapshot.data!.id, snapshot.data!.data()!);
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Name
                ListTile(
                  leading: Icon(Icons.person),
                  title: Text("Name"),
                  subtitle: Text(user.name),
                ),
                // Date of Birth
                ListTile(
                  leading: Icon(Icons.cake),
                  title: Text("Date of Birth"),
                  subtitle: Text(formatDate(user.dateOfBirth)),
                ),
                // Email (Placeholder - assuming email is part of AppUser data later)
                ListTile(
                  leading: Icon(Icons.email),
                  title: Text("Email"),
                  subtitle: Text(user.email), // Placeholder
                ),
                // Phone Number (Placeholder)
                ListTile(
                  leading: Icon(Icons.phone),
                  title: Text("Phone Number"),
                  subtitle: Text(user.phoneNumber == ""
                      ? "No number set"
                      : user.phoneNumber ?? "No number set"), // Placeholder
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    minimumSize: Size(Get.width / 2, Get.height * 0.05),
                    backgroundColor: Colors.amber,
                    foregroundColor: Colors.blueGrey[700],
                  ),
                  onPressed: () {
                    Get.to(OrganizerEditProfileScreen(
                      organizer: user,
                    ));
                  },
                  icon: Icon(Icons.edit),
                  label: Text("Edit Profile"),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
