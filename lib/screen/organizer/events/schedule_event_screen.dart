import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vendor/controller/organizer/create_event_controller.dart';
import 'package:vendor/controller/user/user_controller.dart';
import 'package:vendor/helper/database.dart';
import 'package:vendor/model/event.dart';

class ScheduleEventScreen extends StatelessWidget {
  ScheduleEventScreen({super.key});

  final CreateEventController controller = Get.find<CreateEventController>();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Schedule Event"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTextField(
                  label: 'Event Name',
                  onChanged: (value) => controller.name.value = value,
                ),
                _buildTextField(
                  label: 'Description',
                  onChanged: (value) => controller.description.value = value,
                  maxLines: 3,
                ),
                _buildTextField(
                  label: 'Vendors Limit',
                  keyboardType: TextInputType.number,
                  onChanged: (value) =>
                      controller.maxVendors.value = int.tryParse(value) ?? 0,
                ),
                _buildTextField(
                  label: 'Vendor Fee',
                  keyboardType: TextInputType.number,
                  onChanged: (value) => controller.vendorFee.value =
                      double.tryParse(value) ?? 0.0,
                ),
                _buildTextField(
                  label: 'User Fee',
                  keyboardType: TextInputType.number,
                  onChanged: (value) =>
                      controller.userFee.value = double.tryParse(value) ?? 0.0,
                ),
                _buildDatePicker(context),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      String uid =
                          await AuthController().firebaseUser.value!.uid;
                      Event event = Event(
                          id: '',
                          name: controller.name.value,
                          date: controller.date.value,
                          imageUrl: controller.images.value[0] ?? '',
                          organizerId: uid,
                          maxVendors: controller.maxVendors.value,
                          location: 'T.B.D',
                          description: controller.description.value);
                      DatabaseService().createEvent(event);
                      Get.back();
                      Get.snackbar('Success', 'Event Has Been Sent For Review!',
                          backgroundColor: Colors.lightGreen);
                    }
                  },
                  child: const Text('Create Event'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required Function(String) onChanged,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
        keyboardType: keyboardType,
        maxLines: maxLines,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter $label';
          }
          return null;
        },
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildDatePicker(BuildContext context) {
    return Obx(() {
      final controller = Get.find<CreateEventController>();
      return ListTile(
        title: Text(
          'Event Date: ${controller.date.value.toLocal()}'.split(' ')[0],
        ),
        trailing: const Icon(Icons.calendar_today),
        onTap: () async {
          DateTime? picked = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(2000),
            lastDate: DateTime(2101),
          );
          if (picked != null) {
            controller.setDate(picked);
          }
        },
      );
    });
  }

  // Widget _buildMaxVendorsSlider() {
  // final CreateEventController controller = Get.find<CreateEventController>();

  // return Obx(() {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       Text(
  //         'Max Vendors: ${controller.maxVendors.value}',
  //         style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
  //       ),
  //       RangeSlider(
  //         values: RangeValues(0, 500),
  //         min: 0,
  //         max: 500,
  //         divisions: 5,
  //         labels: RangeLabels(
  //           '0',
  //           controller.maxVendors.value.toString(),
  //         ),
  //         onChanged: (RangeValues values) {
  //           controller.maxVendors.value = values.end.toInt();
  //         },
  //       ),
  //     ],
  //   );
  // });
}
