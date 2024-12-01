import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vendor/controller/vendor/event_application_controller.dart';
import 'package:vendor/helper/database.dart';
import 'package:vendor/main.dart';
import 'package:vendor/model/event.dart';
import 'package:vendor/model/user.dart';

class VendorApplicationScreen extends StatelessWidget {
  final Event event;
  VendorApplicationScreen({required this.event});

  final EventApplicationController controller =
      Get.put(EventApplicationController());

  @override
  Widget build(BuildContext context) {
    controller.setQuestions(event.questions);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Get.theme.colorScheme.primary,
        title: Text('Application'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: Get.height * 0.7,
              width: Get.width * 0.8,
              child: Obx(
                () => ListView.builder(
                  itemCount: controller.questions.length,
                  itemBuilder: (context, index) {
                    return QuestionContainer(index: index);
                  },
                ),
              ),
            ),
            _buildSubmitButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton() => ElevatedButton(
        onPressed: () async {
          Application application = Application(
            id: authController.uid,
            vendorId: authController.uid,
            eventId: event.id,
            vendor: Vendor.fromMap(authController.uid, authController.appUser),
            applicationDate: DateTime.now(),
            questions: controller.getAnsweredQuestions(),
            approved: Approval(approved: null),
          );
          var result = await DatabaseService().applyForEvent(
            event.id,
            application,
          );
          print(result);
          if (result == false) {
            Get.snackbar('Error', 'Can not apply more than once');
          } else {
            Get.snackbar('Congratulations', 'You have applied for this event!');
          }
          Get.back();
        },
        child: Text('Submit'),
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          minimumSize: Size(Get.width / 2, Get.height * 0.05),
          backgroundColor: Get.theme.colorScheme.primary,
          foregroundColor: Colors.blueGrey[700],
        ),
      );
}

class QuestionContainer extends StatelessWidget {
  final int index; // Index to identify the question

  QuestionContainer({required this.index});

  @override
  Widget build(BuildContext context) {
    final controller =
        Get.find<EventApplicationController>(); // Access the controller

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            controller.questions[index].question,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          TextField(
            onChanged: (value) {
              controller.updateAnswer(index, value); // Update the answer
            },
            decoration: InputDecoration(
              hintText: 'Enter your answer',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
    );
  }
}
