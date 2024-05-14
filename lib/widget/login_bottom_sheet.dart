import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_state_manager/get_state_manager.dart';

import '../screens/login/login_controller.dart';
import '../utils/colors.dart';
import '../utils/global_toast_controller.dart';

class LoginBottomSheet extends GetWidget {
  const LoginBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          SizedBox(height: 20.h),
          Image.asset(
            'assets/images/ic_poeat_logo.png',
            width: 150.w,
            height: 80.h,
          ),
          Text(
            '로그인이 필요한 서비스입니다',
            style: TextStyle(
              fontSize: 14.sp,
              color: gray600,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 10.h),
          Text(
            'SNS 계정으로 간편하게 로그인하세요',
            style: TextStyle(
              fontSize: 12.sp,
              color: gray500,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 10.h),
          Text(
            '⚡️ 3초만에 가입하기',
            style: TextStyle(
              fontSize: 10.sp,
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 20.h),
          // google
          InkWell(
            onTap: () {
              LoginController.to.signInWithGoogle();
            },
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 10.h),
              width: 300.w,
              decoration: BoxDecoration(
                color: Color(0xfffffff),
                border: Border.all(
                  color: gray400,
                  width: 0.5,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/ic_login_google.png',
                    width: 20.w,
                    height: 20.h,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    '구글로 시작하기',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 10.h),
          // apple
          InkWell(
            onTap: () {
              LoginController.to.signInWithKakao();
            },
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 10.h),
              width: 300.w,
              decoration: BoxDecoration(
                color: Color(0xFFFEE500),
                border: Border.all(
                  color: gray400,
                  width: 0.5,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/ic_login_kakao.png',
                    width: 20.w,
                    height: 20.h,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    '카카오로 시작하기',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 10.h),
          // apple
          InkWell(
            onTap: () {
              //LoginController.to.signInWithApple();
              GlobalToastController.to.showToast('준비중입니다.');
            },
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 10.h),
              width: 300.w,
              decoration: BoxDecoration(
                color: Colors.black,
                border: Border.all(
                  color: gray400,
                  width: 0.5,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/ic_login_apple.png',
                    width: 20.w,
                    height: 20.h,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    '애플로 시작하기',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}