import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:photo_manager/photo_manager.dart';

import '../screens/upload/upload_controller.dart';
import '../utils/app_routes.dart';

// CustomGallery widget
class CustomGallery extends GetView<UploadController> {
  const CustomGallery({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: FutureBuilder(
        future: controller.fetchAssets(),
        builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else {
            return Obx(() {
              return Container(
                width: 1.sw,
                height: 1.sh,
                color: Theme.of(context).scaffoldBackgroundColor,
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 1,
                    crossAxisSpacing: 1.w,
                    mainAxisSpacing: 1.h,
                    mainAxisExtent: 180.h,
                  ),
                  itemCount: controller.assets.length,
                  itemBuilder: (BuildContext context, int index) {
                    final AssetEntity asset = controller.assets[index];
                    return InkWell(
                      onTap: () {
                        if (asset.id == 'camera') {
                          controller.pickVideoFromCamera();
                        } else {
                          asset.file.then((value) {
                            controller.uploadFile.value = value ?? File('');
                            Get.toNamed(AppRoutes.uploadPreview);
                          });
                        }
                      },
                      child: Stack(
                        children: <Widget>[
                          _galleryItems(asset),
                          _checkbox(context, asset),
                          _playTime(asset),
                        ],
                      ),
                    );
                  },
                ),
              );
            });
          }
        },
      ),
    );
  }

  // 앨범 내 동영상 선택
  _galleryItems(AssetEntity asset) {
    return Center(
      child: asset.id == 'camera'
          ? Container(
              margin: EdgeInsets.only(left: 4.w, right: 4.w, top: 1.h, bottom: 1.h),
              padding: EdgeInsets.all(10.w),
              width: 256.w,
              height: 256.h,
              decoration: BoxDecoration(
                color: Colors.black,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.camera_alt,
                    size: 24.w,
                    color: Colors.white,
                  ),
                  SizedBox(height: 5.h),
                  Text(
                    '카메라',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            )
          : FutureBuilder<Uint8List?>(
              future: asset.thumbnailDataWithSize(ThumbnailSize(256, 256)),
              builder:
                  (BuildContext context, AsyncSnapshot<Uint8List?> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                } else {
                  return Image.memory(
                    snapshot.data!,
                    fit: BoxFit.cover,
                  );
                }
              },
            ),
    );
  }

  // 앨범 내 동영상 선택
  _checkbox(BuildContext context, AssetEntity asset) {
    return asset.id == 'camera'
        ? Container()
        : Obx(
            () => Positioned(
              top: 5.h,
              right: 8.w,
              child: InkWell(
                onTap: () async {
                  if (controller.selectedList.contains(controller.assets.indexOf(asset))) {
                    controller.selectedList.remove(controller.assets.indexOf(asset));
                  } else {
                    controller.selectedList.add(controller.assets.indexOf(asset));
                  }
                  await controller.setSelectVideoFiles();
                },
                child: Container(
                  width: 24.w,
                  height: 24.h,
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    shape: BoxShape.circle,
                  ),
                  child: // 멀티 선택
                      controller.selectedList
                          .contains(controller.assets.indexOf(asset))
                          ? Icon(
                              Icons.check,
                              size: 14.w,
                              color: Theme.of(context).colorScheme.primary,
                            )
                          : Container(),
                ),
              ),
            ),
          );
  }

  // 동영상 길이 표시
  _playTime(AssetEntity asset) {
    return Positioned(
      bottom: 5.h,
      right: 8.w,
      child: asset.type == AssetType.video
          ? Container(
              padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                borderRadius: BorderRadius.circular(6.r),
              ),
              child: Text(
                '${_convertDuration(asset.duration)}',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w400,
                ),
              ),
            )
          : Container(),
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
