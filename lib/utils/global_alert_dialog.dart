import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class GlobalAlertDialog extends GetxController {

  static void showToast(String message) {
    Get.snackbar(
      '알림',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.black.withOpacity(0.8),
      colorText: Colors.white,
      margin: EdgeInsets.only(bottom: 20.h, left: 20.w, right: 20.w),
      borderRadius: 10.r,
      duration: Duration(seconds: 1),
    );
  }

  static void alertDialog(BuildContext context, String title, String message) {
    showCupertinoDialog(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            CupertinoDialogAction(
              child: Text('확인'),
              onPressed: () {
                Get.back();
              },
            ),
          ],
        );
      },
    );
  }

  static void confirmDialog(BuildContext context, String title, String message, Function() onConfirm) {
    showCupertinoDialog(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            CupertinoDialogAction(
              child: Text('확인'),
              onPressed: () {
                onConfirm();
                Get.back();
              },
            ),
            CupertinoDialogAction(
              child: Text('취소'),
              onPressed: () {
                Get.back();
              },
            ),
          ],
        );
      },
    );
  }
}