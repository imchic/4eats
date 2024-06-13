import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:foreats/screens/notification/notifications_controller.dart';
import 'package:get/get.dart';

import '../screens/feed/feed_controller.dart';
import '../screens/upload/upload_controller.dart';
import '../utils/app_routes.dart';
import '../utils/colors.dart';
import '../utils/toast_controller.dart';

class BaseAppBar extends GetWidget implements PreferredSizeWidget {
  // title
  final Color color;
  final String title;
  final bool? centerTitle;
  final bool? leading;
  final bool? actions;
  final bool? notification;
  final bool? customTitle;
  final Function? callback;

  const BaseAppBar(
      {super.key,
      this.color = Colors.transparent,
      required this.title,
      this.centerTitle = false,
      this.leading = false,
      this.actions = false,
      this.notification = false,
      this.customTitle = false,
      this.callback});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shadowColor: Colors.transparent,
      title: Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              //margin: EdgeInsets.only(top: 4.w),
              padding: customTitle == true
                  ? EdgeInsets.only(left: 0.w)
                  : EdgeInsets.only(left: 10.w),
              child: Text(
                textAlign: TextAlign.center,
                title,
                style: TextStyle(
                  color:
                      Get.isDarkMode ? Colors.white : Colors.black,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            notification == true
                ? Obx(() => Container(
                      margin: EdgeInsets.only(right: 10.w),
                      child: InkWell(
                        onTap: () {
                          Get.toNamed(AppRoutes.notification);
                        },
                        child: FutureBuilder(
                          future: NotificationsController.to.countNotification(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return Container();
                            } else {
                              return snapshot.data == 0
                                  ? SvgPicture.asset(
                                      'assets/images/ic_bell.svg',
                                      colorFilter: ColorFilter.mode(
                                        Get.isDarkMode ? Colors.white : Colors.black,
                                        BlendMode.srcIn,
                                      ),
                                      width: 20.w,
                                    )
                                  : Stack(
                                      children: [
                                        Container(
                                          margin: EdgeInsets.only(top: 6.w),
                                          child: SvgPicture.asset(
                                            'assets/images/ic_bell.svg',
                                            colorFilter: ColorFilter.mode(
                                              Get.isDarkMode ? Colors.white : Colors.black,
                                              BlendMode.srcIn,
                                            ),
                                            width: 20.w,
                                          ),
                                        ),
                                        Positioned(
                                          right: 0,
                                          top: 0,
                                          child: Container(
                                            padding: EdgeInsets.all(2.w),
                                            decoration: BoxDecoration(
                                              color: Colors.red,
                                              shape: BoxShape.circle,
                                            ),
                                            child: Text(
                                              snapshot.data.toString(),
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 10.sp,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                            }
                          },
                        ),
                      ),
                    ),
                )
                : Container(),
          ],
        ),
      ),
      centerTitle: centerTitle,
      leading: leading == true
          ? Container(
              padding: EdgeInsets.only(left: 10.w),
              child: IconButton(
                icon: Icon(Icons.arrow_back_ios, color: Get.isDarkMode ? Colors.white : Colors.black, size: 14.sp),
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
                  Get.toNamed(AppRoutes.uploadRegister,
                      preventDuplicates: false);
                } else {
                  ToastController.to.showToast('동영상을 선택해주세요.');
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
