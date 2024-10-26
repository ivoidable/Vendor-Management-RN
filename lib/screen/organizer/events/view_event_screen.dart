import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:vendor/model/event.dart';
import 'package:vendor/screen/organizer/events/view_application_screen.dart';

class ViewEventScreen extends StatelessWidget {
  final Event event;

  ViewEventScreen({required this.event});

  @override
  Widget build(BuildContext context) {
    event.applications
        .sort((a, b) => a.applicationDate.compareTo(b.applicationDate));
    return Scaffold(
      appBar: AppBar(
        title: Text('Event: ${event.name}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              color: Colors.amber,
              height: 180,
              width: Get.width * 0.85,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 1,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Image.network(
                      event.imageUrl,
                      width: 180,
                      height: 180,
                      fit: BoxFit.cover,
                    ),
                  );
                },
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
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                ),
                Text(
                  'User Fee: \$${event.attendeeFee.toStringAsFixed(2)}',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
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
                      fontSize: 16, fontWeight: FontWeight.w400),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const Text(
                  'Applications:',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(
              height: 4,
            ),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.grey[300],
              ),
              width: Get.width * 0.85,
              height: Get.height * 0.3,
              child: ListView.builder(
                itemCount: event.applications.length,
                itemBuilder: (context, index) {
                  final application = event.applications[index];
                  return ApplicationCard(
                    application: application,
                    onShowDetails: () async {
                      Approval approval = await Get.to(
                          ViewApplicationScreen(application: application));
                      application.approved = approval;
                      if (approval.approved != null) {
                        if (approval.approved!) {
                          event.registeredVendors.add(application.vendor);
                        } else if (!approval.approved!) {}
                      }
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
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
      color = Colors.blueGrey;
      status = "Pending Review";
    }
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: ListTile(
        tileColor: color,
        leading: application.vendor.logoUrl.isNotEmpty
            ? Image.network(application.vendor.logoUrl, width: 50)
            : const Icon(Icons.business),
        title: Text(application.vendor.businessName),
        subtitle: Text(
          'Application Date: ${application.applicationDate.toLocal()}',
        ),
        trailing: Row(
          children: [
            Text(status),
            ElevatedButton(
              onPressed: application.approved.approved == null
                  ? onShowDetails
                  : () {
                      Get.snackbar('Already Reviewed Application',
                          'You can not review applications multiple times');
                    },
              child: const Text('Show Application'),
            ),
          ],
        ),
      ),
    );
  }
}
