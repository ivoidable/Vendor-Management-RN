import 'package:flutter/material.dart';
import 'package:vendor/helper/helper_widgets.dart';
import 'package:vendor/model/event.dart';

class VendorEventsTab extends StatelessWidget {
  final List<Event> events = [];
  //TODO: Fetch Real Event Data

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: ListView.builder(
        padding: const EdgeInsets.all(8.0),
        itemCount: events.length,
        itemBuilder: (context, index) {
          final event = events[index];
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
}

class VendorMessagesTabs extends StatelessWidget {
  const VendorMessagesTabs({super.key});

  @override
  Widget build(BuildContext context) {
    return Text("Messages Tabs");
  }
}

class VendorNotificationsTab extends StatelessWidget {
  const VendorNotificationsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Text("Notifications Tab");
  }
}

class VendorProfileTab extends StatelessWidget {
  const VendorProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Text("Profile Tab");
  }
}
