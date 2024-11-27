import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:vendor/controller/vendor/add_product_controller.dart';
import 'package:vendor/main.dart';
import 'package:vendor/model/product.dart';

class AddProductScreen extends StatelessWidget {
  AddProductScreen({super.key});

  final AddProductController controller = Get.put(AddProductController());
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add Product"),
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
                  label: 'Name',
                  onChanged: (value) => controller.productName.value = value,
                  format: [],
                ),
                _buildTextField(
                  label: 'Stock',
                  keyboardType: TextInputType.number,
                  onChanged: (value) =>
                      controller.stock.value = int.tryParse(value) ?? 0,
                  format: [FilteringTextInputFormatter.digitsOnly],
                ),
                _buildTextField(
                  label: 'Price',
                  keyboardType: TextInputType.number,
                  onChanged: (value) =>
                      controller.price.value = double.tryParse(value) ?? 0.0,
                  format: [FilteringTextInputFormatter.digitsOnly],
                ),
                // _buildTextField(
                //   label: 'User Fee',
                //   keyboardType: TextInputType.number,
                //   onChanged: (value) =>
                //       controller.userFee.value = double.tryParse(value) ?? 0.0,
                //   format: [FilteringTextInputFormatter.digitsOnly],
                // ),
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
                          var prod = Product(
                            vendorId: authController.uid,
                            productName: controller.productName.value,
                            images: controller.images,
                            stock: controller.stock.value,
                            price: controller.price.value,
                          );
                          controller.addProduct(prod);
                          Get.back();
                          Get.snackbar('Success', 'Product Has Been Added',
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
}
