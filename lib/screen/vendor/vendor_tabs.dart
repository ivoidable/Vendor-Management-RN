import 'package:flutter/material.dart';
import 'package:vendor/helper/helper_widgets.dart';

class VendorEventsTab extends StatelessWidget {
  final List<Map<String, dynamic>> events = [
    {
      'name': 'Food Festival',
      'image': 'https://via.placeholder.com/150',
      'vendors': 12,
      'maxVendors': 20,
    },
    {
      'name': 'Tech Expo',
      'image': 'https://via.placeholder.com/150',
      'vendors': 8,
      'maxVendors': 15,
    },
  ];
  //TODO: Fetch Real Event Data

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(8.0),
      itemCount: events.length,
      itemBuilder: (context, index) {
        final event = events[index];
        return EventCard(
          name: event['name'],
          imageUrl: event['image'],
          vendors: event['vendors'],
          maxVendors: event['maxVendors'],
          onClick: () {
            // Handle click event
            print('Clicked on ${event['name']}');
          },
        );
      },
    );
  }
}
