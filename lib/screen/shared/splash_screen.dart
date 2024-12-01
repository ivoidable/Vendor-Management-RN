import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Expanded(
      child: Container(
        color: Get.theme.colorScheme.primary,
      ),
    ));
  }
}
