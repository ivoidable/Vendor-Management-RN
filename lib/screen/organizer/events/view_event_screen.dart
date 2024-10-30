import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:vendor/controller/organizer/event_controller.dart';
import 'package:vendor/model/event.dart';
import 'package:vendor/screen/organizer/events/event_tabs.dart';

class ViewEventScreen extends StatelessWidget {
  final Event event;
  ViewEventScreen({required this.event});

  @override
  Widget build(BuildContext context) {
    EventController eventController = Get.put(EventController());
    var tabs = [
      ViewEventDetailsTab(event: event),
      ViewApplicationsScreen(event: event),
      ViewRegisteredVendorsScreen(event: event),
    ];
    return Scaffold(
      body: Obx(
        () => IndexedStack(
          index: eventController.selectedIndex.value,
          children: tabs,
        ),
      ),
      bottomNavigationBar: GNav(
        rippleColor: Colors.amber[500]!,
        hoverColor: Colors.grey[100]!,
        gap: 8,
        activeColor: Colors.blueGrey[700]!,
        iconSize: 24,
        tabBorderRadius: 8,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
        duration: const Duration(milliseconds: 200),
        tabBackgroundColor: Colors.grey[100]!,
        color: Colors.black,
        onTabChange: (index) => eventController.selectedIndex.value = index,
        tabs: const [
          GButton(
            icon: Icons.home,
            text: 'Details',
          ),
          GButton(
            icon: Icons.send,
            text: 'Applications',
          ),
          GButton(
            icon: Icons.list_alt,
            text: 'Registered',
          ),
        ],
      ),
    );
  }
}
