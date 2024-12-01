import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vendor/controller/vendor/view_organizer_controller.dart';
import 'package:vendor/helper/database.dart';
import 'package:vendor/model/review.dart';
import 'package:vendor/model/user.dart';

class OrganizerDetailsTab extends StatelessWidget {
  final controller = Get.find<ViewOrganizerController>();
  OrganizerDetailsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Get.theme.colorScheme.primary,
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
            ElevatedButton(
              onPressed: () {
                Get.dialog(
                  AlertDialog(
                    title: Text('Enter Data'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Obx(
                          () {
                            return controller.image.value == null
                                ? IconButton(
                                    icon: Icon(Icons.image, size: 50),
                                    onPressed: controller.pickImage,
                                  )
                                : Image.file(
                                    File(controller.image.value!.path),
                                    width: 100,
                                    height: 100,
                                  );
                          },
                        ),
                        TextField(
                          onChanged: controller.updateText,
                          decoration: InputDecoration(labelText: 'Details'),
                        ),
                        SizedBox(height: 24),
                        buildRatingWidget(),
                      ],
                    ),
                    actions: [
                      TextButton(
                        child: Text('Submit'),
                        onPressed: controller.submitData,
                      ),
                      TextButton(
                        child: Text('Cancel'),
                        onPressed: () {
                          controller.textInput.value = '';
                          controller.image.value = null;
                          Get.back();
                        },
                      ),
                    ],
                  ),
                );
              },
              child: Text("Review"),
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                minimumSize: Size(Get.width / 4, Get.height * 0.05),
                backgroundColor: Colors.blueGrey[700],
                foregroundColor: Get.theme.colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildRatingWidget() {
    return Obx(
      () => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(5, (index) {
          return IconButton(
            icon: Icon(
              Icons.star,
              color:
                  index < controller.rating.value ? Get.theme.colorScheme.primary : Colors.grey,
            ),
            onPressed: () {
              controller.updateRating(index + 1);
            },
          );
        }),
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
        backgroundColor: Get.theme.colorScheme.primary,
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
        title: const Text('Registered Vendors'),
        centerTitle: true,
        backgroundColor: Get.theme.colorScheme.primary,
      ),
      body: FutureBuilder(
        future: DatabaseService().getOrganizerFeedback(controller.organizer.id),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(
                snapshot.error.toString(),
              ),
            );
          } else if (!snapshot.hasData) {
            return Text(snapshot.error.toString());
          } else {
            List<Review> reviews = snapshot.data!;
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Container(
                  height: Get.height * 0.85,
                  width: Get.width * 0.85,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.grey[300],
                  ),
                  child: ListView.builder(
                    itemBuilder: (context, index) {
                      return ReviewWidget(review: reviews[index]);
                    },
                    itemCount: snapshot.data!.length,
                  ),
                ),
              ),
            );
          }
        },
      ),
    );
  }
}

class ReviewWidget extends StatelessWidget {
  final Review review;

  const ReviewWidget({Key? key, required this.review}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: DatabaseService().getUser(review.reviewerId),
      builder: (context, snapshot) {
        final Vendor vendor =
            Vendor.fromMap(review.reviewerId, snapshot.data!.data()!);
        return Card(
          margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundImage: NetworkImage(vendor.logoUrl),
                    ),
                    SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          vendor.name,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Row(
                          children: List.generate(5, (index) {
                            return Icon(
                              Icons.star,
                              color: index < review.rating
                                  ? Get.theme.colorScheme.primary
                                  : Colors.grey,
                              size: 18,
                            );
                          }),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  review.review,
                  style: TextStyle(fontSize: 14, color: Colors.black87),
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(review.imagesUrls.first, fit: BoxFit.cover),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
