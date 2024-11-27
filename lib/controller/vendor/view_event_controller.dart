import 'package:get/get.dart';
import 'package:vendor/helper/database.dart';
import 'package:vendor/main.dart';
import 'package:vendor/model/event.dart';

class ViewEventController extends GetxController {
  Rx<Event> event;
  Application? application;
  // int? applicationsCount;

  ViewEventController(this.event, this.application);

  @override
  void onInit() async {
    // applicationsCount = await DatabaseService().getAppliedVendorsCount(event.value.id);
    var res = await DatabaseService().getApplication(authController.uid, event.value.id);
    if (res != null) application = res;
    super.onInit();
  }
}
