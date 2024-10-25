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
    event.applications.sort((a, b) => a.applicationDate.compareTo(b.applicationDate));
    return Scaffold(
      appBar: AppBar(
        title: Text('Event: ${event.name}'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
            const Text(
              'Applications:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            //FIXME: Fix Applications
            ListView.builder(
              itemCount: event.applications.length,
              itemBuilder: (context, index) {
                final application = event.applications[index];
                return ApplicationCard(
                  application: application,
                  onShowDetails: () {
                    Get.to(ViewApplicationScreen(application: application));
                  },
                );
              },
            ),
            const SizedBox(height: 16),
            const Text(
              'Event Images:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 150,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 1,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Image.network(
                      event.imageUrl,
                      width: 150,
                      height: 150,
                      fit: BoxFit.cover,
                    ),
                  );
                },
              ),
            ),
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
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: ListTile(
        leading: application.vendor.logoUrl.isNotEmpty
            ? Image.network(application.vendor.logoUrl, width: 50)
            : const Icon(Icons.business),
        title: Text(application.vendor.businessName),
        subtitle: Text(
          'Application Date: ${application.applicationDate.toLocal()}',
        ),
        trailing: ElevatedButton(
          onPressed: onShowDetails,
          child: const Text('Show Application'),
        ),
      ),
    );
  }
}