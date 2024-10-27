import 'package:get/get.dart';
import 'package:vendor/helper/database.dart';
import 'package:vendor/main.dart';
import 'package:vendor/model/user.dart';

class OrganizerEditProfileController extends GetxController {
  final Organizer organizer;

  OrganizerEditProfileController(this.organizer);

  // Observables for fields
  var name = ''.obs;
  Rx<DateTime> dateOfBirth = Rx(DateTime.now());
  var email = ''.obs;

  @override
  void onInit() {
    super.onInit();

    // Initialize observables with vendor data
    name.value = organizer.name;
    dateOfBirth.value = organizer.dateOfBirth;
    email.value = organizer.email;
  }

  // Update vendor object with the new data
  void updateVendor() async {
    organizer.name = name.value;
    organizer.dateOfBirth = dateOfBirth.value;
    organizer.email = email.value;

    // For demonstration, print updated vendor data
    DatabaseService().updateUser(authController.uid, organizer.toMap());
    authController.appUser = organizer.toMap();
    print(
        'Updated Vendor: ${organizer.name}, ${organizer.dateOfBirth}, ${organizer.email}');
  }
}
