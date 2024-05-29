import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:foreats/utils/dialog_util.dart';
import 'package:foreats/utils/text_style.dart';
import 'package:get/get.dart';

import '../../utils/app_routes.dart';
import '../../utils/colors.dart';
import '../../widget/base_appbar.dart';
import '../../widget/point_card.dart';
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
      backgroundColor: Theme
          .of(context)
          .colorScheme
          .background,
      appBar: BaseAppBar(
        title: '마이페이지',
      ),
      body: Obx(() {
        if (UserStore.to.isLoginCheck == false) {
          return DialogUtil().buildLoadingDialog();
        } else {
          return Column(
            children: [
              _buildMyProfileInfo(context),
              _buildMyFeedContainer(context),
            ],
          );
        }
      }),
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
              Obx(() {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(50.r),
                  child: CachedNetworkImage(
                    imageUrl: UserStore.to.user.value.profileImage ?? '',
                    imageBuilder: (context, imageProvider) =>
                        Container(
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
                    placeholder: (context, url) =>
                        Container(
                          width: 40.w,
                          height: 40.h,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.grey[200],
                          ),
                        ),
                    errorWidget: (context, url, error) =>
                        Container(
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
                );
              }),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      children: [
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              UserStore.to.user.value.nickname ?? '',
                              style: TextStyle(
                                color: Theme
                                    .of(context)
                                    .colorScheme
                                    .onBackground,
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w700,
                                height: 0,
                              ),
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              '@${UserStore.to.user.value.id ?? ''}',
                              style: TextStyle(
                                color: gray500,
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w400,
                                height: 0,
                              ),
                            ),
                          ],
                        ),
                      ],
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
          PointCard().buildPointCard(context),
        ],
      ),
    );
  }

  /// 내가 올린 피드
  Widget _buildMyFeedContainer(BuildContext context) {
    return Obx(() {
        return Expanded(
          child: FutureBuilder(future: controller.getMyFeeds(),
              builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return DialogUtil().buildLoadingDialog();
                } else {
                  return Container(
                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
                    margin: EdgeInsets.symmetric(vertical: 10.h),
                    child: GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 10.w,
                        mainAxisSpacing: 10.h,
                        mainAxisExtent: 150.h,
                        // childAspectRatio: 2,
                      ),
                      itemCount: snapshot.data.length,
                      itemBuilder: (BuildContext context, int index) {
                        return Column(
                          children: [
                            // scrollview
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(6.r),
                                child: Stack(
                                  children: [
                                    CachedNetworkImage(
                                      imageUrl: snapshot.data[index].thumbnailUrls[0] ?? '',
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) => Container(color: gray200,),
                                      errorWidget: (context, url, error) => Container(color: gray200, child: Icon(Icons.error, color: Colors.red,),),
                                    ),
                                    // 좋아요
                                    Positioned(
                                      right: 0.w,
                                      child: IconButton(
                                        icon: Icon(Icons.favorite_border, color: Colors.white, size: 16.sp),
                                        onPressed: () {
                                          // 좋아요 추가
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  );
                }
              }),
        );
      });
  }

  /// 내가 올린 피드 아이템
  // Widget _myFeedItem(index) {
  //   return Column(
  //     children: [
  //       Stack(
  //         children: [
  //           // round corner
  //           Container(
  //             width: 100.w,
  //             height: 150.h,
  //             decoration: BoxDecoration(
  //               borderRadius: BorderRadius.circular(6.r),
  //               color: gray200,
  //             ),
  //             child: ClipRRect(
  //               borderRadius: BorderRadius.circular(6.r),
  //               child: CachedNetworkImage(
  //                 imageUrl: FeedController.to.thumbnailList[index],
  //                 fit: BoxFit.cover,
  //                 placeholder: (context, url) =>
  //                     Container(
  //                       color: gray200,
  //                     ),
  //                 errorWidget: (context, url, error) =>
  //                     Container(
  //                       color: gray200,
  //                       child: Icon(
  //                         Icons.error,
  //                         color: Colors.red,
  //                       ),
  //                     ),
  //               ),
  //             ),
  //           ),
  //           // 재생시간
  //           Positioned(
  //             top: 5.h,
  //             right: 5.w,
  //             child: Container(
  //               padding: EdgeInsets.all(5),
  //               child: Row(
  //                 children: [
  //                   Icon(
  //                     Icons.favorite,
  //                     color: Colors.red,
  //                     size: 12.sp,
  //                   ),
  //                   SizedBox(width: 3.w),
  //                   Text(
  //                     FeedController.to.feedList[index].likeCount.toString(),
  //                     style: TextStyle(
  //                       color: Colors.white,
  //                       fontSize: 10.sp,
  //                       fontWeight: FontWeight.w600,
  //                       height: 0,
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //             ),
  //           ),
  //         ],
  //       ),
  //     ],
  //   );
  // }

}