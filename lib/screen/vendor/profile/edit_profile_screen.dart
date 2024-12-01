import 'package:date_time_picker/date_time_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vendor/controller/vendor/edit_profile_controller.dart';
import 'package:vendor/model/user.dart';

class EditProfileScreen extends StatelessWidget {
  final Vendor vendor;

  EditProfileScreen({Key? key, required this.vendor}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Initialize the controller with the provided vendor
    final VendorEditProfileController controller =
        Get.put(VendorEditProfileController(vendor));

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Get.theme.colorScheme.primary,
        title: const Text('Edit Vendor Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            SizedBox(height: Get.height * 0.05),
            profileImageWidget(),
            SizedBox(height: Get.height * 0.05),
            _buildTextField(
              label: 'Name',
              icon: Icons.person,
              onChanged: (value) => controller.name.value = value,
              initialValue: controller.name.value,
            ),
            const SizedBox(height: 24),
            _buildTextField(
              label: 'Business Name',
              icon: Icons.business,
              onChanged: (value) => controller.businessName.value = value,
              initialValue: controller.businessName.value,
            ),
            const SizedBox(height: 24),
            _buildTextField(
              label: 'Phone',
              icon: Icons.phone,
              onChanged: (value) => controller.phoneNumber.value = value,
              initialValue: controller.phoneNumber.value,
            ),
            const SizedBox(height: 24),
            _buildTextField(
              label: 'Email',
              icon: Icons.email,
              onChanged: (value) => controller.email.value = value,
              initialValue: controller.email.value,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 24),
            DateTimePicker(
              initialValue: '',
              decoration: InputDecoration(
                labelText: 'Date of Birth',
                border: OutlineInputBorder(),
              ),
              initialDate: controller.dateOfBirth.value,
              firstDate: DateTime(1930),
              lastDate: DateTime.now(),
              dateLabelText: 'Date of birth',
              onChanged: (value) {
                controller.dateOfBirth.value = DateTime.parse(value);
              },
              validator: (val) {
                return null;
              },
              onSaved: (val) =>
                  controller.dateOfBirth.value = DateTime.parse(val!),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                minimumSize: Size(Get.width / 2, Get.height * 0.05),
                backgroundColor: Get.theme.colorScheme.primary,
                foregroundColor: Colors.blueGrey[700],
              ),
              onPressed: () {
                controller.updateVendor();
                Get.back(); // Navigate back after saving
              },
              child: const Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }

  Widget profileImageWidget() {
    final VendorEditProfileController controller = Get.find();
    return Obx(() {
      return GestureDetector(
        onTap: () async {
          await controller.pickImage(); // Pick a new image on tap
        },
        child: CircleAvatar(
          radius: 60,
          backgroundColor: Colors.grey[300],
          backgroundImage: controller.profileImage.value != null
              ? FileImage(controller.profileImage.value!)
              : AssetImage('assets/default_profile.png') as ImageProvider,
          child: controller.profileImage.value == null
              ? Icon(Icons.camera_alt, size: 30, color: Colors.white)
              : null,
        ),
      );
    });
  }

  Widget _buildTextField({
    required String label,
    required IconData icon,
    required Function(String) onChanged,
    required String initialValue,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      initialValue: initialValue,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: const OutlineInputBorder(),
      ),
      keyboardType: keyboardType,
      onChanged: onChanged,
    );
  }
}
