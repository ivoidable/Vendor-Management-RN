import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vendor/screen/shared/login_screen.dart';

class AuthController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String uid = "";
  Rxn<User?> firebaseUser = Rxn<User?>();
  RxString userRole = ''.obs; // Observes role changes

  @override
  void onInit() {
    firebaseUser.bindStream(_auth.authStateChanges());
    ever(firebaseUser, _setUserRole); // Listen to auth changes and update role
    super.onInit();
  }

  Future<void> _setUserRole(User? user) async {
    if (user == null) {
      uid = '';
      userRole.value = ''; // Reset role on sign out
      Get.offAllNamed('/login');
    } else {
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(user.uid).get();
      uid = userDoc.id;
      debugPrint(uid);
      userRole.value = userDoc['role'] ?? 'signed_out';
      _navigateBasedOnRole(userRole.value); // Navigate based on role
    }
  }

  void _navigateBasedOnRole(String role) {
    switch (role) {
      case 'vendor':
        debugPrint("Running As Vendor");
        Get.offAllNamed('/vendor_main');
        break;
      case 'organizer':
        debugPrint("Running As Organizer");
        Get.offAllNamed('/organizer_main');
        break;
      case 'user':
        debugPrint("Running As User");
        Get.offAllNamed('/user_main');
        break;
      case 'admin':
        Get.offAllNamed('/admin_main');
        break;
      default:
        Get.offAll(LoginScreen());
        break;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
