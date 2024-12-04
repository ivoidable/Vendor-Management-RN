import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:vendor/controller/vendor/main_controller.dart';
import 'package:vendor/helper/database.dart';
import 'package:vendor/helper/helper_widgets.dart';
import 'package:vendor/main.dart';
import 'package:vendor/model/event.dart';
import 'package:vendor/model/user.dart';
import 'package:vendor/screen/vendor/events/view_event_screen.dart';
import 'package:vendor/screen/vendor/profile/add_product_screen.dart';
import 'package:vendor/screen/vendor/profile/calendar_screen.dart';
import 'package:vendor/screen/vendor/profile/edit_profile_screen.dart';
import 'package:vendor/screen/vendor/vendor/view_vendor_from_vendor_screen.dart';

class VendorEventsTab extends StatelessWidget {
  final VendorMainController mainController;
  VendorEventsTab({required this.mainController});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: mainController.getEvents(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text(snapshot.error.toString()),
          );
        } else {
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Obx(() {
              return RefreshIndicator(
                  onRefresh: mainController.onRefresh,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(8.0),
                    itemCount: mainController.events.length,
                    itemBuilder: (context, index) {
                      final event = mainController.events[index];
                      return EventCard(
                        event: event,
                        onTap: () async {
                          var res = await DatabaseService().getApplication(authController.uid, event.id);
                          Get.to(VendorViewEventScreen(event: event, app: res));
                        },
                      );
                    },
                  ));
            }),
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
        if (snapshot.hasError) {
          return Center(
            child: Text(snapshot.error.toString()),
          );
        } else {
          List<Vendor> vendor = mainController.vendors;
          return RefreshIndicator(
            onRefresh: mainController.onRefresh,
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Obx(
                () {
                  return ListView.builder(
                    padding: const EdgeInsets.all(8.0),
                    itemCount: mainController.vendors.length,
                    itemBuilder: (context, index) {
                      return Card(); //TODO: Remove This too
                    },
                  );
                },
              ),
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
    return const Center(child: Text("To be implemented"));
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
        child: (imageUrl.isEmpty) ? const Icon(Icons.person, size: 50) : null,
      );
    }

    return Scaffold(
      body: FutureBuilder(
        future: DatabaseService().getUser(authController.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          Vendor user =
              Vendor.fromMap(snapshot.data!.id, snapshot.data!.data()!);
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Edit Profile Button
                buildProfileImage(user),
                const SizedBox(
                  height: 24,
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    minimumSize: Size(Get.width / 2, Get.height * 0.05),
                    backgroundColor: Get.theme.colorScheme.primary,
                    foregroundColor: Colors.blueGrey[700],
                  ),
                  onPressed: () {
                    Get.to(EditProfileScreen(
                      vendor: Vendor.fromMap(
                          authController.uid, authController.appUser),
                    ));
                  },
                  icon: const Icon(Icons.edit),
                  label: const Text("Edit Profile"),
                ),
                const SizedBox(height: 24),
                // Name
                ListTile(
                  leading: const Icon(Icons.person),
                  title: const Text("Name"),
                  subtitle: Text(user.name),
                ),

                // Date of Birth
                ListTile(
                  leading: const Icon(Icons.cake),
                  title: const Text("Date of Birth"),
                  subtitle: Text(formatDate(user.dateOfBirth)),
                ),

                // Email (Placeholder - assuming email is part of AppUser data later)
                ListTile(
                  leading: const Icon(Icons.email),
                  title: const Text("Email"),
                  subtitle: Text(user.email), // Placeholder
                ),

                // Phone Number
                ListTile(
                  leading: const Icon(Icons.phone),
                  title: const Text("Phone Number"),
                  subtitle: Text(user.phoneNumber == ""
                      ? "No number set"
                      : user.phoneNumber ?? "No number set"),
                ),
                ListTile(
                  leading: const Icon(Icons.history),
                  title: const Text("History"),
                  onTap: () {
                    Get.to(() => VendorEventHistoryScreen());
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.calendar_month),
                  title: const Text("Calendar"),
                  onTap: () {
                    Get.to(() => VendorCalendarScreen());
                  },
                ),
                ListTile(
                  leading: const Icon(
                    Icons.shop,
                  ),
                  title: const Text("Products"),
                  trailing: IconButton(
                    onPressed: () {
                      Get.to(AddProductScreen());
                    },
                    icon: const Icon(Icons.add),
                  ),
                ),
                CatalogView(vendor: user),
              ],
            ),
          );
        },
      ),
    );
  }
}

class VendorEventHistoryScreen extends StatelessWidget {
  const VendorEventHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Event History'),
        centerTitle: true,
        backgroundColor: Get.theme.colorScheme.primary,
      ),
      body: FutureBuilder(
        future:
            DatabaseService().getAllRegisteredEventsHistory(authController.uid),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          } else {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            if (!snapshot.hasData) return const Center(child: Text("No Events"));
            List<Event> events = snapshot.data!;
            return Padding(
              padding: const EdgeInsets.all(12.0),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.grey[300],
                ),
                child: ListView.builder(
                  itemBuilder: (context, index) {
                    return EventCard(
                      event: events[index],
                    );
                  },
                  itemCount: events.length,
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
