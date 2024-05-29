import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:foreats/utils/logger.dart';
import 'package:get/get.dart';

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
      backgroundColor: Colors.white,
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
              FutureBuilder(
                future: controller.fetchSupportersList(),
                builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return DialogUtil().buildLoadingDialog();
                } else {
                  return _supporters(context);
                }
              }),
              // FutureBuilder(
              //   future: controller.fetchCurrentLocation(),
              //   builder: (context, snapshot) {
              //     if (snapshot.connectionState == ConnectionState.waiting) {
              //       return DialogUtil().buildLoadingDialog();
              //     } else {
              //       AppLog.to.d('snapshot.data: ${snapshot.data}');
              //       return snapshot.data != null || snapshot.data != 'null' || snapshot.data != ''
              //           ? _currentRecommanded(context, snapshot.data.toString())
              //           : Text('현재 위치를 찾을 수 없어요 😢', style: TextStyleUtils().bodyTextStyle(color: gray600));
              //     }
              //   },
              // ),
              // SizedBox(height: 10.h),
              FutureBuilder(
                future: controller.fetchLoungeFeedList(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return DialogUtil().buildLoadingDialog();
                  } else {
                    return _todayRecommanded(context);
                  }
                },
              ),
              // FutureBuilder(
              //   future: MapController.to.convertLatLngToAddress(),
              //   builder: (context, snapshot) {
              //     if (snapshot.connectionState == ConnectionState.waiting) {
              //       return DialogUtil().buildLoadingDialog();
              //     } else {
              //       return _loungePopular(context, snapshot.data.toString());
              //     }
              //   },
              // ),
            ],
          ),
        ),
      ),
    );
  }

  /// 오늘의 추천
  Widget _todayRecommanded(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: 20.w, right: 20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('오늘의 추천은 어떠세요? 😎', style: TextStyleUtils().loungeTitleTextStyle()),
          SizedBox(height: 5.h),
          Text('포잇에서 추천하는 가게들이에요', style: TextStyleUtils().bodyTextStyle(color: gray600)),
          SizedBox(height: 10.h),
          controller.loungeFeedList.length > 0
              ? _feedThumbnailList()
              : Text('추천하는 가게가 없어요 😢', style: TextStyleUtils().bodyTextStyle(color: gray600)),
        ],
      ),
    );
  }

  /// 현재 지역구 추천
  Widget _currentRecommanded(BuildContext context, String currentAddress) {
    return SizedBox(
      width: 0.9.sw,
      height: 0.3.sh,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('${currentAddress.split(" ")[1]}에서 인기가 많은 가게에요! 🌟', style: TextStyleUtils().loungeTitleTextStyle(),),
          //SizedBox(height: 5.h),
          //Text('현재 위치: $currentAddress', style: TextStyleUtils().bodyTextStyle(color: gray600),),
          SizedBox(height: 10.h),
          currentAddress != 'null'
              ? _feedRecommendList(context)
              : Text('현재 위치를 찾을 수 없어요 😢', style: TextStyleUtils().bodyTextStyle(color: gray600)),
        ],
      ),
    );
  }

  /// 인기 있는 가게 리스트
  Widget _feedRecommendList(BuildContext context) {
    return Container(
      width: 390.w,
      height: 0.25.sh,
      child: FutureBuilder(
        future: controller.fetchSearchPlace(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return DialogUtil().buildLoadingDialog();
          } else {
            return ListView.separated(
              shrinkWrap: true,
              scrollDirection: Axis.horizontal,
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                return Column(
                  children: [
                    InkWell(
                      onTap: () {
                        //Get.toNamed(AppRoutes.mapDetail, arguments: snapshot.data[index]);
                      },
                      child: Container(
                        width: 0.3.sw,
                        height: 0.5.sw,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(6.r),
                              child: CachedNetworkImage(
                                imageUrl: snapshot.data![index].thumbnail ?? '',
                                fit: BoxFit.cover,
                                placeholder: (context, url) => DialogUtil().buildLoadingDialog(),
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
                                      snapshot.data![index].name ?? '',
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
                    return ListView.separated(
                      shrinkWrap: true,
                      scrollDirection: Axis.horizontal,
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        return _supportersItems(
                            snapshot.data![index].profileImage ?? '',
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

  /// 오늘의 추천 피드
  // Widget _loungeTodayRecommend(BuildContext context) {
  //   return _todayRecommanded(context);
  // }

  /// 오늘의 추천 피드 리스트
  Widget _feedThumbnailList() {
    return Container(
      width: 1.sw,
      height: 0.3.sh,
      child: FutureBuilder(
        future: controller.fetchLoungeFeedList(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return DialogUtil().buildLoadingDialog();
          } else {
            return ListView.separated(
              shrinkWrap: true,
              scrollDirection: Axis.horizontal,
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                return Column(
                  children: [
                    InkWell(
                      onTap: () {
                        //Get.toNamed(AppRoutes.mapDetail, arguments: snapshot.data[index]);
                      },
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6.r),
                            child: CachedNetworkImage(
                              imageUrl: snapshot.data![index].thumbnailUrls![0] ?? '',
                              fit: BoxFit.cover,
                              placeholder: (context, url) => DialogUtil().buildLoadingDialog(),
                              errorWidget: (context, url, error) => const Icon(Icons.error),
                            ),
                          ),
                          Positioned(
                            bottom: 5.h,
                            right: 2.w,
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
                                    snapshot.data![index].storeName ?? '',
                                    style: TextStyleUtils().bodyTextStyle(
                                      fontSize: 7.sp,
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
  _supportersItems(String? imageUrl, String value) {
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
