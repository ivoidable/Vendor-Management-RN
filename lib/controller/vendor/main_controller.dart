import 'package:get/get.dart';
import 'package:vendor/helper/database.dart';
import 'package:vendor/model/event.dart';
import 'package:vendor/model/user.dart';

class VendorMainController extends GetxController {
  var selectedIndex = 0.obs;

  var events = <Event>[].obs;
  var vendors = <Vendor>[].obs;

  void changeTab(int index) {
    selectedIndex.value = index;
  }

  Future<void> getEvents() async {
    events.value = await DatabaseService().getAllEvents();
  }

  Future<void> onRefresh() {
    return Future.wait([getEvents(), getVendors()]);
  }

  Future<void> getVendors() async {
    vendors.value = await DatabaseService().getAllVendors();
  }
}
