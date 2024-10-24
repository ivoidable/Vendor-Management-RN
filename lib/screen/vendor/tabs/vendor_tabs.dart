import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:vendor/controller/vendor/main_controller.dart';
import 'package:vendor/helper/database.dart';
import 'package:vendor/helper/helper_widgets.dart';
import 'package:vendor/main.dart';
import 'package:vendor/model/user.dart';
import 'package:vendor/screen/shared/settings_screen.dart';

class VendorEventsTab extends StatelessWidget {
  final VendorMainController mainController;
  VendorEventsTab({required this.mainController});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: mainController.getEvents(),
      builder: (context, snapshot) {
        if (mainController.events.isEmpty) {
          return Center(
            child: ElevatedButton(
              onPressed: () => authController.signOut(),
              child: Text("Sign out"),
            ),
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
                    // Handle click event
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

class VendorVendorsTab extends StatelessWidget {
  final VendorMainController mainController;
  VendorVendorsTab({required this.mainController});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: mainController.getVendors(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
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
                    // Handle click event
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

class VendorNotificationsTab extends StatelessWidget {
  final VendorMainController mainController;
  VendorNotificationsTab({required this.mainController});

  @override
  Widget build(BuildContext context) {
    return Text("Notifications Do not work yet");
  }
}

class VendorProfileTab extends StatelessWidget {
  final VendorMainController mainController;
  VendorProfileTab({required this.mainController});

  @override
  Widget build(BuildContext context) {
    // Helper function to format the date
    String formatDate(DateTime date) {
      return DateFormat.yMMMd().format(date);
    }

    // Determine the profile image (logo for Vendor, placeholder for others)
    Widget buildProfileImage(Vendor user) {
      String? imageUrl;
      imageUrl = user.logoUrl;

      return CircleAvatar(
        radius: 50,
        backgroundImage: (imageUrl.isNotEmpty) ? NetworkImage(imageUrl) : null,
        child: (imageUrl.isEmpty) ? Icon(Icons.person, size: 50) : null,
      );
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
            future: DatabaseService().getUser(authController.uid),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                print(snapshot.error.toString());
                return Center(
                  child: Text(snapshot.error.toString()),
                );
              }
              if (!snapshot.hasData) {
                return Center(
                  child: Text("Couldn't Get Data"),
                );
              }
              debugPrint(snapshot.data.toString());
              Vendor user =
                  Vendor.fromMap(authController.uid, snapshot.data!.data()!);
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Profile Image
                    Center(
                      child: buildProfileImage(user),
                    ),
                    const SizedBox(height: 10),

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
                      subtitle: Text(user.phoneNumber ?? ""), // Placeholder
                    ),
                  ],
                ),
              );
            }));
  }
}
