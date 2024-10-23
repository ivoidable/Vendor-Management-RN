import 'package:get/get.dart';

class CreateEventController extends GetxController {
  var name = ''.obs;
  var description = ''.obs;
  var vendorFee = 0.0.obs;
  var userFee = 0.0.obs;
  var date = DateTime.now().obs;
  var maxVendors = 0.obs;
  var images = <String>[].obs;
  var applications = <String>[].obs;

  void setDate(DateTime pickedDate) {
    date.value = pickedDate;
  }

  void addImage(String url) {
    images.add(url);
  }

  void addApplication(String applicant) {
    applications.add(applicant);
  }
}
