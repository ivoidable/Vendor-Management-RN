import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vendor/controller/vendor/main_controller.dart';
import 'package:vendor/main.dart';

class AuthController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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
      userRole.value = ''; // Reset role on sign out
      Get.offAllNamed('/login');
    } else {
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(user.uid).get();
      userRole.value = userDoc['role'] ?? 'signed_out';
      _navigateBasedOnRole(userRole.value); // Navigate based on role
    }
  }

  void _navigateBasedOnRole(String role) {
    switch (role) {
      case 'vendor':
      Get.put(VendorMainController());
        Get.offAllNamed('/vendor_main');
        break;
      case 'moderator':
        Get.offAllNamed('/moderator_main');
        break;
      case 'admin':
        Get.offAllNamed('/admin_main');
        break;
      case 'normal_user':
      //TODO: add user controller
        Get.offAllNamed('/user_main');
        break;
      default:
        Get.offAll(AuthenticationWrapper());
        break;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
