import 'package:get/get.dart';
import 'package:vendor/helper/database.dart';
import 'package:vendor/model/event.dart';
import 'package:vendor/model/user.dart';
import 'package:vendor/screen/vendor/tabs/vendor_tabs.dart';

class VendorMainController extends GetxController {
  var selectedIndex = 0.obs;

  List<Event> events = [];
  List<Vendor> vendors = [];

  final tabs = [
    VendorEventsTab(),
    VendorVendorsTab(),
    VendorNotificationsTab(),
    VendorProfileTab(),
  ];

  void changeTab(int index) {
    selectedIndex.value = index;
  }

  Future<List<Event>> getEvents() async {
    events = await DatabaseService().getAllEvents();
    return events;
  }

  Future<List<Vendor>> getVendors() async {
    vendors = await DatabaseService().getAllVendors();
    return vendors;
  }
}
