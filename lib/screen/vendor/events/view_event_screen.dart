import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:vendor/helper/database.dart';
import 'package:vendor/main.dart';
import 'package:vendor/model/event.dart';
import 'package:vendor/model/user.dart';
import 'package:vendor/screen/vendor/events/vendor_application_screen.dart';

class VendorViewEventScreen extends StatelessWidget {
  final Event event;

  VendorViewEventScreen({required this.event});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.amber,
        centerTitle: true,
        title: Text('Event: ${event.name}'),
      ),
      body: SingleChildScrollView(
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
                  for (var image in event.images)
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
            // Container(
            //   height: 150,
            //   child: ListView.builder(
            //     scrollDirection: Axis.horizontal,
            //     itemCount: 1,
            //     itemBuilder: (context, index) {
            //       return Padding(
            //         padding: const EdgeInsets.only(right: 8.0),
            //         child: Image.network(
            //           event.images.first,
            //           width: 150,
            //           height: 150,
            //           fit: BoxFit.cover,
            //         ),
            //       );
            //     },
            //   ),
            // ),
            Text(
              event.name,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              event.description,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            Text(
              'Vendor Fee: \$${event.vendorFee.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Text(
              'User Fee: \$${event.attendeeFee.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 16),
            Text(
              'Date: ${DateFormat.yMMMMd().add_jm().format(event.date)}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
            ),
            const SizedBox(height: 16),
            !event.appliedVendorsId.contains(authController.uid)
                ? ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      minimumSize: Size(Get.width / 2.5, Get.height * 0.05),
                      backgroundColor: Colors.amber,
                      foregroundColor: Colors.blueGrey[700],
                    ),
                    child: Text('Apply'),
                    onPressed: () async {
                      //TODO: Check if there are any questions then ask them
                      if (event.questions.isNotEmpty) {
                        await Get.to(VendorApplicationScreen(
                          event: event,
                        ));
                        Get.back();
                      } else {
                        Get.defaultDialog(
                          title: 'Apply for event',
                          titleStyle: TextStyle(fontSize: 24),
                          middleText:
                              "Are you sure you want to apply for this event?",
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
                              Get.snackbar(
                                  'Error', 'Can not apply more than once');
                            }
                          },
                          onCancel: () {},
                        );
                      }

                      // Get.dialog(
                      //   Container(
                      //     height: Get.height * 0.5,
                      //     width: Get.width * 0.88,
                      //     decoration: BoxDecoration(
                      //       color: Colors.grey[300],
                      //       borderRadius: BorderRadius.circular(12),
                      //     ),
                      //     child: Column(
                      //       children: [
                      //         const Text('Apply for event'),
                      //         const Text(
                      //             'Are you sure you want to apply for this event?'),
                      //         const Spacer(),
                      //         Row(
                      //           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      //           children: [
                      //             ElevatedButton(
                      //               style: ElevatedButton.styleFrom(
                      //                 shape: RoundedRectangleBorder(
                      //                   borderRadius: BorderRadius.circular(12),
                      //                 ),
                      //                 minimumSize:
                      //                     Size(Get.width / 4, Get.height * 0.05),
                      //                 backgroundColor: Colors.amber,
                      //                 foregroundColor: Colors.blueGrey[700],
                      //               ),
                      //               onPressed: () {
                      //                 Get.back();
                      //               },
                      //               child: const Text('Cancel'),
                      //             ),
                      //             ElevatedButton(
                      //               style: ElevatedButton.styleFrom(
                      //                 shape: RoundedRectangleBorder(
                      //                   borderRadius: BorderRadius.circular(12),
                      //                 ),
                      //                 minimumSize:
                      //                     Size(Get.width / 4, Get.height * 0.05),
                      //                 backgroundColor: Colors.amber,
                      //                 foregroundColor: Colors.blueGrey[700],
                      //               ),
                      //               onPressed: () {
                      //                 //TODO: Apply vendor for event
                      //               },
                      //               child: const Text('Apply'),
                      //             ),
                      //           ],
                      //         ),
                      //       ],
                      //     ),
                      //   ),
                      //   barrierDismissible: true,
                      // );
                    },
                  )
                : const Text(
                    "You have applied for this event!",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
            // Image carousel with height of 150 and width of 85% of screen width
            // Container(
            //   width: Get.width * 0.86,
            //   child: car.CarouselSlider(
            //     options: car.CarouselOptions(
            //       height: 150,
            //       aspectRatio: 16 / 9,
            //       viewportFraction: 0.8,
            //       initialPage: 0,
            //       enableInfiniteScroll: true,
            //       reverse: false,
            //       autoPlay: true,
            //       autoPlayInterval: Duration(seconds: 3),
            //       autoPlayAnimationDuration: Duration(milliseconds: 800),
            //       autoPlayCurve: Curves.fastOutSlowIn,
            //       enlargeCenterPage: true,
            //       onPageChanged: (index, reason) {},
            //       scrollDirection: Axis.horizontal,
            //     ),
            //     items: event.images.map((image) {
            //       return Builder(
            //         builder: (BuildContext context) {
            //           return Container(
            //             width: MediaQuery.of(context).size.width,
            //             margin: EdgeInsets.symmetric(horizontal: 5.0),
            //             decoration: BoxDecoration(
            //               borderRadius: BorderRadius.circular(10),
            //             ),
            //             child: Image.network(
            //               image,
            //               fit: BoxFit.cover,
            //             ),
            //           );
            //         },
            //       );
            //     }).toList(),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}
