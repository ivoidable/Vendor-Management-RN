import 'dart:io';

import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:vendor/helper/database.dart';
import 'package:vendor/main.dart';
import 'package:vendor/model/user.dart';

class VendorEditProfileController extends GetxController {
  final Vendor vendor;

  VendorEditProfileController(this.vendor);

  // Observables for fields
  var name = ''.obs;
  Rx<DateTime> dateOfBirth = Rx(DateTime.now());
  var email = ''.obs;
  var phoneNumber = ''.obs;
  var businessName = ''.obs;
  var profileImage = Rx<File?>(null); // Observable to store the selected image

  final ImagePicker _picker = ImagePicker(); // Instance of ImagePicker

  // Function to pick an image from the gallery
  Future<void> pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      profileImage.value = File(image.path);
      DatabaseService().uploadLogo(image, authController.uid);
    }
  }

  @override
  void onInit() {
    super.onInit();

    // Initialize observables with vendor data
    name.value = vendor.name;
    dateOfBirth.value = vendor.dateOfBirth;
    phoneNumber.value = vendor.phoneNumber ?? "";
    email.value = vendor.email;
    businessName.value = vendor.businessName;
  }

  void uploadImage() {
    //TODO: Implement image upload
  }

  // Update vendor object with the new data
  void updateVendor() async {
    vendor.name = name.value;
    vendor.dateOfBirth = dateOfBirth.value;
    vendor.email = email.value;
    vendor.businessName = businessName.value;

    // For demonstration, print updated vendor data
    DatabaseService().updateUser(authController.uid, vendor.toMap());
    authController.appUser = vendor.toMap();
    print(
        'Updated Vendor: ${vendor.name}, ${vendor.dateOfBirth}, ${vendor.email}, ${vendor.businessName}');
  }
}
