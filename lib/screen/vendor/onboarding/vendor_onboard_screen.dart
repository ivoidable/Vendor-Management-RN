import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vendor/helper/database.dart';
import 'package:vendor/main.dart';
import 'package:vendor/model/event.dart';
import 'package:vendor/screen/shared/register_screen.dart';

class VendorOnboardScreen extends StatelessWidget {
  VendorOnboardScreen({super.key});

  DateTime dateOfBirth = DateTime.now();
  final RegisterController controller = Get.put(RegisterController());
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController sloganController = TextEditingController();
  final TextEditingController businessNameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Get.theme.colorScheme.primary,
        centerTitle: true,
        title: const Text('Register'),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: Get.width / 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Name Text Box
            TextField(
              controller: businessNameController,
              keyboardType: TextInputType.name,
              maxLength: 128,
              decoration: const InputDecoration(label: Text("Business Name")),
            ),
            const SizedBox(
              height: 6,
            ),
            // Email text Box
            TextField(
              controller: phoneNumberController,
              keyboardType: TextInputType.emailAddress,
              maxLength: 255,
              decoration: const InputDecoration(label: Text("Phone Number")),
            ),
            const SizedBox(
              height: 6,
            ),
            TextField(
              controller: sloganController,
              keyboardType: TextInputType.name,
              maxLength: 128,
              decoration: const InputDecoration(label: Text("Slogan")),
            ),
            const SizedBox(
              height: 6,
            ),
            TagSelector(tagController: controller),
            const SizedBox(
              height: 6,
            ),
            // Submit button
            ElevatedButton(
              onPressed: () {
                DatabaseService().updateUser(
                  authController.uid,
                  {
                    'business_name': businessNameController.text,
                    'phone_number': phoneNumberController.text,
                    'activities': controller.selectedTags.value,
                  },
                );
                authController.appUser['business_name'] = businessNameController.text;
                authController.appUser['phone_number'] = phoneNumberController.text;
                authController.appUser['activities'] = controller.selectedTags.value.map((elements) => EventActivity.values.firstWhere((element) => element.name == elements)).toList();
                Get.offAllNamed('/vendor_main');
              },
              child: const Text("Register"),
            ),
            const SizedBox(
              height: 6,
            ),
          ],
        ),
      ),
    );
  }
}

class TagSelector extends StatelessWidget {
  final RegisterController tagController;
  TagSelector({required this.tagController});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Flexible(
          fit: FlexFit.loose,
          child: Obx(
            () => Wrap(
              children: tagController.selectedTags
                  .map((tag) => Chip(
                        label: Text(tag),
                        deleteIcon: Icon(Icons.cancel),
                        onDeleted: () => tagController.toggleTag(tag),
                      ))
                  .toList(),
            ),
          ),
        ),
        SizedBox(height: 10),
        Flexible(
          fit: FlexFit.loose,
          child: DropdownButton<String>(
            hint: Text("Select Activities"),
            items: tagController.availableTags.map((String tag) {
              return DropdownMenuItem<String>(
                value: tag,
                child: Obx(
                  () => Container(
                    width: Get.width * 0.6,
                    child: CheckboxListTile(
                      title: Text(tag),
                      value: tagController.selectedTags.contains(tag),
                      onChanged: (_) => tagController.toggleTag(tag),
                    ),
                  ),
                ),
              );
            }).toList(),
            onChanged: (_) {},
          ),
        ),
      ],
    );
  }
}

// class ChipSelector extends StatelessWidget {
//   const ChipSelector({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final List<String> options = ['Vendor', 'Organizer'];

//     return Wrap(
//       spacing: 12.0,
//       children: options.asMap().entries.map((entry) {
//         final int index = entry.key;
//         final String label = entry.value;

//         return Obx(() => ChoiceChip(
//               label: Text(label),
//               selected: controller.selectedChip.value == index,
//               onSelected: (bool isSelected) {
//                 if (isSelected) controller.selectChip(index);
//               },
//               selectedColor: Get.theme.colorScheme.primary,
//               backgroundColor: Colors.grey.shade200,
//               labelStyle: TextStyle(
//                 color: controller.selectedChip.value == index
//                     ? Colors.white
//                     : Colors.black,
//               ),
//             ));
//       }).toList(),
//     );
//   }
// }
