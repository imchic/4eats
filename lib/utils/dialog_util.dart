import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:lottie/lottie.dart';

import 'colors.dart';

class DialogUtil {

  static void showLoadingDialog() {
    Get.dialog(
      Center(
        child: Lottie.asset(
          'assets/lottie/loading.json',
          width: 100.w,
          height: 100.h,
          fit: BoxFit.fill,
        ),
      ),
      barrierDismissible: false,
    );
  }

  static void hideLoadingDialog() {
    Get.back();
  }

  static void showAlertDialog({
    required String title,
    required String message,
    required Function onConfirm,
    required Function onCancel,
  }) {
    Get.defaultDialog(
      title: title,
      titleStyle: TextStyle(
        fontSize: 16.sp,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
      content: Text(
        message,
        style: TextStyle(
          fontSize: 14.sp,
          color: Colors.black,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            onCancel();
            Get.back();
          },
          child: Text(
            '취소',
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.black,
            ),
          ),
        ),
        TextButton(
          onPressed: () {
            onConfirm();
            Get.back();
          },
          child: Text(
            '확인',
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.black,
            ),
          ),
        ),
      ],
    );
  }

  static void showSnackBar({
    required String message,
    required Color color,
  }) {
    Get.snackbar(
      '',
      message,
      backgroundColor: color,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  static void showSuccessSnackBar({
    required String message,
  }) {
    showSnackBar(
      message: message,
      color: Theme.of(Get.context!).primaryColor,
    );
  }

  static void showErrorSnackBar({
    required String message,
  }) {
    showSnackBar(
      message: message,
      color: Theme.of(Get.context!).errorColor,
    );
  }

  /// 이메일 중복 로그인 정보 확인 다이얼로그
  static void accountExistsWithDifferentCredential({
    required String email,
    required Function onConfirm,
  }) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.r),
        ),
        title: Text('중복된 로그인 정보', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp, color: Colors.black)),
        content:
        //Text('이미 가입된 이메일입니다 \n ${userModel.value.email} \n ${doc.data()['loginType']} 로 가입된 계정이 존재합니다.', style: TextStyle(fontSize: 14.sp, color: Colors.black)),
        Container(
          width: Get.width * 0.5,
          height: Get.height * 0.3,
          child: Column(
            children: [
              Lottie.asset('assets/lottie/id_already.json', width: 150.w, height: 150.h),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: '이미 가입된 이메일입니다 \n',
                      style: TextStyle(fontSize: 14.sp, color: Colors.black),
                    ),
                    TextSpan(
                      text: maskEmail('$email \n'),
                      style: TextStyle(fontSize: 14.sp, color: Theme.of(Get.context!).colorScheme.primary),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
              //Get.offAndToNamed(AppRoutes.home);
            },
            child: Text('확인', style: TextStyle(fontSize: 14.sp, color: Theme.of(Get.context!).colorScheme.primary)),
          ),
          TextButton(
            onPressed: () {
              Get.back();
            },
            child: Text('취소', style: TextStyle(fontSize: 14.sp, color: gray500)),
          ),
        ],
      ),
    );
  }
}

// 이메일 주소 마스킹
String maskEmail(String email) {
  String maskedEmail = email.replaceAll(RegExp(r'(?<=.{3}).(?=[^@]*?.@)'), '*');
  return maskedEmail;
}