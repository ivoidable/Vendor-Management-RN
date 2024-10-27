import 'package:get/get.dart';
import 'package:vendor/helper/database.dart';
import 'package:vendor/main.dart';
import 'package:vendor/model/user.dart';

class VendorEditProfileController extends GetxController {
  final Vendor vendor;

  VendorEditProfileController(this.vendor);

  // Observables for fields
  var name = ''.obs;
  Rx<DateTime> dateOfBirth = Rx(DateTime.now());
  var email = ''.obs;
  var businessName = ''.obs;

  @override
  void onInit() {
    super.onInit();

    // Initialize observables with vendor data
    name.value = vendor.name;
    dateOfBirth.value = vendor.dateOfBirth;
    email.value = vendor.email;
    businessName.value = vendor.businessName;
  }

  // Update vendor object with the new data
  void updateVendor() async {
    vendor.name = name.value;
    vendor.dateOfBirth = dateOfBirth.value;
    vendor.email = email.value;
    vendor.businessName = businessName.value;

    // For demonstration, print updated vendor data
    DatabaseService().updateUser(authController.uid, vendor.toMap());
    authController.appUser = vendor.toMap();
    print(
        'Updated Vendor: ${vendor.name}, ${vendor.dateOfBirth}, ${vendor.email}, ${vendor.businessName}');
  }
}
