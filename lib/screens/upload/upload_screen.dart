import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:foreats/screens/upload/upload_controller.dart';
import 'package:get/get.dart';
import 'package:photo_manager/photo_manager.dart';

import '../../utils/colors.dart';
import '../../widget/base_appbar.dart';
import '../../widget/custom_gallery.dart';
import '../feed/feed_controller.dart';

class UploadScreen extends GetView<UploadController> {
  const UploadScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(UploadController());
    return Scaffold(
      appBar: BaseAppBar(
        title: '모든앨범',
        leading: true,
        actions: true,
        callback: () {
          FeedController.to.recentPlay();
          Get.back();
        },
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: CustomGallery(),
          ),
          buildSelectVideo(),
        ],
      ),
    );
  }

  /// 선택한 비디오
  Widget buildSelectVideo() {
    return Obx(() {
      return controller.selectedList.isEmpty
          ? const SizedBox()
          : Column(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: Theme.of(Get.context!).colorScheme.tertiary,
                      size: 20.sp,
                    ),
                    SizedBox(width: 10.w),
                    Text(
                      '선택한 비디오 ${controller.selectedList.length}개',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(Get.context!).colorScheme.tertiary
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                  height: 0.2.sh,
                  decoration: BoxDecoration(
                    color: Theme.of(Get.context!).scaffoldBackgroundColor,
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 0.w, vertical: 10.h),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: controller.selectedList.length,
                      itemBuilder: (BuildContext context, int index) {
                        final int assetIndex = controller.selectedList[index];
                        final AssetEntity asset = controller.assets[assetIndex];
                        return FutureBuilder<Uint8List?>(
                          future:
                              asset.thumbnailDataWithSize(ThumbnailSize(256, 256)),
                          builder: (BuildContext context,
                              AsyncSnapshot<Uint8List?> snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return Center(
                                child: CircularProgressIndicator(),
                              );
                            } else {
                              return Stack(
                                  children: [
                                  Container(
                                    width: 0.1.sh,
                                    height: 0.25.sh,
                                    margin: EdgeInsets.only(right: 4.w, left: 4.w, bottom: 10.h, top: 10.h),
                                    padding: EdgeInsets.all(2.w),
                                    child: ClipRRect(
                                      child: Image.memory(
                                        snapshot.data!,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                ),
                                Positioned(
                                  right: 10.w,
                                  top: 14.h,
                                  child: Container(
                                    padding: EdgeInsets.all(2.w),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.5),
                                      borderRadius: BorderRadius.circular(10.r),
                                    ),
                                    child: InkWell(
                                      onTap: () {
                                        controller.removeCustomGallerySelectedList(assetIndex);
                                      },
                                      child: Icon(
                                        Icons.close,
                                        color: Colors.white,
                                        size: 16.sp,
                                      ),
                                    ),
                                  ),
                                ),
                              ]);
                            }
                          },
                        );
                      },
                      separatorBuilder: (BuildContext context, int index) {
                        return SizedBox(width: 10.w);
                      }
                    ),
                  ),
                ),
            ],
          );
    });
  }
}
