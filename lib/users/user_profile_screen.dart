import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:foreats/screens/feed/feed_controller.dart';
import 'package:get/get.dart';

import '../model/feed_model.dart';
import '../utils/app_routes.dart';
import '../utils/colors.dart';
import '../utils/dialog_util.dart';
import '../utils/logger.dart';
import '../utils/text_style.dart';
import '../widget/base_appbar.dart';
import 'user_controller.dart';

class UserProfileScreen extends GetView<UserController> {
  const UserProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // args
    final args = Get.arguments;
    final getFeed = args['feedModel'];

    Get.put(UserController());
    Get.put(FeedController());

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: BaseAppBar(
        title: '#${getFeed.nickname}',
        centerTitle: false,
        customTitle: true,
        leading: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 동영상 갯수
            FutureBuilder(
              future: UserController.to.fetchUsersFeed(getFeed.nickname),
              builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return DialogUtil().buildLoadingDialog();
                } else {
                  return Container(
                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
                    margin: EdgeInsets.symmetric(vertical: 10.h),
                    child: Container(
                      child: controller.getUserFeed.isEmpty ? Center(
                        child: Text(
                          '아직 업로드한 동영상이 없어요 😢',
                          style: TextStyleUtils.bodyTextStyle(
                            color: gray600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ) : GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 10.w,
                          mainAxisSpacing: 10.h,
                          mainAxisExtent: 150.h,
                          // childAspectRatio: 2,
                        ),
                        //itemCount: snapshot.data[snapshot.data.l]['videoUrls'].length,
                        //itemCount: getFeed.videoUrls.length,
                        itemCount: snapshot.data[0]['videoUrls'].length,
                        shrinkWrap: true,
                        itemBuilder: (BuildContext context, int index) {
                          return Column(
                            children: [
                              // scrollview
                              Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.grey,
                                    borderRadius: BorderRadius.circular(10.r),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10.r),
                                    child: Stack(
                                        children: [
                                          InkWell(
                                            onTap: () {
                                              // 동영상 재생
                                              AppLog.to.d('동영상 재생');
                                              var model = FeedModel.fromJson(snapshot.data[0]);
                                              AppLog.to.d('model: $model');
                                              Get.toNamed(AppRoutes.feedDetail, arguments: {
                                                'detailFeed': model,
                                              });
                                            },
                                            child: CachedNetworkImage(
                                              imageUrl: snapshot.data[0]['thumbnailUrls'][index],
                                              fit: BoxFit.cover,
                                              width: double.infinity,
                                              height: double.infinity,
                                              placeholder: (context, url) => Center(child: DialogUtil().buildLoadingDialog()),
                                              errorWidget: (context, url, error) => Icon(Icons.error),
                                            ),
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
                                        ]
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

}