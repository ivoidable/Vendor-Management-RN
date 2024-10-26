import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:vendor/controller/organizer/create_event_controller.dart';
import 'package:vendor/controller/auth_controller.dart';
import 'package:vendor/helper/database.dart';
import 'package:vendor/main.dart';
import 'package:vendor/model/event.dart';

class ScheduleEventScreen extends StatelessWidget {
  ScheduleEventScreen({super.key});

  final CreateEventController controller = Get.put(CreateEventController());
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    controller.images.add(
        'https://media.discordapp.net/attachments/1152649816199938060/1293154293385265212/2024-10-08_13.09.24.png?ex=671d6989&is=671c1809&hm=09a6caa9ee923aadad52f542940ca582fa7caaa4211cb0371a659783e12477cb&=&format=webp&quality=lossless&width=1071&height=602');
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
                  format: [],
                ),
                _buildTextField(
                  label: 'Description',
                  onChanged: (value) => controller.description.value = value,
                  maxLines: 3,
                  format: [],
                ),
                _buildTextField(
                  label: 'Vendors Limit',
                  keyboardType: TextInputType.number,
                  onChanged: (value) =>
                      controller.maxVendors.value = int.tryParse(value) ?? 0,
                  format: [FilteringTextInputFormatter.digitsOnly],
                ),
                _buildTextField(
                  label: 'Vendor Fee',
                  keyboardType: TextInputType.number,
                  onChanged: (value) => controller.vendorFee.value =
                      double.tryParse(value) ?? 0.0,
                  format: [FilteringTextInputFormatter.digitsOnly],
                ),
                // _buildTextField(
                //   label: 'User Fee',
                //   keyboardType: TextInputType.number,
                //   onChanged: (value) =>
                //       controller.userFee.value = double.tryParse(value) ?? 0.0,
                //   format: [FilteringTextInputFormatter.digitsOnly],
                // ),
                _buildDatePicker(context),
                Obx(
                  () => ListView.builder(
                    shrinkWrap: true,
                    itemCount: controller.questions.length,
                    itemBuilder: (context, index) {
                      return Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: controller.questions[index],
                              decoration: const InputDecoration(
                                hintText: 'Enter your question',
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Question cannot be empty';
                                }
                                return null;
                              },
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => controller.removeQuestion(index),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton.icon(
                      onPressed: controller.addQuestion,
                      icon: const Icon(Icons.add),
                      label: const Text('Add Question'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      String uid = authController.uid;
                      Event event = Event(
                        id: '',
                        organizerId: uid,
                        name: controller.name.value,
                        date: controller.date.value,
                        vendorFee: controller.vendorFee.value,
                        attendeeFee: controller.userFee.value,
                        maxVendors: controller.maxVendors.value,
                        description: controller.description.value,
                        imageUrl: controller.images[0],
                        location: 'T.B.D',
                        registeredVendors: [],
                        applications: [],
                        questions: [],
                      );
                      DatabaseService().createEvent(event);
                      Get.back();
                      Get.snackbar('Success', 'Event Has Been Scheduled',
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
    required List<TextInputFormatter> format,
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
        inputFormatters: format,
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
