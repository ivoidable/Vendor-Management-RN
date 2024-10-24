import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:vendor/helper/database.dart';
import 'package:vendor/model/event.dart';
import 'package:vendor/model/user.dart';

class OrganizerMainController extends GetxController {
  var selectedIndex = 0.obs;

  List<Event> events = [];
  List<Vendor> vendors = [];

  void changeTab(int index) {
    selectedIndex.value = index;
  }

  void scheduleEvent(Organizer organizer, Event event) {
    DatabaseService().scheduleEvent(organizer, event);
  }

  Future<List<Event>> getScheduledEvents(
      Future<DocumentSnapshot<Map<String, dynamic>>?> organizer) async {
    var org =
        Organizer.fromMap((await organizer)!.id, (await organizer)!.data()!);
    events = await DatabaseService().getScheduledEvents(org);
    return events;
  }

  Future<List<Vendor>> getVendors() async {
    vendors = await DatabaseService().getAllVendors();
    return vendors;
  }
}
