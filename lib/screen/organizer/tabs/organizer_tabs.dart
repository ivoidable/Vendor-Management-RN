import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:vendor/controller/organizer/main_controller.dart';
import 'package:vendor/controller/auth_controller.dart';
import 'package:vendor/helper/database.dart';
import 'package:vendor/helper/helper_widgets.dart';
import 'package:vendor/model/user.dart';
import 'package:vendor/screen/organizer/events/schedule_event_screen.dart';
import 'package:vendor/screen/shared/settings_screen.dart';

class OrganizerEventsTab extends StatelessWidget {
  final OrganizerMainController mainController =
      Get.find<OrganizerMainController>();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: mainController.getScheduledEvents(
          DatabaseService().getUser(AuthController().firebaseUser.value!.uid)
              as Future<Organizer>),
      builder: (context, snapshot) {
        if (mainController.events.isEmpty) {
          return Center(
            child: Text("No Scheduled Events"),
          );
        } else if (snapshot.hasError) {
          return Center(
            child: Text(snapshot.error.toString()),
          );
        } else {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Stack(
              children: [
                ListView.builder(
                  padding: const EdgeInsets.all(8.0),
                  itemCount: mainController.events.length,
                  itemBuilder: (context, index) {
                    final event = mainController.events[index];
                    return EventCard(
                      name: event.name,
                      imageUrl: event.imageUrl,
                      vendors: event.registeredVendors.length,
                      maxVendors: event.maxVendors,
                      onClick: () {
                        // Handle click event
                        print('Clicked on ${event.name}');
                      },
                    );
                  },
                ),
                Positioned(
                  bottom: 50,
                  left: 25,
                  child: FloatingActionButton(
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
      },
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
        if (!snapshot.hasData) {
          return const Center(
            child: Text("No Vendors Found"),
          );
        } else if (snapshot.hasError) {
          return Center(
            child: Text(snapshot.error.toString()),
          );
        } else {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: mainController.events.length,
              itemBuilder: (context, index) {
                final event = mainController.events[index];
                return EventCard(
                  name: event.name,
                  imageUrl: event.imageUrl,
                  vendors: event.registeredVendors.length,
                  maxVendors: event.maxVendors,
                  onClick: () {
                    //TODO: Get.to(ViewVendorProfile());
                    print('Clicked on ${event.name}');
                  },
                );
              },
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
    return Text("Notifications Do not work yet");
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
      appBar: AppBar(
        title: const Text("Profile"),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Get.to(SettingsScreen());
            },
          ),
        ],
      ),
      body: FutureBuilder(
        future:
            DatabaseService().getUser(AuthController().firebaseUser.value!.uid),
        builder: (context, snapshot) {
          Organizer user = snapshot.data as Organizer;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Edit Profile Button
                ElevatedButton.icon(
                  onPressed: () {
                    //TODO: Get.to(EditProfileScreen());
                  },
                  icon: Icon(Icons.edit),
                  label: Text("Edit Profile"),
                ),
                const SizedBox(height: 20),

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

                // Role
                ListTile(
                  leading: Icon(Icons.work),
                  title: Text("Role"),
                  subtitle: Text(user.role),
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
                  subtitle:
                      Text(user.phoneNumber ?? "No number set"), // Placeholder
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
