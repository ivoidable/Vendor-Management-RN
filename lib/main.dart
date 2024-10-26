import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:vendor/middleware/auth_middleware.dart';
import 'package:vendor/screen/shared/login_screen.dart';
import 'package:vendor/screen/organizer/main_screen.dart';
import 'package:vendor/screen/shared/register_screen.dart';
import 'package:vendor/screen/vendor/main_screen.dart';
import 'controller/auth_controller.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

late AuthController authController;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  final dir = await getApplicationDocumentsDirectory();
  Hive.init(dir.path);
  Hive.openBox('settings');
  authController = Get.put(AuthController()); // Initialize UserController
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
        GetPage(
          name: '/vendor_main',
          middlewares: [AuthMiddleware('vendor')],
          page: () => VendorMainScreen(),
        ),
        GetPage(
          name: '/organizer_main',
          middlewares: [AuthMiddleware('organizer')],
          page: () => OrganizerMainScreen(),
        ),
        // GetPage(name: '/moderator_dashboard', page: () => ModeratorDashboard()),
        // GetPage(name: '/admin_dashboard', page: () => AdminDashboard()),
      ],
    );
  }
}
