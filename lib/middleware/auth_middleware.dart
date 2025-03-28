import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:vendor/controller/auth_controller.dart';

class AuthMiddleware extends GetMiddleware {
  final String requiredRole;

  AuthMiddleware(this.requiredRole);

  @override
  RouteSettings? redirect(String? route) {
    final AuthController userController = Get.find<AuthController>();

    if (userController.userRole.value != requiredRole) {
      return RouteSettings(
          name: '/login'); // Redirect to login if role doesn't match
    }
    return null;
  }
}
