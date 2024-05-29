import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:foreats/utils/colors.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../../utils/app_routes.dart';
import '../../utils/dialog_util.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 2000), () {
      Get.offNamed(AppRoutes.onboarding);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          SizedBox(
            width: 1.sw,
            height: 1.sh - 150.h,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                    '맛있는 순간, 맛집의 숨을 보석을 찾아서',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w800,
                      color: gray500,
                      fontFamily: 'Pretendard'
                    )
                ),
                SizedBox(height: 20.h),
                Image.asset(
                  'assets/images/ic_foreat_new_logo.png',
                  width: 100.w,
                  height: 100.h,
                ),
                //SizedBox(height: 10.h),
              ],
            ),
          ),
          DialogUtil().buildLoadingDialog(),
          Text(
            '현재 당신 주변에 핫플, 맛집 정보를 찾아보세요!',
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w400,
              color: gray600,
              fontFamily: 'Pretendard'
            ),
          ),
        ],
      ),
    );
  }
}
