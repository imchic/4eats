import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class ToastController extends GetxController {
  static ToastController get to => Get.find();

  final RxBool isShowToast = false.obs;
  final RxString toastMessage = ''.obs;

  // show
  Future<void> showToast(String message) async {

    // 중복제거
    if (isShowToast.value) {
      await hideToast();
    }

    isShowToast.value = true;
    toastMessage.value = message;

    Get.snackbar(
      '알림',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.black.withOpacity(0.8),
      colorText: Colors.white,
      margin: EdgeInsets.only(bottom: 20.h, left: 20.w, right: 20.w),
      borderRadius: 10.r,
      duration: Duration(milliseconds: 800),
    );

    isShowToast.value = false;

  }

  // error
  Future<void> showErrorToast(String message) async {
    isShowToast.value = true;
    toastMessage.value = message;

    Get.snackbar(
      '알림',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      margin: EdgeInsets.only(bottom: 20.h, left: 20.w, right: 20.w),
      borderRadius: 10.r,
      duration: Duration(milliseconds: 800),
    );

    isShowToast.value = false;
  }

  // hide
  Future<void> hideToast() async {
    isShowToast.value = false;
  }
}
