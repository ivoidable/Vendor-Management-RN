import 'dart:io';

import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:vendor/helper/database.dart';
import 'package:vendor/main.dart';
import 'package:vendor/model/product.dart';
import 'package:vendor/model/user.dart';

class AddProductController extends GetxController {
  var productName = ''.obs;
  var images = <String>[].obs;
  RxInt stock = 0.obs;
  RxDouble price = 0.0.obs;

  final ImagePicker _picker = ImagePicker();
  var selectedImage = Rx<File?>(null); // Reactive variable

  // Method to pick an image from gallery or camera
  Future<void> pickImage(ImageSource source) async {
    final XFile? image = await _picker.pickImage(source: source);
    if (image != null) {
      selectedImage.value = File(image.path);
      //TODO: Product Image Logic
    }
  }

  // Method to clear the selected image
  void removeImage(int index) {
    images.remove(index);
  }

  void addProduct(Product product) {
    Vendor user = Vendor.fromMap(authController.uid, authController.appUser);
    user.products.add(product);
    DatabaseService().updateUser(authController.uid, user.toMap());
  }
}
