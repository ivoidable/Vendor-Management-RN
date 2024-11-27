import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:vendor/helper/database.dart';
import 'package:vendor/main.dart';
import 'package:vendor/model/review.dart';
import 'package:vendor/model/user.dart';

class ViewOrganizerController extends GetxController {
  final Organizer organizer;
  final String eventId;
  RxInt rating = 5.obs;
  RxInt index = 0.obs;
  RxList<XFile> images = <XFile>[].obs;

  void updateRating(int newRating) {
    rating.value = newRating;
  }

  ViewOrganizerController({
    required this.organizer,
    required this.eventId,
  });

  @override
  void onInit() async {
    super.onInit();
  }

  var image = Rxn<XFile>(); // Rxn allows null values
  var textInput = ''.obs;
  var dataList = <String>[].obs;

  final ImagePicker _picker = ImagePicker();

  Future<void> pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      image.value = pickedFile;
    }
  }

  void updateText(String text) {
    textInput.value = text;
  }

  void submitData() {
    if (textInput.isNotEmpty && image.value != null) {
      DatabaseService().reviewOrganizer(
        Review(
          id: '',
          reviewerId: authController.uid,
          organizerId: organizer.id,
          eventId: eventId,
          review: textInput.value,
          rating: rating.value,
          imagesUrls: [],
        ),
        organizer.id,
        image.value!,
      );
      textInput.value = '';
      image.value = null;
      Get.back();
    } else {
      Get.snackbar('Error', 'Please fill in all fields');
    }
  }

  void changeIndex(int newIndex) {
    index.value = newIndex;
  }
}
