import 'package:date_time_picker/date_time_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:vendor/helper/database.dart';

class RegisterScreen extends StatelessWidget {
  RegisterScreen({super.key});

  DateTime dateOfBirth = DateTime.now();
  bool isVendor = false;
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
        padding: EdgeInsets.all(Get.width),
        child: Column(
          children: [
            // Logo Here
            // Name Text Box
            TextField(controller: emailController, keyboardType: TextInputType.emailAddress, maxLength: 255, decoration: const InputDecoration(label: Text("Email Address")),),
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
            Switch(value: isVendor, onChanged: (vendor) {
              isVendor = vendor;
            }),
            const SizedBox(height: 12,),
            // Submit button
            ElevatedButton(onPressed: () {
              DatabaseService().signUp(email: emailController.text, password: passwordController.text, name: nameController.text, dateOfBirth: dateOfBirth, role: isVendor ? 'vendor' : 'user');
            }, child: const Text("Register")),
            const SizedBox(height: 6,),
          ],
        ),
      ),
    );
  }
}