import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:foreats/utils/colors.dart';
import 'package:foreats/utils/dialog_util.dart';
import 'package:get/get.dart';

import '../../utils/logger.dart';
import '../../utils/text_style.dart';
import '../../widget/base_appbar.dart';
import 'store_controller.dart';

class StoreScreen extends GetView<StoreController> {
  StoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // args
    final args = Get.arguments;

    return Scaffold(
        backgroundColor: Colors.white,
        appBar: BaseAppBar(
          title: '#${args['storeName']}',
          centerTitle: false,
          customTitle: true,
          leading: true,
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Row(
                  children: [
                    Text(
                        args['storeAddress'],
                        style: TextStyleUtils.bodyTextStyle(
                          color: gray600,
                          fontWeight: FontWeight.w500,
                        )
                    ),
                    Spacer(),
                    // 즐겨찾기
                    IconButton(
                      icon: Icon(Icons.favorite_border),
                      onPressed: () {
                        // 즐겨찾기 추가
                      },
                    ),
                  ],
                ),
              ),
              // 동영상 갯수
              FutureBuilder(
                future: StoreController.to.fetchStores(args['storeName']),
                builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return DialogUtil().buildLoadingDialog();
                  } else {
                    return Container(
                      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
                      margin: EdgeInsets.symmetric(vertical: 10.h),
                      child: Container(
                        child: GridView.builder(
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 10.w,
                            mainAxisSpacing: 10.h,
                            mainAxisExtent: 150.h,
                            // childAspectRatio: 2,
                          ),
                          //itemCount: snapshot.data[snapshot.data.l]['videoUrls'].length,
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
                                          CachedNetworkImage(
                                            imageUrl: snapshot.data[0]['thumbnailUrls'][index],
                                            fit: BoxFit.cover,
                                            width: double.infinity,
                                            height: double.infinity,
                                            placeholder: (context, url) => Center(child: DialogUtil().buildLoadingDialog()),
                                            errorWidget: (context, url, error) => Icon(Icons.error),
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
        ));
  }
}
