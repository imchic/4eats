import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:foreats/home/home_controller.dart';
import 'package:foreats/model/notification_model.dart';
import 'package:foreats/utils/colors.dart';
import 'package:foreats/utils/dialog_util.dart';
import 'package:foreats/utils/logger.dart';
import 'package:foreats/utils/text_style.dart';
import 'package:foreats/widget/base_appbar.dart';
import 'package:get/get.dart';

import 'notifications_controller.dart';

class NotificationsScreen extends GetView<NotificationsController> {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(NotificationsController());

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const BaseAppBar(
        title: '알림',
        leading: true,
      ),
      body: FutureBuilder(
        future: controller.fetchNotification(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: DialogUtil().buildLoadingDialog(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          final List<NotificationModel>? notifications = snapshot.data;

          return notifications == null || notifications.isEmpty
              ? Center(
                  child: Text(
                    '알림이 없어요 😢',
                    style: TextStyleUtils.bodyTextStyle(
                      fontSize: 10.sp,
                      color: gray800
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () async {
                    await controller.fetchNotification();
                  },
                child: ListView.builder(
                    itemCount: notifications.length,
                    itemBuilder: (context, index) {
                      return _buildNotificationItem(notifications[index]);
                    },
                  ),
              );
        },
      ),
    );
  }

  Widget _buildNotificationItem(
    NotificationModel notification,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 16.w,
        vertical: 8.h,
      ),
      child: Row(
        children: [
          CachedNetworkImage(
            imageUrl: notification.userPhotoUrl ?? '',
            imageBuilder: (context, imageProvider) => Container(
              width: 30.w,
              height: 30.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                  image: imageProvider,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            placeholder: (context, url) => Container(
              width: 30.w,
              height: 30.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey[200],
              ),
            ),
            errorWidget: (context, url, error) => Icon(Icons.error),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  notification.type ?? '',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  //notification.createdAt.toString() ?? '',
                  HomeController.to.timeAgo(
                    notification.createdAt ?? DateTime.now(),
                  ),
                  style: TextStyleUtils.bodyTextStyle(
                    color: Colors.grey,
                    fontSize: 9.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  notification.body ?? '',
                  style: TextStyleUtils.bodyTextStyle(
                    fontSize: 10.sp,
                    color: gray800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
