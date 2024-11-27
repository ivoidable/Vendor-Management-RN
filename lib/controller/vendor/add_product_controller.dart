import 'dart:io';

import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:vendor/helper/database.dart';
import 'package:vendor/main.dart';
import 'package:vendor/model/product.dart';
import 'package:vendor/model/user.dart';

class AddProductController extends GetxController {
  var productName = ''.obs;
  var images = <String>[];
  RxInt stock = 0.obs;
  RxDouble price = 0.0.obs;

  final ImagePicker _picker = ImagePicker();
  var selectedImage = Rx<XFile?>(null); // Reactive variable

  // Method to pick an image from gallery or camera
  Future<void> pickImage(ImageSource source) async {
    final XFile? image = await _picker.pickImage(source: source);
    if (image != null) {
      selectedImage.value = XFile(image.path);
    }
  }

  // Method to clear the selected image
  void removeImage(int index) {
    images.remove(index);
  }

  void addProduct(Product product) async {
    String imageUrl = await DatabaseService().uploadProductImage(
      selectedImage.value!,
      authController.uid,
      product.productName,
    );
    product.images.clear();
    product.images.add(imageUrl);
    print(product.images);
    DatabaseService().addProduct(authController.uid, product);
  }
}
