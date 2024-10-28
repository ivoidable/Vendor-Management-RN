import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:vendor/helper/database.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: Get.width / 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo Here
            // Email Text Box
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              maxLength: 255,
              decoration: InputDecoration(label: Text("Email Address")),
            ),
            // Password Text Box
            TextField(
              controller: passwordController,
              maxLength: 64,
              obscureText: true,
              decoration: InputDecoration(label: Text("Password")),
            ),
            // Submit button
            ElevatedButton(
              onPressed: () {
                DatabaseService()
                    .signIn(emailController.text, passwordController.text);
              },
              child: Text("Login"),
            ),
            SizedBox(
              height: 18,
            ),
            OutlinedButton(
              onPressed: () {
                Get.offNamed('/register');
              },
              child: Text("Register"),
            ),
          ],
        ),
      ),
    );
  }
}
