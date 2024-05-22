import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../screens/feed/feed_controller.dart';
import '../screens/upload/upload_controller.dart';
import '../utils/app_routes.dart';
import '../utils/colors.dart';
import '../utils/global_toast_controller.dart';

class BaseAppBar extends GetWidget implements PreferredSizeWidget {
  // title
  final Color color;
  final String title;
  final bool? centerTitle;
  final bool? leading;
  final bool? actions;
  final Function? callback;

  const BaseAppBar(
      {super.key,
      this.color = Colors.transparent,
      required this.title,
      this.centerTitle = false,
      this.leading = false,
      this.actions = false,
      this.callback
      });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      shadowColor: Colors.transparent,
      title: Container(
        margin: EdgeInsets.only(left: 10.w),
        child: Container(
          margin: EdgeInsets.only(top: 4.w),
          child: Text(
            textAlign: TextAlign.center,
            title,
            style: TextStyle(
              color: gray800,
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
      centerTitle: centerTitle,
      leading: leading == true
          ? Container(
              padding: EdgeInsets.only(left: 10.w),
              child: IconButton(
                icon: Icon(Icons.arrow_back_ios, color: gray800, size: 14.sp),
                onPressed: () {
                  print('leading');
                  if (callback != null) {
                    callback!();
                  } else {
                    Get.back();
                  }
                },
              ),
            )
          : null,
      actions: [
        if (actions == true)
          Container(
            padding: EdgeInsets.only(right: 10.w),
            child: IconButton(
              icon: Icon(Icons.arrow_forward, color: gray800, size: 16.sp),
              onPressed: () {
                if (UploadController.to.selectedList.isNotEmpty) {
                  Get.toNamed(AppRoutes.uploadRegister, preventDuplicates: false);
                } else {
                  GlobalToastController.to.showToast('동영상을 선택해주세요.');
                }
              },
            ),
          ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(56.0);
}
