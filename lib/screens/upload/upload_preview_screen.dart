import 'package:cached_video_player_plus/cached_video_player_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:foreats/screens/upload/upload_controller.dart';
import 'package:get/get.dart';

class UploadPreviewScreen extends GetView<UploadController> {
  const UploadPreviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
        canPop: true,
        onPopInvoked: (bool isPop) {
          if (isPop) {
            controller.videoController.dispose();
          }
        },
        child: Scaffold(
          body: FutureBuilder<void>(
            future: controller.previewVideo(),
            builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              } else {
                return Stack(
                  children: [
                    CachedVideoPlayerPlus(controller.videoController),
                    _back(),
                    _previewVideoIndicator(context),
                  ],
                );
              }
            },
          ),
        ));
  }

  // back button
  Widget _back() {
    return Positioned(
      left: 10.w,
      top: 44.h,
      child: IconButton(
        icon: Icon(
          CupertinoIcons.back,
          color: Colors.white,
          size: 20.sp,
        ),
        onPressed: () {
          Get.back();
          controller.videoController.dispose();
        },
      ),
    );
  }

  Widget _previewVideoIndicator(BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 20.h,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: Get.width * 0.9,
            height: 2.h,
            alignment: Alignment.center,
            child: VideoProgressIndicator(
              controller.videoController,
              allowScrubbing: true,
              colors: VideoProgressColors(
                playedColor: Theme.of(context).colorScheme.secondary,
                bufferedColor: Colors.black.withOpacity(0.25),
                backgroundColor: Colors.black.withOpacity(0.25),
              ),
              padding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
    );
  }
}
