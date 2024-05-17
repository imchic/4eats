import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:foreats/screens/upload/upload_controller.dart';
import 'package:get/get.dart';

import '../../utils/app_routes.dart';
import '../../widget/base_appbar.dart';

class UploadDoneScreen extends GetView<UploadController> {
  const UploadDoneScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          BaseAppBar(
            title: '동영상 업로드',
          ),
          SizedBox(
            width: 393.w,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    'assets/images/ic_upload_done.svg',
                    width: 48.w,
                    height: 48.h,
                  ),
                  SizedBox(height: 20.h),
                  Text(
                    '업로드 완료',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 20.h),
                  Text(
                    '회원님의 달달한 게시물이 업로드되었습니다!',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Color(0xff9B9B9B),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 20.h),
                ],
              ),
            ),
          ),
          GestureDetector(
            onTap: () async {
              // await FeedController.to.downloadStreamingFolder();
              //FeedController.to.downloadStreamingFolder();
              // Get.offAllNamed(AppRoute.home);
              // HomeController.to.changePage(0);
              Get.offAllNamed(AppRoutes.home);
            },
            child: Container(
              width: 350.w,
              height: 50.h,
              margin: EdgeInsets.only(bottom: 34.h, top: 20.h, left: 20.w, right: 20.w),
              padding: EdgeInsets.all(15.r),
              decoration: ShapeDecoration(
                color: Theme.of(context).colorScheme.secondary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    '확인',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      height: 0,
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

}