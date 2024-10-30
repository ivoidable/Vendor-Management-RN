import 'package:date_time_picker/date_time_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vendor/helper/database.dart';
import 'package:vendor/model/user.dart';

class RegisterController extends GetxController {
  var isVendor = false.obs;
  var selectedChip = 0.obs; // Observable to store the selected chip index

  var availableTags = Activity.values.map((str) => str.name).toList().obs;
  var selectedTags = <String>[].obs;

  void toggleTag(String tag) {
    if (selectedTags.contains(tag)) {
      selectedTags.remove(tag);
    } else {
      selectedTags.add(tag);
    }
  }

  void selectChip(int index) {
    selectedChip.value = index; // Update the selected chip
  }

  void updateShite(Vendor vendor) {
    //TODO: Update Vendor
  }
}

class RegisterScreen extends StatelessWidget {
  RegisterScreen({super.key});

  DateTime dateOfBirth = DateTime.now();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    RegisterController controller = Get.put(RegisterController());
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register'),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: Get.width / 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo Here
            // Name Text Box
            TextField(
              controller: nameController,
              keyboardType: TextInputType.name,
              maxLength: 64,
              decoration: const InputDecoration(label: Text("Full Name")),
            ),
            const SizedBox(
              height: 6,
            ),
            // Email text Box
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              maxLength: 255,
              decoration: const InputDecoration(label: Text("Email Address")),
            ),
            const SizedBox(
              height: 6,
            ),
            // Password Text Box
            TextField(
              controller: passwordController,
              maxLength: 64,
              obscureText: true,
              decoration: const InputDecoration(label: Text("Password")),
            ),
            const SizedBox(
              height: 6,
            ),
            // Date of birth
            DateTimePicker(
              initialValue: '',
              firstDate: DateTime(1930),
              lastDate: DateTime.now(),
              dateLabelText: 'Date of birth',
              onChanged: (val) => print(val),
              validator: (val) {
                print(val);
                return null;
              },
              onSaved: (val) => dateOfBirth = DateTime.parse(val!),
            ),
            const SizedBox(
              height: 6,
            ),
            ChipSelector(),
            const SizedBox(
              height: 12,
            ),
            // Submit button
            ElevatedButton(
                onPressed: () {
                  DatabaseService().signUp(
                    email: emailController.text,
                    password: passwordController.text,
                    name: nameController.text,
                    dateOfBirth: dateOfBirth,
                    role: controller.selectedChip.value == 0
                        ? 'vendor'
                        : 'organizer',
                  );
                },
                child: const Text("Register")),
            const SizedBox(
              height: 6,
            ),
          ],
        ),
      ),
    );
  }
}

class ChipSelector extends StatelessWidget {
  const ChipSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final RegisterController controller = Get.put(RegisterController());

    final List<String> options = ['Vendor', 'Organizer'];

    return Wrap(
      spacing: 12.0,
      children: options.asMap().entries.map((entry) {
        final int index = entry.key;
        final String label = entry.value;

        return Obx(() => ChoiceChip(
              label: Text(label),
              selected: controller.selectedChip.value == index,
              onSelected: (bool isSelected) {
                if (isSelected) controller.selectChip(index);
              },
              selectedColor: Colors.amber,
              backgroundColor: Colors.grey.shade200,
              labelStyle: TextStyle(
                color: controller.selectedChip.value == index
                    ? Colors.white
                    : Colors.black,
              ),
            ));
      }).toList(),
    );
  }
}
