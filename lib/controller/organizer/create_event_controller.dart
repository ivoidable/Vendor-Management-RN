import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:vendor/model/event.dart';

class CreateEventController extends GetxController {
  var name = ''.obs;
  var description = ''.obs;
  var vendorFee = 0.0.obs;
  var userFee = 0.0.obs;
  var startDate = DateTime.now().obs;
  var endDate = DateTime.now().add(Duration(days: 1)).obs;
  var maxVendors = 0.obs;
  var images = <String>[].obs;
  var applications = <String>[].obs;
  var selectedLocation = Rx<LatLng?>(null);

  final ImagePicker _picker = ImagePicker();
  var selectedImage = Rx<File?>(null); // Reactive variable

  var availableTags = Activity.values.map((str) => str.name).toList().obs;
  var selectedTags = <String>[].obs;

  void toggleTag(String tag) {
    if (selectedTags.contains(tag)) {
      selectedTags.remove(tag);
    } else {
      selectedTags.add(tag);
    }
  }

  void updateLatlng(LatLng position) {
    selectedLocation.value = position;
  }

  // Method to pick an image from gallery or camera
  Future<void> pickImage(ImageSource source) async {
    final XFile? image = await _picker.pickImage(source: source);
    if (image != null) {
      selectedImage.value = File(image.path);
    }
  }

  String? getGoogleMapsLink() {
    if (selectedLocation.value != null) {
      double latitude = selectedLocation.value!.latitude;
      double longitude = selectedLocation.value!.longitude;
      return 'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
    }
    return null;
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
