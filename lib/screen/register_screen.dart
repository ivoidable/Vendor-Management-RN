import 'package:date_time_picker/date_time_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:vendor/helper/database.dart';


class RegisterController extends GetxController {
  var isVendor = false.obs;
}

class RegisterScreen extends StatelessWidget {
  RegisterScreen({super.key});

  final RegisterController controller = Get.put(RegisterController());

  DateTime dateOfBirth = DateTime.now();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register'),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: Get.width/8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo Here
            // Name Text Box
            TextField(controller: nameController, keyboardType: TextInputType.name, maxLength: 64, decoration: const InputDecoration(label: Text("Full Name")),),
            const SizedBox(height: 6,),
            // Email text Box
            TextField(controller: emailController, keyboardType: TextInputType.emailAddress, maxLength: 255, decoration: const InputDecoration(label: Text("Email Address")),),
            const SizedBox(height: 6,),
            // Password Text Box
            TextField(controller: passwordController, maxLength: 64, obscureText: true, decoration: const InputDecoration(label: Text("Password")),),
            const SizedBox(height: 6,),
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
            const SizedBox(height: 6,),
            Switch(value: controller.isVendor.value, onChanged: (vendor) {
              print(vendor);
              controller.isVendor.value = vendor;
            },
            ),
            const SizedBox(height: 12,),
            // Submit button
            ElevatedButton(onPressed: () {
              DatabaseService().signUp(email: emailController.text, password: passwordController.text, name: nameController.text, dateOfBirth: dateOfBirth, role: controller.isVendor.value ? 'vendor' : 'user');
            }, child: const Text("Register")),
            const SizedBox(height: 6,),
          ],
        ),
      ),
    );
  }
}