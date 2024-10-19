import 'package:get/get.dart';

class VendorMainController extends GetxController {
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
