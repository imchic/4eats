import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../utils/app_routes.dart';
import '../../utils/logger.dart';

class OnBoardingMiddleware extends GetMiddleware {

  @override
  RouteSettings? redirect(String? route) {

    final Future<SharedPreferences> prefs = SharedPreferences.getInstance();

    prefs.then((SharedPreferences prefs) {

      var isFirstAppOpen = prefs.getBool('isFirstInstall');
      if (isFirstAppOpen == null) {
        //
      } else {
        Get.offAndToNamed(AppRoutes.home);
      }

    });

    return null;
  }

}