import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:vendor/controller/organizer/create_event_controller.dart';
import 'package:vendor/helper/database.dart';
import 'package:vendor/main.dart';
import 'package:vendor/model/event.dart';

class ScheduleEventScreen extends StatelessWidget {
  ScheduleEventScreen({super.key});

  final CreateEventController controller = Get.put(CreateEventController());
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    //TODO: Remove This on release
    controller.images.add(
        'https://firebasestorage.googleapis.com/v0/b/vendorevents-d3e6c.appspot.com/o/event_sample.jpg?alt=media&token=7c6dfe6a-c720-4797-bc52-2e301bfec13a');
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Schedule Event",
          style: TextStyle(color: Colors.blueGrey[700]),
        ),
        centerTitle: true,
        backgroundColor: Colors.amber,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: Get.height * 0.13,
                ),
                _buildImagePicker(),
                SizedBox(
                  height: Get.height * 0.05,
                ),
                // ImagePicker that adds images from gallery to controller.images
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
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: controller.questions.length,
                    itemBuilder: (context, index) {
                      return Row(
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: TextFormField(
                                decoration: InputDecoration(
                                  labelText: 'Enter your question',
                                  focusColor: Colors.amber,
                                  labelStyle: TextStyle(color: Colors.blueGrey),
                                  iconColor: Colors.amber,
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: Colors.blueGrey,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: Colors.amber,
                                      width: 3,
                                    ),
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                controller: controller.questions[index],
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Question cannot be empty';
                                  }
                                  return null;
                                },
                              ),
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
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        minimumSize: Size(Get.width / 2, Get.height * 0.05),
                        backgroundColor: Colors.blueGrey[700],
                        foregroundColor: Colors.amber,
                      ),
                      onPressed: controller.addQuestion,
                      icon: const Icon(Icons.add),
                      label: const Text('Add Question'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        minimumSize: Size(Get.width / 2, Get.height * 0.05),
                        backgroundColor: Colors.amber,
                        foregroundColor: Colors.blueGrey[700],
                      ),
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
                            images: controller.images,
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
                SizedBox(
                  height: 24,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImagePicker() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              minimumSize: Size(Get.width / 2, Get.height * 0.05),
              backgroundColor: Colors.amber,
              foregroundColor: Colors.blueGrey[700],
            ),
            onPressed: () => controller.pickImage(ImageSource.gallery),
            icon: const Icon(Icons.add_a_photo),
            label: const Text('Add Image'),
          ),
        ],
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
          focusColor: Colors.amber,
          labelStyle: TextStyle(color: Colors.blueGrey),
          iconColor: Colors.amber,
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: Colors.amber,
              width: 3,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: Colors.blueGrey,
            ),
          ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
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
          'Event Date: ${controller.date.value.toLocal().toIso8601String()}'
              .split('T')[0],
        ),
        trailing: const Icon(Icons.calendar_today),
        onTap: () async {
          DateTime? picked = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime.now(),
            lastDate: DateTime(DateTime.now().year + 3),
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
