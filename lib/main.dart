import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vendor/controller/vendor/main_controller.dart';
import 'package:vendor/helper/database.dart';
import 'package:vendor/model/user.dart';
import 'package:vendor/screen/login_screen.dart';
import 'package:vendor/screen/register_screen.dart';
import 'package:vendor/screen/user/main_screen.dart';
import 'package:vendor/screen/vendor/main_screen.dart';
import 'controller/user_controller.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  Get.put(UserController()); // Initialize UserController
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      defaultTransition: Transition.cupertino,
      title: "Vendor Management App",
      initialRoute: '/login',
      getPages: [
        GetPage(name: '/login', page: () => LoginScreen()),
        GetPage(name: '/register', page: () => RegisterScreen()),
        GetPage(name: '/user_main', page: () => UserMainScreen()),
        GetPage(name: '/vendor_main', page: () => VendorMainScreen()),
        // GetPage(name: '/moderator_dashboard', page: () => ModeratorDashboard()),
        // GetPage(name: '/admin_dashboard', page: () => AdminDashboard()),
      ],
    );
  }
}

class AuthenticationWrapper extends StatelessWidget {
  Future<AppUser?> getUserData() async {
    if (FirebaseAuth.instance.currentUser != null) {
      String uid = FirebaseAuth.instance.currentUser!.uid;
      AppUser user =
          AppUser.fromFirestore((await DatabaseService().getUser(uid))!);
      return user;
    } else {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getUserData(), // Check login status
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator(); // Show loading indicator
        }

        if (snapshot.hasData && snapshot.data != null) {
          // If user is logged in, initialize the MainController and go to VendorMainScreen
          switch (snapshot.data!.role) {
            case 'vendor':
              Get.put(VendorMainController());
              return VendorMainScreen();
            // case 'moderator':

            //   break;
            // case 'admin':

            //   break;
            default:
              return UserMainScreen();
          }
        } else {
          // Navigate to Login Screen if not authenticated
          return LoginScreen();
        }
      },
    );
  }
}
