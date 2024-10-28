import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:vendor/controller/vendor/main_controller.dart';
import 'package:vendor/helper/database.dart';
import 'package:vendor/helper/helper_widgets.dart';
import 'package:vendor/main.dart';
import 'package:vendor/model/user.dart';
import 'package:vendor/screen/vendor/profile/add_product_screen.dart';
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
                        name: event.name,
                        images: event.images,
                        vendors: event.registeredVendors.length,
                        maxVendors: event.maxVendors,
                        onClick: () {
                          //TODO: Navigate to Event Screen
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
                      return VendorCard(
                        vendor: vendor[index],
                        onClick: () {
                          Get.to(ViewVendorVendorProfileScreen(
                            vendor: vendor[index],
                          ));
                          print('Clicked on ${mainController.vendors[index]}');
                        },
                      );
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
                    backgroundColor: Colors.amber,
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
                  leading: const Icon(
                    Icons.shop,
                  ),
                  title: const Text("Products"),
                  trailing: IconButton(
                    onPressed: () {
                      //TODO: Add Product Here
                      Get.to(AddProductScreen());
                      print("Add Product");
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
