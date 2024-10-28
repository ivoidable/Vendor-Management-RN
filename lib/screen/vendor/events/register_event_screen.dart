import 'package:flutter/material.dart';

class RegisterEventScreen extends StatelessWidget {
  const RegisterEventScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.amber,
        centerTitle: true,
        title: const Text('Register Event'),
      ),
      body: const Center(
        child: Text('Register Event'),
      ),
    );
  }
}
