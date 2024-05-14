import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../../utils/app_routes.dart';
import '../../utils/colors.dart';
import '../../widget/base_appbar.dart';
import '../biz/biz_controller.dart';
import '../feed/feed_controller.dart';
import '../login/login_controller.dart';
import '../login/user_store.dart';
import 'mypage_controller.dart';

class MyPageScreen extends GetView<MyPageController> {
  const MyPageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(LoginController());
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: BaseAppBar(
        title: '마이페이지',
      ),
      body: Column(
        children: [
          Obx(() {
            if (UserStore.to.isLoggedIn) {
              return _buildMyProfileInfo(context);
            } else {
              return Container();
            }
          }),
          Expanded(
            child:
              _buildMyFeedContainer(context),
            ),
        ],
      ),
    );

  }

  // 내 정보
  Widget _buildMyProfileInfo(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.r),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CachedNetworkImage(
                imageUrl: UserStore.to.userProfile.photoUrl ?? '',
                imageBuilder: (context, imageProvider) => Container(
                  width: 40.w,
                  height: 40.h,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: imageProvider,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                placeholder: (context, url) => Container(
                  width: 40.w,
                  height: 40.h,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey[200],
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  width: 44.w,
                  height: 44.h,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey[200],
                  ),
                  child: Icon(
                    Icons.error,
                    color: Colors.red,
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      UserStore.to.userProfile.id ?? '',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onBackground,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        height: 0,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 14.w),
              InkWell(
                onTap: () {
                  Get.toNamed(AppRoutes.settings);
                },
                child: Container(
                  width: 24.w,
                  height: 24.h,
                  margin: EdgeInsets.only(right: 0.w),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SvgPicture.asset(
                        'assets/images/ic_settings.svg',
                        width: 20.w,
                        height: 20.h,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Container(
            width: 0.9.sw,
            height: 50.h,
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  // Theme.of(context).colorScheme.primary,
                  // Theme.of(context).colorScheme.secondary,
                  // Theme.of(context).colorScheme.secondary,
                  Color(0xff536DFE),
                  Color(0xff6A3DE8),
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(5.r),
              shape: BoxShape.rectangle,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        SvgPicture.asset(
                          'assets/images/ic_payment_card.svg',
                          width: 20.w,
                          height: 20.h,
                          colorFilter: ColorFilter.mode(
                            Theme.of(context).colorScheme.onPrimary,
                            BlendMode.srcIn,
                          ),
                        ),
                        SizedBox(width: 5.w),
                        Text('누적포인트',
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.onPrimary,
                                fontWeight: FontWeight.w800)),
                      ],
                    ),
                    Text(
                        '${BizController.to.numberFormat(int.parse(UserStore.to.userProfile.point ?? '0'))}P',
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.onPrimary,
                            fontWeight: FontWeight.w700)),
                  ],
                ),
                // 누적 사용내역
                Container(
                  width: double.infinity,
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('적립 / 사용내역',
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.onPrimary,
                              fontSize: 10.sp,
                              // underscore
                              decoration: TextDecoration.underline,
                              fontWeight: FontWeight.w700)),
                      SizedBox(width: 10.w),
                      Icon(
                        Icons.arrow_forward_ios,
                        color: Theme.of(context).colorScheme.onPrimary,
                        size: 10.sp,
                      ),
                    ],
                  ),
                ),
              ],
            ),

          ),
        ],
      ),
    );
  }

  Widget _buildMyFeedContainer(BuildContext context) {
    return Obx(() {
      if (FeedController.to.thumbnailList.isNotEmpty) {
        return GridView.builder(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 0.6.w / 0.88.h
          ),
          itemCount: FeedController.to.thumbnailList.length,
          itemBuilder: (context, index) {
            return InkWell(onTap: () {
              Get.toNamed(AppRoutes.feedDetail, arguments: {
                'detailFeed': FeedController.to.feedList[index],
              });
            }, child: _myFeedItem(index));
          },
        );
      } else {
        return Container();
      }
    });
  }

  Widget _myFeedItem(index) {
    return Column(
      children: [
        Stack(
          children: [
            // round corner
            Container(
              width: 100.w,
              height: 150.h,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6.r),
                color: gray200,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6.r),
                child: Image.file(
                  File(FeedController.to.thumbnailList[index]),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            // 재생시간
            Positioned(
              top: 5.h,
              right: 5.w,
              child: Container(
                padding: EdgeInsets.all(5),
                child: Row(
                  children: [
                    Icon(
                      Icons.favorite,
                      color: Colors.red,
                      size: 12.sp,
                    ),
                    SizedBox(width: 3.w),
                    Text(
                      FeedController.to.feedList[index].likeCount.toString(),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w600,
                        height: 0,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // 동영상 길이 텍스트 변환
  _convertDuration(int duration) {
    final int minutes = (duration / 60).truncate();
    final int seconds = duration % 60;
    if (seconds < 10) {
      return '$minutes:0$seconds';
    }
    return '$minutes:$seconds';
  }

}
