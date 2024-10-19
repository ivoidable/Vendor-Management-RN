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
      initialRoute: '/auth',
      getPages: [
        GetPage(name: '/auth', page: () => AuthenticationWrapper()),
        GetPage(name: '/login', page: () => LoginScreen()),
        GetPage(name: '/register', page: () => RegisterScreen()),
        GetPage(name: '/user_main', page: () => const UserMainScreen()),
        GetPage(name: '/vendor_main', page: () => VendorMainScreen()),
        // GetPage(name: '/moderator_dashboard', page: () => ModeratorDashboard()),
        // GetPage(name: '/admin_dashboard', page: () => AdminDashboard()),
      ],
    );
  }
}

class AuthenticationWrapper extends StatelessWidget {
  Future<AppUser?> getUserData() async {
    print("Called");
    var shite = await DatabaseService().getUser(FirebaseAuth.instance.currentUser!.uid);
    if (FirebaseAuth.instance.currentUser != null && shite != null) {
      String uid = FirebaseAuth.instance.currentUser!.uid;
      AppUser user =
          AppUser.fromFirestore((await DatabaseService().getUser(uid))!);
      return user;
    } else if (shite == null) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getUserData(), // Check login status
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: const CircularProgressIndicator()); // Show loading indicator
        }

        if (snapshot.hasData && snapshot.data != null) {
          // If user is logged in, initialize the MainController and go to VendorMainScreen
          switch (snapshot.data!.role) {
            case 'vendor':
              Get.put(VendorMainController());
              //FIXME: The app shows errors when you reload or sign in, my guess its because of the double checking of authentication, remove one mf
              return VendorMainScreen();
            // case 'moderator':

            //   break;
            // case 'admin':

            //   break;
            default:
              return const UserMainScreen();
          }
        } else {
          // Navigate to Login Screen if not authenticated
          return LoginScreen();
        }
      },
    );
  }
}
