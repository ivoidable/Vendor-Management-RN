import 'package:get/get.dart';
import 'package:vendor/helper/database.dart';
import 'package:vendor/model/event.dart';

class VendorMainController extends GetxController {
  var selectedIndex = 0.obs;

  List<Event> events = [];

  final tabs = [
    // VendorEventsTab(),
    // VendorMessagesTab(),
    // VendorNotificationsTab(),
    // VendorProfileTab(),
  ];

  void changeTab(int index) {
    selectedIndex.value = index;
  }



  //TODO: Add Data Fetching Methods & Refresh Method
  Future<void> getEvents() async {
    events = await DatabaseService().getAllEvents();
  }
}
