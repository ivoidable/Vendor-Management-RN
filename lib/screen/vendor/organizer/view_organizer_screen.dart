import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:vendor/controller/vendor/view_organizer_controller.dart';
import 'package:vendor/model/user.dart';
import 'package:vendor/screen/vendor/organizer/organizer_profile_tabs.dart';

class ViewOrganizerScreen extends StatelessWidget {
  final Organizer organizer;
  final String eventId;
  ViewOrganizerScreen({
    required this.organizer,
    required this.eventId,
  });

  @override
  Widget build(BuildContext context) {
    var controller = Get.put(ViewOrganizerController(
      organizer: organizer,
      eventId: eventId,
    ));
    var tabs = [
      OrganizerDetailsTab(),
      OrganizerEventsTab(),
      OrganizerFeedbackTab(),
    ];
    return Scaffold(
      body: Obx(
        () => IndexedStack(
          children: tabs,
          index: controller.index.value,
        ),
      ),
      bottomNavigationBar: GNav(
        rippleColor: Colors.amber[500]!,
        hoverColor: Colors.grey[100]!,
        gap: 8,
        activeColor: Colors.blueGrey[700]!,
        iconSize: 24,
        tabBorderRadius: 8,
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 18),
        duration: Duration(milliseconds: 200),
        tabBackgroundColor: Colors.grey[100]!,
        color: Colors.black,
        onTabChange: (index) => controller.index.value = index,
        tabs: const [
          GButton(
            icon: Icons.person_outline,
            text: 'Profile',
          ),
          GButton(
            icon: Icons.event,
            text: 'Events',
          ),
          GButton(
            icon: Icons.feedback_outlined,
            text: 'Feedback',
          ),
        ],
      ),
    );
  }
}
