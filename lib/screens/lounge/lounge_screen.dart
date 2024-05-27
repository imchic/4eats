import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:googleapis/admob/v1.dart';

import '../../utils/app_routes.dart';
import '../../utils/colors.dart';
import '../../utils/dialog_util.dart';
import '../../utils/logger.dart';
import '../../utils/text_style.dart';
import '../../widget/base_appbar.dart';
import '../map/map_controller.dart';
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
      body: _buildLoungeBody(context),
    );
  }

  Widget _buildLoungeBody(BuildContext context) {
    return SingleChildScrollView(
      child: SizedBox(
        width: 390.w,
        height: 1.sh,
        child: Container(
          padding: EdgeInsets.only(top: 10.h, bottom: 20.h),
          child: Column(
            children: [
              SizedBox(height: 10.h),
              _popularSupporters(context),
              // 오늘의 추천 타이틀
              _feedRecommandedTitle(),
              // 오늘의 추천
              FutureBuilder(
                future: controller.fetchLoungeFeedList(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return DialogUtil().buildLoadingDialog();
                  } else {
                    return _popularFeeds(context);
                  }
                },
              ),
              FutureBuilder(
                future: MapController.to.convertLatLngToAddress(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return DialogUtil().buildLoadingDialog();
                  } else {

                    AppLog.to.i('snapshot.data: ${snapshot.data}');

                    return _popularThumbnail(context, snapshot.data.toString());
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Container _feedRecommandedTitle() {
    return Container(
              width: 1.sw,
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 5.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('오늘의 추천은 어떠세요? 😎', style: TextStyleUtils().loungeTitleTextStyle()),
                  SizedBox(height: 5.h),
                  Text('포잇에서 추천하는 가게들이에요', style: TextStyleUtils().bodyTextStyle(color: gray600),)
                ],
              ),
            );
  }

  /// 인기 있는 지역 썸네일
  Widget _popularThumbnail(BuildContext context, String currentLocation) {

    var sigungu = currentLocation.split(' ')[1];

    return Container(
      width: 390.w,
      // color: randomColor(),
      padding: EdgeInsets.only(left: 20.w, right: 20.w, top: 10.h, bottom: 10.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            currentLocation == 'null'
                ? '인기 있는 가게를 확인해보세요 ??'
                : '$sigungu에서 인기 있는 가게를 확인해보세요 😋',
            style: TextStyleUtils().loungeTitleTextStyle(),
          ),
          /*RichText(
            text: TextSpan(
              text: sigungu == 'null'
                  ? '인기 있는 가게를 확인해보세요 ??'
                  : '$sigungu',
              style: TextStyleUtils().loungeSubTitleTextStyle(null),
              children: [
                TextSpan(
                  text: '에서 인기 있는 가게를 확인해보세요 ??',
                  style: TextStyleUtils().loungeSubTitleTextStyle(null),
                ),
              ],
            ),
          ),*/
          SizedBox(height: 10.h),
          // FutureBuilder(
          //   future: MapController.to.fetchSearchPlace('맛집', page: 1),
          //   builder: (context, snapshot) {
          //     if (snapshot.connectionState == ConnectionState.waiting) {
          //       return DialogUtil().buildLoadingDialog();
          //     } else {
          //       AppLog.to.i('snapshot.data: ${snapshot.data}');
          //       return _feedRecommendList(context, snapshot.data);
          //     }
          //   },
          // ),
          // 1초 뒤에 검색
          FutureBuilder(
            future: controller.fetchSearchPlace(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return DialogUtil().buildLoadingDialog();
              } else {
                //AppLog.to.i('snapshot.data: ${snapshot.data}');
                return _feedRecommendList(context, snapshot.data);
              }
            },
          ),
        ],
      ),
    );
  }

  /// 인기 있는 가게 리스트
  Widget _feedRecommendList(BuildContext context, List<dynamic>? data) {
    return SizedBox(
      width: 390.w,
      height: 0.25.sh,
      child: ListView.separated(
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        itemCount: controller.loungeFeedList.length,
        itemBuilder: (context, index) {
          return Column(
            children: [
              InkWell(
                onTap: () {
                  Get.toNamed(AppRoutes.feedDetail, arguments: data![index]);
                },
                child: Container(
                  width: 0.3.sw,
                  height: 0.5.sw,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Stack(
                    children: [
                      Container(
                        width: 0.3.sw,
                        height: 0.5.sw,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(6.r),
                          child: CachedNetworkImage(
                            imageUrl: data![index].thumbnail ?? '',
                            fit: BoxFit.cover,
                            placeholder: (context, url) => const Center(
                              child: CircularProgressIndicator(),
                            ),
                            errorWidget: (context, url, error) =>
                                const Icon(Icons.error),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 5.h,
                        left: 5.w,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 5.w, vertical: 2.h),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                data[index].name ?? '',
                                style: TextStyleUtils().bodyTextStyle(
                                  fontSize: 9.sp,
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

  /// 인기 서포터즈
  Widget _popularSupporters(BuildContext context) {
    return Container(
      width: 390.w,
      padding: EdgeInsets.only(left: 20.w, right: 20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('이달의 포잇터분들이에요 👀', style: TextStyleUtils().loungeTitleTextStyle(),),
              SizedBox(height: 5.h),
              Text('포잇에서 왕성하게 활동중이신 분들이에요', style: TextStyleUtils().bodyTextStyle(color: gray600,),),
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
                    //AppLog.to.i('snapshot.data: ${snapshot.data}');
                    return ListView.separated(
                      shrinkWrap: true,
                      scrollDirection: Axis.horizontal,
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        return _circleAvatarItem(
                            snapshot.data![index].photoUrl ?? '',
                            snapshot.data![index].nickname ?? '');
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

  /// 인기 피드
  Widget _popularFeeds(BuildContext context) {
    return Container(
      width: Get.width,
      padding: EdgeInsets.only(left: 20.w, right: 20.w),
      child: _feedThumbnailList(),
    );
  }

  Widget _feedThumbnailList() {
    return Container(
      width: 390.w,
      height: 0.25.sh,
      margin: EdgeInsets.only(top: 10.h),
      child: FutureBuilder(
        future: controller.fetchLoungeFeedList(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return DialogUtil().buildLoadingDialog();
          } else {
            return ListView.separated(
              shrinkWrap: true,
              scrollDirection: Axis.horizontal,
              itemCount: controller.loungeFeedList.length,
              itemBuilder: (context, index) {
                return Column(
                  children: [
                    InkWell(
                      onTap: () {
                        Get.toNamed(AppRoutes.feedDetail,
                            arguments: snapshot.data![index]);
                      },
                      child: Container(
                        width: 0.3.sw,
                        height: 0.5.sw,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(6.r),
                              child: CachedNetworkImage(
                                imageUrl: snapshot.data![index].thumbnailUrls![0] ?? '',
                                fit: BoxFit.cover,
                                placeholder: (context, url) => const Center(
                                  child: CircularProgressIndicator(),
                                ),
                                errorWidget: (context, url, error) => const Icon(Icons.error),
                              ),
                            ),
                            Positioned(
                              bottom: 5.h,
                              left: 5.w,
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.5),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      snapshot.data![index].userNickname ?? '',
                                      style: TextStyleUtils().bodyTextStyle(
                                        fontSize: 9.sp,
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
                    ),
                  ],
                );
              },
              separatorBuilder: (BuildContext context, int index) {
                return SizedBox(width: 10.w);
              },
            );
          }
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
              style: TextStyleUtils().bodyTextStyle(fontSize: 8.sp, fontWeight: FontWeight.w500),
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
