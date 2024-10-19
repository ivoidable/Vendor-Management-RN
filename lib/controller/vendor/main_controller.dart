import 'package:get/get.dart';

class MainController extends GetxController {
  var selectedIndex = 0.obs;

  final tabs = [
    // VendorEventsTab(),
    // VendorMessagesTab(),
    // VendorNotificationsTab(),
    // VendorProfileTab(),
  ];

  void changeTab(int index) {
    selectedIndex.value = index;
  }
}
