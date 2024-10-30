import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vendor/model/event.dart';

class ViewApplicationScreen extends StatelessWidget {
  final Application application;

  const ViewApplicationScreen({Key? key, required this.application})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Application Details')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Vendor: ${application.vendor.businessName}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Slogan: ${application.vendor.slogan ?? ""}'),
            const SizedBox(height: 8),
            const Text(
              'Questions:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            ...application.questions.map(
              (question) => ListTile(
                title: Text(question.question),
                subtitle: Text(question.answer),
              ),
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    // Handle approval
                    Get.back(result: Approval(approved: true));
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.lightGreen),
                  child: const Text('Approve'),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Handle rejection
                    Get.back(result: Approval(approved: false));
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: const Text('Reject'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
