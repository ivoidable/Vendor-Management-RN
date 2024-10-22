import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vendor/controller/vendor/main_controller.dart';
import 'package:vendor/helper/database.dart';
import 'package:vendor/model/user.dart';
import 'package:vendor/screen/login_screen.dart';
import 'package:vendor/screen/organizer/main_screen.dart';
import 'package:vendor/screen/register_screen.dart';
import 'package:vendor/screen/user/main_screen.dart';
import 'package:vendor/screen/vendor/main_screen.dart';
import 'controller/user_controller.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  Get.put(AuthController()); // Initialize UserController
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      defaultTransition: Transition.cupertino,
      title: "Vendor Management App",
      initialRoute: '/login',
      getPages: [
        GetPage(name: '/login', page: () => LoginScreen()),
        GetPage(name: '/register', page: () => RegisterScreen()),
        GetPage(name: '/user_main', page: () => const UserMainScreen()),
        GetPage(name: '/vendor_main', page: () => VendorMainScreen()),
        GetPage(name: '/organizer_main', page: () => OrganizerMainScreen()),
        // GetPage(name: '/moderator_dashboard', page: () => ModeratorDashboard()),
        // GetPage(name: '/admin_dashboard', page: () => AdminDashboard()),
      ],
    );
  }
}
