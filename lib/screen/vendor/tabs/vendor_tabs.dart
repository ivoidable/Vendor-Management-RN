import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vendor/controller/vendor/main_controller.dart';
import 'package:vendor/helper/helper_widgets.dart';

class VendorEventsTab extends StatelessWidget {
  final VendorMainController mainController = Get.find<VendorMainController>();
  //TODO: Fetch Real Event Data

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: mainController.getEvents(),
      builder: (context, snapshot) {
        if (mainController.events.isEmpty) {
          return Center(
            child: Text("No Available Events"),
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
  final VendorMainController mainController = Get.find<VendorMainController>();
  VendorVendorsTab({super.key});

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
  const VendorNotificationsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Text("Notifications Do not work yet");
  }
}

class VendorProfileTab extends StatelessWidget {
  const VendorProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Text("Profile Tab");
  }
}
