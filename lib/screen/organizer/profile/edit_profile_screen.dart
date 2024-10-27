import 'package:date_time_picker/date_time_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vendor/controller/organizer/edit_profile_controller.dart';
import 'package:vendor/model/user.dart';

class OrganizerEditProfileScreen extends StatelessWidget {
  final Organizer organizer;

  OrganizerEditProfileScreen({Key? key, required this.organizer})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Initialize the controller with the provided vendor
    final OrganizerEditProfileController controller =
        Get.put(OrganizerEditProfileController(organizer));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Vendor Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildTextField(
              label: 'Name',
              icon: Icons.person,
              onChanged: (value) => controller.name.value = value,
              initialValue: controller.name.value,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              label: 'Email',
              icon: Icons.email,
              onChanged: (value) => controller.email.value = value,
              initialValue: controller.email.value,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            DateTimePicker(
              initialValue: '',
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
