import 'dart:io';
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:foreats/utils/logger.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';

import '../../utils/app_routes.dart';
import '../../utils/colors.dart';
import '../../widget/base_appbar.dart';
import '../feed/feed_controller.dart';
import 'lounge_controller.dart';

class LoungeScreen extends GetView<LoungeController> {

  LoungeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: BaseAppBar(
        title: '라운지',
      ),
      body:
      Column(
        children: [
          Expanded(
            child: _buildLoungeBody(context),
          ),
        ],
      ),
    );
  }

  Widget _buildLoungeBody(BuildContext context) {
    return SingleChildScrollView(
      child: SizedBox(
        width: 390.w,
        child: Container(
          padding: EdgeInsets.only(top: 10.h, bottom: 20.h),
          child: Column(
            children: [
              _popularThumbnail(context),
              _popularSupporters(context),
              _popularFeeds(context),
            ],
          ),
        ),
      ),
    );
  }

  /// 인기 있는 지역 썸네일
  Widget _popularThumbnail(BuildContext context) {
    return Container(
      width: 390.w,
      padding: EdgeInsets.only(left: 20.w, right: 20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '인기 있는 지역이에요 🔥',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onBackground,
              fontSize: 14.sp,
              fontWeight: FontWeight.w700,
              height: 0,
            ),
          ),
          SizedBox(
            width: 390.w,
            height: 215.h,
            child: ListView.separated(
              shrinkWrap: true,
              scrollDirection: Axis.horizontal,
              itemCount: controller.locationList.length,
              itemBuilder: (context, index) {
                return Column(
                  children: [
                    InkWell(
                      onTap: () {
                        controller.locationIndex.value = index;
                        controller.moveToLocation();
                        Get.toNamed(AppRoutes.map, arguments: {
                          'lonlat': controller.lonlat,
                          'location': controller.locationList[index],
                        });
                      },
                      child: Container(
                        width: 100.w,
                        height: 175.h,
                        alignment: Alignment.center,
                        child: Container(
                          width: 100.w,
                          height: 150.h,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(6.r),
                            child: CachedNetworkImage(
                              imageUrl: controller.locationThumbnailList[index],
                              fit: BoxFit.cover,
                              placeholder: (context, url) => const Center(
                                child: CircularProgressIndicator(),
                              ),
                              errorWidget: (context, url, error) => const Icon(Icons.error),
                            ),
                          )
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          controller.locationList[index],
                          style: TextStyle(
                            color: gray800,
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w500,
                            height: 0,
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
              separatorBuilder: (BuildContext context, int index) {
                return SizedBox(width: 10.w);
              },
            ),
          ),
        ],
      ),
    );
  }

  /// 인기 서포터즈
  Widget _popularSupporters(BuildContext context) {
    return Container(
      width: 390.w,
      padding: EdgeInsets.only(left: 20.w, right: 20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '인기가 많은 서포터즈를 확인해보세요 🌟',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onBackground,
              fontSize: 14.sp,
              fontWeight: FontWeight.w700,
              height: 0,
            ),
          ),
          SizedBox(height: 10.h),
          Obx(() {
            if (controller.users.isEmpty) {
              return Container(
                  width: 390.w,
                  height: 90.h,
                  child: Center(
                    child: Text('서포터즈가 없습니다 🌟', style: TextStyle(color: gray500, fontSize: 14.sp, fontWeight: FontWeight.w600)),
                  ));
            } else {
              return SizedBox(
                width: 390.w,
                height: 90.h,
                child:
                Obx(() => controller.users.isEmpty
                  ? Container(
                    width: 390.w,
                    height: 90.h,
                    child: Center(
                      child: Text('서포터즈가 없습니다 🌟', style: TextStyle(color: gray500, fontSize: 14.sp, fontWeight: FontWeight.w600)),
                    ),
                )
                  : // 리스트 아이템 겹치기
                  ListView.separated(
                    shrinkWrap: true,
                    scrollDirection: Axis.horizontal,
                    itemCount: controller.users.length,
                    itemBuilder: (context, index) {
                      return _circleAvatarItem(controller.users[index].photoUrl, controller.users[index].nickname ?? '');
                    },
                    separatorBuilder: (BuildContext context, int index) {
                      // 간격 겹치기
                      return SizedBox(width: 8.w);
                    },
                  ),
                )
              );
            }
          }),
        ],
      ),
    );
  }

  /// 인기 피드
  Widget _popularFeeds(BuildContext context) {
    return Container(
      width: 390.w,
      padding: EdgeInsets.only(left: 20.w, right: 20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '인기가 많은 피드를 확인해보세요 👀',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onBackground,
              fontSize: 14.sp,
              fontWeight: FontWeight.w700,
              height: 0,
            ),
          ),
          SizedBox(height: 10.h),
          Obx(() {
            if (FeedController.to.thumbnailList.isEmpty) {
              return SizedBox(
                width: 390.w,
                height: 175.h,
                child: Center(
                  child: Text('피드가 없습니다 👀', style: TextStyle(color: gray500, fontSize: 14.sp, fontWeight: FontWeight.w600)),
                ),
              );
            } else {
              return _feedThumbnailList();
            }
          }),
        ],
      ),
    );
  }

  Widget _feedThumbnailList() {
    return SizedBox(
      width: 390.w,
      height: 175.h,
      child: ListView.separated(
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        itemCount: controller.loungeFeedList.length,
        itemBuilder: (context, index) {
          return Column(
            children: [
              InkWell(
                onTap: () {
                  //Get.toNamed(AppRoutes.feedDetail, arguments: controller.loungeFeedList[index]);
                },
                child: Container(
                  width: 100.w,
                  height: 150.h,
                  alignment: Alignment.center,
                  child: Container(
                    width: 100.w,
                    height: 150.h,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6.r),
                      child: CachedNetworkImage(
                        imageUrl: controller.loungeFeedList[index].thumbnailUrls![0],
                        fit: BoxFit.cover,
                        placeholder: (context, url) => const Center(
                          child: CircularProgressIndicator(),
                        ),
                        errorWidget: (context, url, error) => const Icon(Icons.error),
                      ),
                    ),
                  ),
                ),
              ),
              Row(
                children: [
                  Text(
                    controller.loungeFeedList[index].storeName ?? '',
                    style: TextStyle(
                      color: gray800,
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w500,
                      height: 0,
                    ),
                  ),
                ],
              ),
            ],
          );
        },
        separatorBuilder: (BuildContext context, int index) {
          return SizedBox(width: 10.w);
        },
      ),
    );
  }

  /// 유저 리스트 아이템
  _circleAvatarItem(String? imageUrl, String value) {
    return Column(
      children: [
        InkWell(
          onTap: () {
            //Get.toNamed(AppRoutes.userProfile, arguments: value);
          },
          child: CachedNetworkImage(
            imageUrl: imageUrl ?? '',
            imageBuilder: (context, imageProvider) => Container(
              width: 50.w,
              height: 50.h,
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
        ),
        SizedBox(height: 5.h),
        Row(
          children: [
            Text(
              value,
              style: TextStyle(
                color: gray500,
                fontSize: 11.sp,
                fontWeight: FontWeight.w600,
                height: 0,
              ),
            ),
          ],
        ),
      ],
    );
  }

  randomColor() {
    // get pastel color
    final random = Random();

    final pastelColors = [
      Color(0xffFFC0CB),
      Color(0xffFFB6C1),
      Color(0xffFF69B4),
      Color(0xffFF1493),
      Color(0xffDB7093),
      Color(0xffC71585),
      Color(0xffFFA07A),
      Color(0xffFA8072),
      Color(0xffE9967A),
      Color(0xffF08080),
      Color(0xffCD5C5C),
    ];

    return pastelColors[random.nextInt(pastelColors.length)];
  }

}
