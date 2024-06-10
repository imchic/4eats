import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_view.dart';

import '../../utils/app_routes.dart';
import '../../utils/colors.dart';
import '../../utils/text_style.dart';
import '../../widget/base_appbar.dart';
import 'lounge_controller.dart';

class LoungeFeedScreen extends GetView<LoungeController> {

  const LoungeFeedScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: BaseAppBar(
        title: '가게목록',
        leading: true,
      ),
      body: Obx(
        () => ClipRect(
          child: Container(
            padding: const EdgeInsets.all(8.0),
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 10.w,
                mainAxisSpacing: 10.h,
                mainAxisExtent: 150.h,
                // childAspectRatio: 2,
              ),
              itemCount: controller.loungeFeedList.length,
              itemBuilder: (context, index) {
                final feed = controller.loungeFeedList[index];
                return Column(
                  children: [
                    // scrollview
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(6.r),
                        child:
                          Stack(
                          children: [
                            InkWell(
                              onTap: () {
                                Get.toNamed(AppRoutes.store, arguments: {
                                  'storeName': feed.storeName ?? '',
                                  'storeAddress': feed.storeAddress ?? '',
                                  'storeType': feed.storeType ?? '',
                                  'storeMenu': feed.storeMenuInfo ?? '',
                                  'storeContext': feed.storeContext ?? '',
                                  'lonlat': [
                                    double.parse(feed.storeLngLat!.split(',')[0]),
                                    double.parse(feed.storeLngLat!.split(',')[1])
                                  ]
                                });
                              },
                              child: CachedNetworkImage(
                                imageUrl: feed.thumbnailUrls![0] ?? '',
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Container(color: gray200,),
                                errorWidget: (context, url, error) => Container(color: gray200, child: Icon(Icons.error, color: Colors.red,),),
                              ),
                            ),
                            // 좋아요
                            Positioned(
                              top: 5.h,
                              right: 5.w,
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
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
                                      feed.likeCount.toString(),
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
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      feed.storeName ?? '',
                      style: TextStyleUtils.bodyTextStyle(
                        fontSize: 10.sp,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      feed.storeAddress ?? '',
                      style: TextStyleUtils.bodyTextStyle(
                        fontSize: 7.sp,
                        color: gray500,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}