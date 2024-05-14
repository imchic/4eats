import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../utils/app_routes.dart';

class OnBoardingMiddleware extends GetMiddleware {

  @override
  RouteSettings? redirect(String? route) {

    final Future<SharedPreferences> prefs = SharedPreferences.getInstance();
    final logger = Logger();

    prefs.then((SharedPreferences prefs) {

      logger.i('OnBoardingMiddleware redirect prefs: ${prefs.getBool('isFirstAppOpen')}');

      var isFirstAppOpen = prefs.getBool('isFirstAppOpen');
      if (isFirstAppOpen == null) {
        //
      } else {
        Get.offAndToNamed(AppRoutes.home);
      }

    });

    return null;
  }

}