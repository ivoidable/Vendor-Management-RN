import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vendor/controller/vendor/main_controller.dart';
import 'package:vendor/helper/helper_widgets.dart';

class VendorEventsTab extends StatelessWidget {
  final MainController mainController = Get.find<MainController>();
  //TODO: Fetch Real Event Data

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(8.0),
      itemCount: mainController.events.length,
      itemBuilder: (context, index) {
        final event = mainController.events[index];
        return EventCard(
          name: event.name,
          imageUrl: event.imageUrl,
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
