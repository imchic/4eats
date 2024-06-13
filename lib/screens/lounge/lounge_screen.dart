import 'dart:math';

import 'package:avatar_glow/avatar_glow.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:foreats/model/user_model.dart';
import 'package:get/get.dart';

import '../../model/feed_model.dart';
import '../../utils/app_routes.dart';
import '../../utils/colors.dart';
import '../../utils/dialog_util.dart';
import '../../utils/text_style.dart';
import '../../widget/base_appbar.dart';
import 'lounge_controller.dart';

class LoungeScreen extends GetView<LoungeController> {
  LoungeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: BaseAppBar(
        title: '라운지',
        notification: true,
      ),
      body: _buildLoungeBody(context),
    );
  }

  Widget _buildLoungeBody(BuildContext context) {
    return SingleChildScrollView(
      child: SizedBox(
        child: Container(
          width: 1.sw,
          padding: EdgeInsets.only(top: 10.h),
          child: Column(
            children: [
              // 서포터즈
              FutureBuilder(
                  future: controller.fetchSupportersList(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return DialogUtil().buildLoadingDialog();
                    } else {
                      return _supporters(context);
                    }
                  }),
              SizedBox(height: 10.h),
              FutureBuilder(
                future: controller.fetchLoungeFeedList(''),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return DialogUtil().buildLoadingDialog();
                  } else {
                    return _todayContainer(context);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 오늘의 추천
  Widget _todayContainer(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: 20.w, right: 20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('오늘의 추천은 어떠세요? 😎',
                  style: TextStyleUtils.loungeTitleTextStyle(
                    color: Get.isDarkMode ? Colors.white : Colors.black,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                  )),
              Spacer(),
              // 더보기
              InkWell(
                onTap: () {
                  Get.toNamed(AppRoutes.loungeFeed);
                },
                child: Text('더보기',
                    style: TextStyleUtils.bodyTextStyle(
                        color: Theme
                            .of(context)
                            .colorScheme
                            .primary,
                        fontWeight: FontWeight.w500,
                        fontSize: 9.sp)),
              ),
            ],
          ),
          SizedBox(height: 5.h),
          Text('포잇에서 추천하는 가게들이에요',
              style: TextStyleUtils.bodyTextStyle(
                color: Get.isDarkMode ? gray400 : gray600,
                fontSize: 10.sp,
              )),
          SizedBox(height: 10.h),
          controller.loungeFeedList.isNotEmpty
              ? _todayFeedList()
              : Text('추천하는 가게가 없어요 😢',
              style: TextStyleUtils.bodyTextStyle(
                color: Get.isDarkMode ? Colors.white : gray600,
              )),
        ],
      ),
    );
  }

  /// 인기 서포터즈
  Widget _supporters(BuildContext context) {
    return Container(
      width: 390.w,
      padding: EdgeInsets.only(left: 20.w, right: 20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('이달의 포잇터분들이에요 👀',
                  style: TextStyleUtils.loungeTitleTextStyle(
                    color: Get.isDarkMode ? Colors.white : Colors.black,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                  )),
              SizedBox(height: 5.h),
              Text(
                '포잇에서 왕성하게 활동중이신 분들이에요',
                style: TextStyleUtils.bodyTextStyle(
                  color: Get.isDarkMode ? gray400 : gray600,
                  fontSize: 10.sp,
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          SizedBox(
              width: 390.w,
              height: 80.h,
              child: FutureBuilder(
                future: controller.fetchSupportersList(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return DialogUtil().buildLoadingDialog();
                  } else {
                    return ListView.separated(
                      shrinkWrap: true,
                      scrollDirection: Axis.horizontal,
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        return _supportersItems(
                            // snapshot.data![index].profileImage ?? '',
                            // snapshot.data![index].nickname ?? '');
                            snapshot.data![index]);
                      },
                      separatorBuilder: (BuildContext context, int index) {
                        return SizedBox(width: 10.w);
                      },
                    );
                  }
                },
              )),
        ],
      ),
    );
  }

  /// 오늘의 추천 피드 리스트
  Widget _todayFeedList() {
    return SizedBox(
        width: 390.w,
        height: Get.height * 0.3,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: controller.loungeFeedList.length > 5
              ? 5
              : controller.loungeFeedList.length,
          itemBuilder: (context, index) {
            return _todayFeedItem(controller.loungeFeedList, index);
          },
          separatorBuilder: (BuildContext context, int index) {
            return SizedBox(width: 10.w);
          },
        ));
  }

  /// 오늘의 추천 리스트 아이템
  Widget _todayFeedItem(List<FeedModel> feedList, int index) {
    return Column(
      children: [
        InkWell(
          onTap: () {
            var model = FeedModel.fromJson(feedList[index].toJson());
            Get.toNamed(AppRoutes.feedDetail, arguments: {
              'detailFeed': model,
            });
          },
          child: Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(6.r),
                child: CachedNetworkImage(
                  imageUrl: feedList[index].thumbnailUrls![0],
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Center(
                      child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(gray300),
                  )),
                  errorWidget: (context, url, error) =>
                      const Icon(Icons.error),
                ),
              ),
              // 좋아요
              Positioned(
                top: 5.h,
                right: 5.w,
                child: Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.favorite,
                        color: Colors.white,
                        size: 12.sp,
                      ),
                      SizedBox(width: 5.w),
                      Text(
                        feedList[index].likeCount.toString(),
                        style: TextStyleUtils.bodyTextStyle(
                          fontSize: 8.sp,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 유저 리스트 아이템
  _supportersItems(UserModel model) {
    return Column(
      children: [
        InkWell(
          onTap: () {
            // 유저 포스팅 화면
            Get.toNamed(AppRoutes.userProfile, arguments: {
              'feedModel': model,
            });
          },
          child: AvatarGlow(
            glowRadiusFactor: 0.1,
            glowColor: Get.isDarkMode ? Colors.white : Colors.black,
            glowCount: 1,
            child: CachedNetworkImage(
              imageUrl: model.profileImage ?? '',
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
              placeholder: (context, url) => Center(
                  child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(gray300),
              )),
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
        ),
        SizedBox(height: 5.h),
        Row(
          children: [
            Text(
              model.nickname ?? '',
              style: TextStyleUtils.bodyTextStyle(
                  color: Get.isDarkMode ? Colors.white : Colors.black,
                  fontSize: 8.sp,
                  fontWeight: FontWeight.w500),
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
      Colors.pink[200],
      Colors.purple[200],
      Colors.blue[200],
      Colors.green[200],
      Colors.yellow[200],
      Colors.orange[200],
      Colors.red[200],
      Colors.teal[200],
      Colors.indigo[200],
      Colors.cyan[200],
      Colors.lime[200],
      Colors.amber[200],
      Colors.deepOrange[200],
    ];

    return pastelColors[random.nextInt(pastelColors.length)];
  }
}
