import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SettingsController extends GetxController {
  late RxBool isNotified = false.obs;
  late Locale language;
  void changeIsNotified(bool value) {
    isNotified.value = value;
    update();
  }

  void changeLanguage(Locale locale) {
    language = locale;
    update();
  }
}
