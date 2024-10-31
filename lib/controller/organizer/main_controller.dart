import 'package:get/get.dart';
import 'package:vendor/helper/database.dart';
import 'package:vendor/main.dart';
import 'package:vendor/model/event.dart';
import 'package:vendor/model/user.dart';

class OrganizerMainController extends GetxController {
  var selectedIndex = 0.obs;

  var events = <Event>[].obs;
  var vendors = <Vendor>[].obs;
  late Organizer organizerz =
      Organizer.fromMap(authController.uid, authController.appUser);

  @override
  void onInit() {
    super.onInit();
    onRefresh();
  }

  void changeTab(int index) {
    selectedIndex.value = index;
  }

  void scheduleEvent(Organizer organizer, Event event) {
    DatabaseService().scheduleEvent(organizer, event);
  }

  Future<void> getEvents() async {
    events.value = await DatabaseService().getScheduledEvents(organizerz);
  }

  Future<void> onRefresh() {
    return Future.wait([getEvents(), getVendors()]);
  }

  Future<void> getVendors() async {
    vendors.value = await DatabaseService().getAllVendors();
  }
}
