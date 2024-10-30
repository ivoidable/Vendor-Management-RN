import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:vendor/helper/database.dart';
import 'package:vendor/model/event.dart';
import 'package:vendor/screen/organizer/events/view_application_screen.dart';

class ViewEventDetailsTab extends StatelessWidget {
  final Event event;

  ViewEventDetailsTab({required this.event});

  @override
  Widget build(BuildContext context) {
    //TODO: Clean up Futures and Streams here as they are unnecessary
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.amber,
        centerTitle: true,
        title: Text('Event: ${event.name}'),
        actions: [
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              DatabaseService().deleteEvent(event.id);
              Get.back();
            },
          ),
        ],
      ),
      body: FutureBuilder(
          future: DatabaseService().getApplicationsQuery(event.id),
          builder: (context, snapshot) {
            return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: DatabaseService().getApplicationsStream(event.id),
                initialData: snapshot.data,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(
                      child: Text("No Applications"),
                    );
                  } else {
                    return SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
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
                                      padding:
                                          const EdgeInsets.only(right: 8.0),
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
                            SizedBox(
                              height: 24,
                            ),
                            Text(
                              event.name,
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              event.description,
                              style: const TextStyle(fontSize: 18),
                            ),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Vendor Fee: \$${event.vendorFee.toStringAsFixed(2)}',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500),
                                ),
                                Text(
                                  'User Fee: \$${event.attendeeFee.toStringAsFixed(2)}',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                            SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  '${DateFormat.yMMMMd().add_jm().format(event.date)}',
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w400),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    );
                  }
                });
          }),
    );
  }
}

class ApplicationCard extends StatelessWidget {
  final Application application;
  final VoidCallback onShowDetails;

  const ApplicationCard({
    Key? key,
    required this.application,
    required this.onShowDetails,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color color;
    String status = "";
    if (application.approved.approved != null) {
      if (application.approved.approved == true) {
        color = Colors.lightGreen;
        status = "Approved";
      } else {
        color = Colors.red;
        status = "Rejected";
      }
    } else {
      color = const Color.fromARGB(255, 180, 211, 226);
      status = "Pending Review";
    }
    return GestureDetector(
      onTap: onShowDetails,
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: Container(
          width: Get.width * .85,
          height: Get.height * 0.12,
          child: ListTile(
            tileColor: color,
            leading: application.vendor.logoUrl.isNotEmpty
                ? Image.network(application.vendor.logoUrl, width: 50)
                : const Icon(Icons.business),
            title: Text(application.vendor.businessName),
            subtitle: Text(
              'Application Date: ${application.applicationDate.toLocal()}',
            ),
            trailing: Text(status),
          ),
        ),
      ),
    );
  }
}

class ViewApplicationsScreen extends StatelessWidget {
  final Event event;

  const ViewApplicationsScreen({required this.event});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Applications'),
        centerTitle: true,
        backgroundColor: Colors.amber,
      ),
      body: FutureBuilder(
          future: DatabaseService().getApplicationsQuery(event.id),
          builder: (context, snapshot) {
            return Center(
              child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: DatabaseService().getApplicationsStream(event.id),
                  initialData: snapshot.data,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData)
                      return const Center(
                        child: Text("No applications"),
                      );
                    List<Application> applications =
                        snapshot.data!.docs.map((doc) {
                      return Application.fromMap(
                        doc.id,
                        doc.data(),
                      );
                    }).toList();
                    return Padding(
                        padding: EdgeInsets.all(24),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.grey[300],
                          ),
                          width: Get.width * 0.85,
                          height: Get.height * 0.85,
                          child: ListView.builder(
                            itemCount: applications.length,
                            itemBuilder: (context, index) {
                              final application = applications[index];
                              return ApplicationCard(
                                application: application,
                                onShowDetails: () async {
                                  Approval? approval = await Get.to(
                                      ViewApplicationScreen(
                                          application: application));
                                  application.approved =
                                      approval ?? Approval(approved: null);
                                  if (approval != null) {
                                    if (approval.approved!) {
                                      print(application.toMap());
                                      DatabaseService().registerVendorForEvent(
                                        event.id,
                                        application.vendorId,
                                        application.id,
                                      );
                                    } else if (!approval.approved!) {
                                      DatabaseService().declineApplication(
                                        event.id,
                                        application.vendorId,
                                        application.id,
                                      );
                                    }
                                  }
                                  build(context);
                                },
                              );
                            },
                          ),
                        ));
                  }),
            );
          }),
    );
  }
}

class ViewRegisteredVendorsScreen extends StatelessWidget {
  final Event event;

  const ViewRegisteredVendorsScreen({required this.event});

  @override
  Widget build(BuildContext context) {
    return Scaffold();
  }
}
