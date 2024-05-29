import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:foreats/utils/dialog_util.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

import '../../utils/app_routes.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 1000), () {
      Get.offNamed(AppRoutes.splash);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(child: DialogUtil().buildLoadingDialog());
  }
}
