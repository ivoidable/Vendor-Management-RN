import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ViewRegisteredVendorsScreen extends StatelessWidget {
  const ViewRegisteredVendorsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registered Vendors'),
        centerTitle: true,
        backgroundColor: Get.theme.colorScheme.primary,
      ),
    );
  }
}
