import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:vendor/middleware/auth_middleware.dart';
import 'package:vendor/screen/shared/login_screen.dart';
import 'package:vendor/screen/organizer/main_screen.dart';
import 'package:vendor/screen/shared/register_screen.dart';
import 'package:vendor/screen/shared/splash_screen.dart';
import 'package:vendor/screen/vendor/main_screen.dart';
import 'package:vendor/screen/vendor/onboarding/vendor_onboard_screen.dart';
import 'controller/auth_controller.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
late AuthController authController;
final FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;

@pragma('vm:entry')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Initialize Firebase if needed
  await Firebase.initializeApp();

  // Handle the message, e.g., log it or save data
  print("Handling a background message: ${message.messageId}");
}

const AndroidNotificationChannel channel = AndroidNotificationChannel(
  'high_importance_channel', // id
  'High Importance Notifications', // name
  description: 'This channel is used for important notifications.',
  importance: Importance.high,
);

Future<void> createChannel() async {
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);
}

Future<void> initializeNotifications() async {
  const AndroidInitializationSettings androidInitSettings =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const DarwinInitializationSettings iosInitSettings =
      DarwinInitializationSettings();

  const InitializationSettings initSettings = InitializationSettings(
      android: androidInitSettings, iOS: iosInitSettings);

  await flutterLocalNotificationsPlugin.initialize(
    initSettings,
    onDidReceiveBackgroundNotificationResponse: onSelectNotification,
    onDidReceiveNotificationResponse: onSelectNotification,
  );
  await firebaseMessaging.requestPermission();

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;

    if (notification != null && android != null) {
      flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            channel.id,
            channel.name,
            channelDescription: channel.description,
            icon: '@mipmap/ic_launcher',
          ),
        ),
      );
    }
  });

  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    print('A new onMessageOpenedApp event was published!');
  });
}

Future<void> onSelectNotification(NotificationResponse payload) async {
  // Handle when the user taps on a notification
  print('Notification payload: $payload');
}

Future<void> requestPermissions() async {
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>()
      ?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await createChannel();
  await initializeNotifications();
  await requestPermissions();
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  final dir = await getApplicationDocumentsDirectory();
  Hive.init(dir.path);
  Hive.openBox('settings');
  authController = Get.put(AuthController()); // Initialize UserController
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      defaultTransition: Transition.cupertino,
      title: "Saudi Events",
      initialRoute: '/login',
      theme: ThemeData(
        useMaterial3: true,
        buttonTheme: ButtonThemeData(
          padding: const EdgeInsets.all(12),
          buttonColor: Get.theme.colorScheme.primary,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Get.theme.colorScheme.primary,
          centerTitle: true,
          elevation: 0,
          titleTextStyle: Get.textTheme.titleLarge!.copyWith(color: Colors.white),
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        dividerColor: Get.theme.colorScheme.primary,
        colorScheme: ColorScheme(brightness: Brightness.light, primary: Colors.pink, onPrimary: Colors.pinkAccent, secondary: Colors.cyan, onSecondary: Colors.cyanAccent, error: Colors.red, onError: Colors.redAccent, surface: Colors.white, onSurface: Colors.white),
      ),
      themeMode: ThemeMode.light,
      debugShowCheckedModeBanner: false,
      getPages: [
        GetPage(name: '/splash', page: () => SplashScreen()),
        GetPage(name: '/login', page: () => LoginScreen()),
        GetPage(name: '/register', page: () => RegisterScreen()),
        GetPage(name: '/vendor_onboard', page: () => VendorOnboardScreen()),
        GetPage(name: '/vendor_pricing', page: () => VendorOnboardScreen()),
        GetPage(
          name: '/vendor_main',
          middlewares: [AuthMiddleware('vendor')],
          page: () => VendorMainScreen(),
        ),
        GetPage(
          name: '/user_main',
          middlewares: [AuthMiddleware('attendee')],
          page: () => VendorMainScreen(),
        ),
        GetPage(
          name: '/organizer_main',
          middlewares: [AuthMiddleware('organizer')],
          page: () => OrganizerMainScreen(),
        ),
      ],
    );
  }
}
