import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vendor/helper/database.dart';
import 'package:vendor/main.dart';

class VendorOnboardScreen extends StatelessWidget {
  VendorOnboardScreen({super.key});

  DateTime dateOfBirth = DateTime.now();
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController businessNameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.amber,
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
            // Submit button
            ElevatedButton(
              onPressed: () {
                print(authController.appUser);
                DatabaseService().updateUser(
                  authController.uid,
                  {
                    'business_name': businessNameController.text,
                    'phone_number': phoneNumberController.text,
                  },
                );
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
//               selectedColor: Colors.amber,
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
