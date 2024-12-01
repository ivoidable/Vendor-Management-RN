import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:vendor/controller/vendor/view_event_controller.dart';
import 'package:vendor/helper/database.dart';
import 'package:vendor/main.dart';
import 'package:vendor/model/event.dart';
import 'package:vendor/model/user.dart';
import 'package:vendor/screen/vendor/events/vendor_application_screen.dart';
import 'package:vendor/screen/vendor/organizer/view_organizer_screen.dart';

class VendorViewEventScreen extends StatelessWidget {
  final Event event;
  final Application? app;

  VendorViewEventScreen({required this.event, required this.app});

  @override
  Widget build(BuildContext context) {
    var controller = Get.put(ViewEventController(Rx<Event>(event), app));
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Get.theme.colorScheme.primary,
        centerTitle: true,
        title: Text('Event: ${event.name}'),
      ),
      body: StreamBuilder<Event?>(
        stream: DatabaseService().getRegisteredVendorsStream(event.id),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text(snapshot.error.toString());
          } else {
            controller.event = snapshot.data!.obs;
            if (controller.event != null && controller.event.value != null) {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      height: 150,
                      width: double.infinity,
                      child: CarouselView(
                        itemExtent: 150,
                        children: [
                          for (var image in controller.event.value.images)
                            Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: Image.network(
                                image,
                                width: 150,
                                height: 150,
                                fit: BoxFit.cover,
                              ),
                            ),
                        ],
                      ),
                    ),
                    Text(
                      controller.event.value.name,
                      style: const TextStyle(
                          fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      controller.event.value.description,
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () async {
                        var organizer = Organizer.fromMap(
                            event.organizerId,
                            (await DatabaseService()
                                    .getUser(event.organizerId))!
                                .data()!);
                        Get.to(ViewOrganizerScreen(
                          organizer: organizer,
                          eventId: event.id,
                        ));
                      },
                      child: Text(
                        'Organized by ${controller.event.value.organizerName}',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'Vendor Fee: \$${controller.event.value.vendorFee.toStringAsFixed(2)}',
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w500),
                        ),
                        Text(
                          'User Fee: \$${controller.event.value.attendeeFee.toStringAsFixed(2)}',
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '${controller.event.value.appliedVendorsId.length.toString()}/${controller.event.value.maxVendors.toString()} vendors applied',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w400),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Starts on ${DateFormat.yMMMMd().add_jm().format(controller.event.value.startDate)}',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w400),
                    ),
                    Text(
                      'Ends on ${DateFormat.yMMMMd().add_jm().format(controller.event.value.endDate)}',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w400),
                    ),
                    const SizedBox(height: 16),
                    buildApplyWidget(controller),
                    TextButton(
                      onPressed: () {
                        //TODO: Launch Google Maps with url with latlng
                        launchUrlString('');
                      },
                      child: Text("Location", style: TextStyle(fontSize: 16)),
                    ),
                  ],
                ),
              );
            } else {
              return Center(
                child: Text(
                  "Event has been deleted",
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.red),
                ),
              );
            }
          }
        },
      ),
    );
  }

  Widget buildApplyWidget(ViewEventController controller) {
    var status = "";
    Color color = Colors.green;
    if (controller.application == null) {
      status = "";
      color = Colors.green;
    } else if (controller.application!.approved.approved == null) {
      status = "Waiting for confirmation";
      color = Get.theme.colorScheme.primary;
    } else if (controller.application!.approved.approved == true) {
      status = "Your application has been accepted";
      color = Colors.green;
    } else if (controller.application!.approved.approved == false) {
      status = "Your application has been declined";
      color = Colors.red;
    } else if (controller.event.value.registeredVendorsId.length >=
        controller.event.value.maxVendors) {
      status = "This event is full";
      color = Colors.red;
    }
    return status.isEmpty
        ? ElevatedButton(
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              minimumSize: Size(Get.width / 2.5, Get.height * 0.05),
              backgroundColor: Get.theme.colorScheme.primary,
              foregroundColor: Colors.blueGrey[700],
            ),
            child: Text('Apply'),
            onPressed: () async {
              if (event.questions.isNotEmpty) {
                await Get.to(VendorApplicationScreen(
                  event: event,
                ));
                Get.back();
              } else {
                Get.defaultDialog(
                  title: 'Apply for event',
                  titleStyle: TextStyle(fontSize: 24),
                  middleText: "Are you sure you want to apply for this event?",
                  barrierDismissible: true,
                  onConfirm: () async {
                    Application application = Application(
                      id: '',
                      vendorId: authController.uid,
                      eventId: event.id,
                      vendor: Vendor.fromMap(
                          authController.uid, authController.appUser),
                      applicationDate: DateTime.now(),
                      questions: [],
                      approved: Approval(approved: null),
                    );
                    var result = await DatabaseService().applyForEvent(
                      event.id,
                      application,
                    );
                    if (result) {
                      Get.snackbar('Congratulations',
                          'You have applied for this event!');
                    } else {
                      Get.snackbar('Error', 'Can not apply more than once');
                    }
                  },
                  onCancel: () {},
                );
              }
            },
          )
        : Text(status,
            style: TextStyle(
                color: color, fontSize: 16, fontWeight: FontWeight.bold));
  }
}
