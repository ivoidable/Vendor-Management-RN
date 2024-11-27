import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:vendor/model/event.dart';

class CreateEventController extends GetxController {
  var name = ''.obs;
  var description = ''.obs;
  var vendorFee = 0.0.obs;
  var userFee = 0.0.obs;
  var startDate = DateTime.now().obs;
  var endDate = DateTime.now().add(const Duration(days: 1)).obs;
  var startTime = TimeOfDay.now().obs;
  var endTime = TimeOfDay.now().obs;
  var maxVendors = 0.obs;
  var images = <String>[].obs;
  var imagesUrls = <String>[].obs;
  var applications = <String>[].obs;

  var isVendor = false.obs;
  var selectedChip = 0.obs; // Observable to store the selected chip index
  void selectChip(int index) {
    selectedChip.value = index; // Update the selected chip
  }

  final ImagePicker _picker = ImagePicker();

  var availableTags = Activity.values.map((str) => str.name).toList().obs;
  var selectedTags = <String>[].obs;

  void toggleTag(String tag) {
    if (selectedTags.contains(tag)) {
      selectedTags.remove(tag);
    } else {
      selectedTags.add(tag);
    }
  }

  // Method to pick an image from gallery or camera

  Future<void> pickImage(ImageSource source) async {
    final XFile? image = await _picker.pickImage(source: source);
    print(image);
    if (image != null) {
      print(image.path);
      images.value.add(image.path);
    }
  }

  void setStartTime(TimeOfDay pickedTime, TimeOfDay endTimes) {
    startTime.value = pickedTime;
    endTime.value = endTimes;
    update();
  }

  // Method to clear the selected image
  void removeImage(int index) {
    images.remove(index);
  }

  void setStartDate(DateTime pickedDate) {
    startDate.value = pickedDate;
  }

  void setEndDate(DateTime pickedDate) {
    endDate.value = pickedDate;
  }

  void addImage(String url) {
    images.add(url);
  }

  void addApplication(String applicant) {
    applications.add(applicant);
  }

  var questions = <TextEditingController>[].obs;

  void addQuestion() {
    questions.add(TextEditingController());
  }

  void removeQuestion(int index) {
    questions.removeAt(index);
  }

  @override
  void onClose() {
    images.clear();
    for (var controller in questions) {
      controller.dispose(); // Clean up controllers
    }
    super.onClose();
  }
}
