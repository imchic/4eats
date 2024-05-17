import 'package:cached_network_image/cached_network_image.dart';
import 'package:cached_video_player_plus/cached_video_player_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../../model/feed_model.dart';
import '../../widget/description_text.dart';

class FeedDetailScreen extends StatefulWidget {
  FeedDetailScreen({super.key});

  @override
  State<FeedDetailScreen> createState() => _FeedDetailScreenState();
}

class _FeedDetailScreenState extends State<FeedDetailScreen> {
  late CachedVideoPlayerPlusController _controller;

  int _currentVideoIndex = 0;
  List<String> _videoUrls = [];

  final FeedModel feedDetail = Get.arguments['detailFeed'];

  @override
  void initState() {
    super.initState();
    // args
    _videoUrls = feedDetail.videoUrls!;
    _initializeVideoPlayer();
  }

  Future<void> _initializeVideoPlayer() async {
    _controller = CachedVideoPlayerPlusController.networkUrl(
        Uri.parse(_videoUrls[_currentVideoIndex]))
      ..initialize().then((_) {
        setState(() {});
        _controller.play();
      });
    _controller.addListener(_onVideoPlayerStateChanged);
  }

  _onVideoPlayerStateChanged() {
    if (_controller.value.isPlaying) {
      // Video is playing
    } else if (_controller.value.isBuffering) {
      // Video is buffering
    } else if (_controller.value.isCompleted) {
      print('Video completed');
      // Video playback completed, play the next video
      if (_currentVideoIndex < _videoUrls.length - 1) {
        _currentVideoIndex++;
        _controller.dispose();
        _initializeVideoPlayer();
      } else {
        // All videos played, do something else or loop back to the first video
        _currentVideoIndex = 0;
        _controller.dispose();
        _initializeVideoPlayer();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // 첫번째 영상 끝나면 다음 영상 보여주기
    return Scaffold(
      body: _controller.value.isInitialized
          ? Stack(
            children: [
              CachedVideoPlayerPlus(_controller),
              _backButton(context),
              _feedDetailInfo(context),
            ])
          : Center(child: const CircularProgressIndicator()),
    );
  }

  Widget _backButton(BuildContext context) {
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
        },
      ),
    );
  }

  /// 게시물 상세 정보
  _feedDetailInfo(BuildContext context) {
    return Positioned(
      bottom: 14.h,
      left: 10.w,
      right: 10.w,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
              width: Get.width * 0.95,
              // height: 200.h,
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _feedDetailRegisterUserInfo(context),
                  _feedDetailDescriptionText(context),
                  _feedDetailStoreInfo(context),
                  _feedDetailHashtags(context),
                  _comments(context),
                ],
              ))
        ],
      ),
    );
  }

// 게시물 상세 제목
  _feedDetailRegisterUserInfo(BuildContext context) {
    return SizedBox(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 40.w,
                      height: 40.h,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                      ),
                      child: CachedNetworkImage(
                        imageUrl: feedDetail.profilePhoto ?? '',
                        imageBuilder: (context, imageProvider) => Container(
                          width: 40.w,
                          height: 40.h,
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
                    SizedBox(width: 10.w),
                    Text(
                      feedDetail.userid ?? '',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Row(
            children: [
              InkWell(
                onTap: () {},
                child: Container(
                  padding: EdgeInsets.only(top: 4.h),
                  child: SvgPicture.asset(
                    'assets/images/ic_bookmark.svg',
                    colorFilter:
                        ColorFilter.mode(Colors.white, BlendMode.srcIn),
                    width: 20.w,
                    height: 20.h,
                  ),
                ),
              ),
              SizedBox(width: 10.w),
              InkWell(
                onTap: () {},
                child: Container(
                  padding: EdgeInsets.only(top: 4.h),
                  child: SvgPicture.asset(
                    'assets/images/ic_heart.svg',
                    colorFilter:
                        ColorFilter.mode(Colors.white, BlendMode.srcIn),
                    width: 20.w,
                    height: 20.h,
                  ),
                ),
              ),
              SizedBox(width: 10.w),
              InkWell(
                onTap: () {},
                child: Container(
                  padding: EdgeInsets.only(top: 4.h),
                  child: SvgPicture.asset(
                    'assets/images/ic_share.svg',
                    colorFilter:
                        ColorFilter.mode(Colors.white, BlendMode.srcIn),
                    width: 20.w,
                    height: 20.h,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 게시물 상세 설명
  _feedDetailDescriptionText(BuildContext context) {
    return SizedBox(
      width: Get.width * 0.85,
      child: DescriptionText(
        text: feedDetail.description ?? '',
      ),
    );
  }

  /// 게시물 상세 가게 정보
  _feedDetailStoreInfo(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 4.h),
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 4.h),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                // 밑줄에 맞춤
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    feedDetail.storeName ?? '',
                    style: TextStyle(
                      color: Colors.cyan[500],
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(width: 5.w),
                  Text(
                    feedDetail.storeType ?? '',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w600,
                      height: 2.0,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 2.h),
              Text(
                feedDetail.storeAddress ?? '',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 게시물 상세 해시태그
  _feedDetailHashtags(BuildContext context) {
    return Container(
      height: 24.h,
      margin: EdgeInsets.only(top: 10.h, left: 4.w),
      child: SizedBox(
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: feedDetail.hashTags?.length ?? 0,
          itemBuilder: (context, idx) {
            return Container(
              alignment: Alignment.center,
              margin: EdgeInsets.only(right: 5.w),
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4.r),
              ),
              child: Text(
                feedDetail.hashTags?[idx] ?? '',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          },
          scrollDirection: Axis.horizontal,
        ),
      ),
    );
  }

  // 댓글
  _comments(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 10.h, left: 4.w),
      child: InkWell(
        onTap: () {
          Get.bottomSheet(
            _commentSheet(context),
            backgroundColor: Colors.transparent,
            isScrollControlled: true,
          );
        },
        child: SizedBox(
          width: 260.w,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                '댓글 10개',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(width: 5.w),
              Text(
                '좋아요 100개',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  _commentSheet(BuildContext context) {
    return Container(
      width: Get.width,
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.r),
          topRight: Radius.circular(20.r),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 20.w,
            height: 2.h,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
          SizedBox(
            width: Get.width,
            height: 0.25.sh,
            child: ListView.builder(
              itemCount: 3,
              itemBuilder: (context, idx) {
                return SizedBox(
                  width: Get.width,
                  height: 50.h,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CachedNetworkImage(
                            imageUrl:
                            feedDetail.profilePhoto ??
                                '',
                            imageBuilder: (context, imageProvider) => Container(
                              width: 40.w,
                              height: 40.h,
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
                                color: Colors.grey[100],
                              ),
                            ),
                            errorWidget: (context, url, error) => Container(
                              width: 40.w,
                              height: 40.h,
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
                          SizedBox(width: 10.w),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                feedDetail.userid ?? '',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(height: 2.h),
                              Text(
                                '댓글입니다.',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 10.sp,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

    @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }
}
