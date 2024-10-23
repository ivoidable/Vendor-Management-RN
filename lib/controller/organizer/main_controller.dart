import 'package:get/get.dart';
import 'package:vendor/helper/database.dart';
import 'package:vendor/model/event.dart';
import 'package:vendor/model/user.dart';
import 'package:vendor/screen/organizer/tabs/organizer_tabs.dart';

class OrganizerMainController extends GetxController {
  var selectedIndex = 0.obs;

  List<Event> events = [];
  List<Vendor> vendors = [];

  final tabs = [
    OrganizerEventsTab(),
    OrganizerVendorsTab(),
    OrganizerNotificationsTab(),
    OrganizerProfileTab(),
  ];

  void changeTab(int index) {
    selectedIndex.value = index;
  }

  void scheduleEvent(Organizer organizer, Event event) {
    DatabaseService().scheduleEvent(organizer, event);
  }

  Future<List<Event>> getScheduledEvents(Future<Organizer> organizer) async {
    events = await DatabaseService().getScheduledEvents(await organizer);
    return events;
  }

  Future<List<Vendor>> getVendors() async {
    vendors = await DatabaseService().getAllVendors();
    return vendors;
  }
}
