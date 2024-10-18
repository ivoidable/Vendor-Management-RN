import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

class RegisterScreen extends StatelessWidget {
  RegisterScreen({super.key});

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
            // Email Text Box
            TextField(controller: emailController, keyboardType: TextInputType.emailAddress, maxLength: 255, decoration: InputDecoration(label: Text("Email Address")),),
            SizedBox(height: 6,),
            // Password Text Box
            TextField(controller: passwordController, maxLength: 64, obscureText: true, decoration: InputDecoration(label: Text("Password")),),
            SizedBox(height: 12,),
            // Submit button
            ElevatedButton(onPressed: () {

              //TODO: Implement Login Logic

            }, child: Text("Register")),
            SizedBox(height: 6,),
          ],
        ),
      ),
    );
  }
}