import 'package:get/get.dart';
import 'package:vendor/model/user.dart';

class ViewOrganizerController extends GetxController {
  final Organizer organizer;
  RxInt index = 0.obs;

  ViewOrganizerController({
    required this.organizer,
  });

  void changeIndex(int newIndex) {
    index.value = newIndex;
  }
}
