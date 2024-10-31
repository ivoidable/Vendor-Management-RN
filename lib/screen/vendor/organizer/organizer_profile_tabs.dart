import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vendor/controller/vendor/view_organizer_controller.dart';

class OrganizerDetailsTab extends StatelessWidget {
  final controller = Get.find<ViewOrganizerController>();
  OrganizerDetailsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.amber,
        title: Text(controller.organizer.name),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          children: [
            const SizedBox(
              height: 24,
            ),
            // buildProfileImage(organizer),
            const SizedBox(
              height: 16,
            ),
            Text(
              "${controller.organizer.name}",
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(
              height: 12,
            ),
            ElevatedButton(
              onPressed: () {
                //TODO: Implement Review Logic
                Get.defaultDialog(
                  title: 'Review',
                  textConfirm: "Submit",
                  textCancel: "Cancel",
                  onConfirm: () {},
                  onCancel: () {},
                );
              },
              child: Text("Review"),
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                minimumSize: Size(Get.width / 4, Get.height * 0.05),
                backgroundColor: Colors.blueGrey[700],
                foregroundColor: Colors.amber,
              ),
            ),
            const SizedBox(
              height: 12,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(controller.organizer.email),
                controller.organizer.phoneNumber == null
                    ? const SizedBox(
                        height: 12,
                      )
                    : TextButton(
                        onPressed: () {
                          if (controller.organizer.phoneNumber != null) {
                            launchUrl(Uri.parse(
                                "tel:${controller.organizer.phoneNumber!}"));
                          }
                        },
                        child: Text(controller.organizer.phoneNumber!),
                      ),
              ],
            ),
            const SizedBox(
              height: 12,
            ),
          ],
        ),
      ),
    );
  }
}

class OrganizerEventsTab extends StatelessWidget {
  final controller = Get.find<ViewOrganizerController>();
  OrganizerEventsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.amber,
        title: Text(controller.organizer.name),
        centerTitle: true,
      ),
      body: Center(child: Text("To be implemented")),
    );
  }
}

class OrganizerFeedbackTab extends StatelessWidget {
  final controller = Get.find<ViewOrganizerController>();
  OrganizerFeedbackTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.amber,
        title: Text(controller.organizer.name),
        centerTitle: true,
      ),
      body: Center(child: Text("To be implemented")),
    );
  }
}
