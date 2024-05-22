import 'package:cached_network_image/cached_network_image.dart';
import 'package:cached_video_player_plus/cached_video_player_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:foreats/utils/global_toast_controller.dart';
import 'package:foreats/utils/text_style.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:lottie/lottie.dart';

import '../../home/home_controller.dart';
import '../../utils/app_routes.dart';
import '../../utils/colors.dart';
import '../../utils/logger.dart';
import '../../widget/description_text.dart';
import '../../widget/login_bottom_sheet.dart';
import '../login/user_store.dart';
import 'feed_controller.dart';

class FeedScreen extends GetView<FeedController> {
  FeedScreen({super.key});

  final _logger = Logger();

  @override
  Widget build(BuildContext context) {

    Get.put(AppLog());

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.black,
      systemNavigationBarIconBrightness: Brightness.light,
    ));

    return Scaffold(
      body: Obx(() {
        if (controller.isLoading) {
          return const Center(child: CircularProgressIndicator());
        } else {
          if (controller.feedList.isEmpty) {
            return SizedBox(
              width: 1.sw,
              height: 1.sh,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Lottie.asset(
                    'assets/lottie/empty_video.json',
                    width: 250.w,
                    height: 250.h,
                  ),
                  Text(
                    '게시물이 존재하지 않아요 😢',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            );
          } else {
            return PageView.builder(
              controller: controller.pageController,
              scrollDirection: Axis.vertical,
              itemCount: controller.feedList.length,
              onPageChanged: (index) async {
                controller.currentFeedIndex.value = index;
                controller.allPause();
                controller.allMute();
                controller.initializeVideoPlayer(controller.videoControllerList);
                controller.fetchLikes(controller.feedList[index].seq ?? '');
                controller.fetchBookmarks(controller.feedList[index].seq ?? '');
              },
              itemBuilder: (context, index) {
                return Obx(
                  () => Stack(
                    children: [
                      CachedVideoPlayerPlus(controller.videoControllerList[controller.currentFeedIndex.value][controller.currentVideoUrlIndex.value]),
                      _topMenu(context, index),
                      _feedInfo(context, index),
                      _indicator(context),
                    ],
                  ),
                );
              },
            );
          }
        }
      }),
    );
  }

  /// 상단 메뉴
  _topMenu(BuildContext context, int index) {
    return InkWell(
        onTap: () {
          //controller.showMore(index);
        },
        child: Container(
          margin: EdgeInsets.only(top: 24.h, left: 10.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
                child: Text('4Eat',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 28.sp,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Whisper')),
              ),
              // 검색, 지도, 음소거
              Row(
                children: [
                  InkWell(
                    onTap: () {
                      Get.toNamed(AppRoutes.search);
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 10.w, vertical: 10.h),
                      child: SvgPicture.asset('assets/images/ic_search.svg',
                          color: Colors.white, width: 20.w, height: 20.h),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      Get.toNamed(AppRoutes.map, arguments: {
                        'storeName': controller.feedList[index].storeName,
                        'storeAddress': controller.feedList[index].storeAddress,
                        'storeType': controller.feedList[index].storeType,
                        'lonlat': [
                          double.parse(controller.feedList[index].storeLonlat!
                              .split(',')[0]),
                          double.parse(controller.feedList[index].storeLonlat!
                              .split(',')[1])
                        ]
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 10.w, vertical: 10.h),
                      child: SvgPicture.asset('assets/images/ic_map.svg',
                          color: Colors.white, width: 20.w, height: 20.h),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      controller.changeMute(index);
                    },
                    child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 10.w, vertical: 10.h),
                        child: Obx(
                          () => SvgPicture.asset(
                            controller.isMuted
                                ? 'assets/images/ic_volume_off.svg'
                                : 'assets/images/ic_volume_up.svg',
                            width: 20.w,
                            height: 20.h,
                            colorFilter:
                                ColorFilter.mode(Colors.white, BlendMode.srcIn),
                          ),
                        )),
                  ),
                ],
              ),
            ],
          ),
        ));
  }

  /// 비디오 인디케이터
  _indicator(BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Obx(
          //   () =>
          //       SizedBox(
          //       width: 1.sw,
          //       height: 2.h,
          //       child: LinearProgressIndicator(
          //         value: controller.duration.value.toDouble() /
          //             controller
          //                 .videoControllerList[
          //                     controller.currentVideoIndex.value]
          //                 .value
          //                 .duration
          //                 .inSeconds
          //                 .toDouble(),
          //         valueColor: AlwaysStoppedAnimation(
          //             Theme.of(context).colorScheme.secondary),
          //         backgroundColor: Colors.grey[300],
          //       )),
          // ),
        ],
      ),
    );
  }

  /// 게시물 정보
  _feedInfo(BuildContext context, int index) {
    return Positioned(
      bottom: 14.h,
      left: 10.w,
      right: 10.w,
      child: InkWell(
        onTap: () {
          //controller.showMore(index);
          controller.isFeedMore = !controller.isFeedMore;
          _logger.d('isFeedMore: ${controller.isFeedMore}');
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _feedRegisterUserInfo(context, index),
                    _feedDescriptionText(context, index),
                    _feedStoreInfo(context, index),
                    _feedHashtags(context, index),
                    _feedComments(context, index),
                  ],
                ))
          ],
        ),
      ),
    );
  }

  /// 게시물 등록자 정보
  _feedRegisterUserInfo(BuildContext context, int index) {
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
                      child: Obx(
                        () => CachedNetworkImage(
                          imageUrl:
                              controller.feedList[index].profilePhoto ?? '',
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
                    ),
                    SizedBox(width: 10.w),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          controller.feedList[index].usernickname ?? '',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w700,
                            height: 0,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          '@${controller.feedList[index].userid ?? ''}',
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
          Row(
            children: [
              InkWell(
                onTap: () {
                  // 좋아요
                  controller.isFeedBookmark
                      ? controller.removeBookmark(
                          FeedController.to.feedList[index].seq ?? '')
                      : controller.addBookmark(
                          FeedController.to.feedList[index].seq ?? '');
                },
                child: Obx(
                  () => Container(
                    padding: EdgeInsets.only(top: 4.h),
                    child: Icon(
                      controller.isFeedBookmark
                          ? Icons.bookmark
                          : Icons.bookmark_border,
                      color: controller.isFeedBookmark
                          ? Theme.of(context)
                              .colorScheme
                              .tertiary
                              .withOpacity(0.8)
                          : Colors.white,
                      size: 20.w,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 10.w),
              InkWell(
                onTap: () {
                  // 좋아요
                  controller.isFeedLike
                      ? controller.removeLike(
                          FeedController.to.feedList[index].seq ?? '')
                      : controller
                          .addLike(FeedController.to.feedList[index].seq ?? '');
                },
                child: Container(
                  padding: EdgeInsets.only(top: 4.h),
                  child: Icon(
                    controller.isFeedLike
                        ? Icons.favorite
                        : Icons.favorite_border,
                    color: controller.isFeedLike ? Colors.red : Colors.white,
                    size: 20.w,
                  ),
                ),
              ),
              SizedBox(width: 10.w),
              InkWell(
                onTap: () {
                  // 공유
                  controller
                      .shareFeed(FeedController.to.feedList[index].seq ?? '');
                },
                child: Container(
                  padding: EdgeInsets.only(top: 4.h),
                  child: Icon(
                    Icons.share,
                    color: Colors.white,
                    size: 20.w,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 게시물 설명
  _feedDescriptionText(BuildContext context, int index) {
    return SizedBox(
      width: Get.width * 0.85,
      child: Obx(
        () => DescriptionText(
          text: controller.feedList[index].description ?? '',
        ),
      ),
    );
  }

  /// 가게 정보
  _feedStoreInfo(BuildContext context, int index) {
    return Container(
      //height: !FeedController.to.isFeedMore ? 0.0.sh : 0.15.sh,
      margin: EdgeInsets.only(top: 4.h),
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 4.h),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkWell(
                onTap: () {
                  Get.toNamed(AppRoutes.store, arguments: {
                    'storeName': controller.feedList[index].storeName,
                    'storeAddress': controller.feedList[index].storeAddress,
                    'storeType': controller.feedList[index].storeType,
                    'lonlat': [
                      double.parse(controller.feedList[index].storeLonlat!.split(',')[0]),
                      double.parse(controller.feedList[index].storeLonlat!.split(',')[1])
                    ]
                  });
                },
                child: Row(
                  // 밑줄에 맞춤
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      controller.feedList[index].storeName ?? '',
                      style: TextStyle(
                        color: Colors.cyan[500],
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(width: 5.w),
                    Text(
                      controller.feedList[index].storeType ?? '',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w600,
                        height: 2.0,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                controller.feedList[index].storeAddress ?? '',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w400,
                ),
              ),
              controller.isFeedMore
                  ? Container(
                      width: 0.8.sw,
                      margin: EdgeInsets.only(top: 10.h),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '메뉴',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 5.h),
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 10.w, vertical: 5.h),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                            child: SingleChildScrollView(
                              child: Text(
                                controller.convertMenuList(
                                    controller.feedList[index].storeMenuInfo ??
                                        ''),
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  color: Colors.white,
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 10.h),
                          controller.convertNaverPlaceContext(
                                      controller.feedList[index].storeContext ??
                                          '') !=
                                  ''
                              ? Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '가게 소개',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    SizedBox(height: 5.h),
                                    Text(
                                      // controller.feedList[index].storeContext ?? '',
                                      // 스트링을 리스트로
                                      controller.convertNaverPlaceContext(
                                          controller.feedList[index]
                                                  .storeContext ??
                                              ''),
                                      style: TextStyle(
                                        color: CupertinoColors.activeGreen,
                                        fontSize: 11.sp,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                )
                              : Container(),
                        ],
                      ),
                    )
                  : Container(),
            ],
          ),
        ],
      ),
    );
  }

  ///해시태그
  _feedHashtags(BuildContext context, int index) {
    return Container(
      height: 24.h,
      margin: EdgeInsets.only(top: 4.h, left: 4.w),
      child: SizedBox(
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: controller.feedList[index].hashTags?.length ?? 0,
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
                controller.feedList[index].hashTags?[idx] ?? '',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 11.sp,
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

  /// 댓글
  _feedComments(BuildContext context, int index) {
    return Obx(
      () => Container(
        width: 1.sw,
        margin: EdgeInsets.only(top: 10.h, left: 4.w),
        child: InkWell(
          onTap: () async {
            // 댓글 시트
            //controller.commentController.clear();
            Get.bottomSheet(
              _commentSheet(context, index),
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
                  controller.commentArrayList.isEmpty
                      ? '댓글 0개'
                      : '댓글 ${controller.commentArrayList[index].length + controller.commentArrayList[index].fold(0, (previousValue, element) => previousValue + element.replyCommentList!.length)}개',
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
      ),
    );
  }

  /// 댓글 시트
  _commentSheet(BuildContext context, int feedIndex) {
    return Obx(
      () => controller.isCommentLoading
          ? Container(
              width: Get.width,
              height: 0.25.sh,
              color: Colors.white,
              child: Center(
                child: CircularProgressIndicator(
                  color: Colors.grey[100],
                ),
              ),
            )
          :
          // 댓글 리스트 및 작성 창
          Obx(
              () => SingleChildScrollView(
                child: Container(
                  width: Get.width,
                  padding:
                      EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20.r),
                      topRight: Radius.circular(20.r),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // 댓글 리스트
                      controller.commentArrayList.isEmpty
                          ? SizedBox(
                              width: Get.width,
                              height: 0.25.sh,
                              child: Center(
                                child: Text(
                                  '댓글이 없어요 😢',
                                  style: TextStyle(
                                    color: Colors.grey[400],
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            )

                          // 댓글 리스트
                          : Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width: Get.width,
                                  // height: controller.commentArrayList[feedIndex].length < 10
                                  //     ? 0.4.sh
                                  //     : 0.8.sh,
                                  child: Obx(
                                    () => RefreshIndicator(
                                      onRefresh: () async {
                                        // await controller.fetchComments(
                                        //     controller.feedList[feedIndex].feedId ?? '',
                                        //     feedIndex);
                                      },
                                      child: buildComment(feedIndex),
                                    ),
                                  ),
                                ),
                              ],
                            ),

                      // 댓글 작성 창
                      Container(
                        width: 1.sw,
                        padding: EdgeInsets.symmetric(horizontal: 10.w),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: controller.commentController,
                                onTap: () {
                                  _logger.d('onTap');

                                  if (UserStore.to.isLoggedIn) {
                                    if (controller.commentController.text.contains('@')) {
                                      controller.isMentionLoading = true;
                                      controller.fetchMentionUser(controller.commentController.text);
                                    } else {
                                      controller.isMentionLoading = false;
                                    }
                                  } else {
                                    Get.bottomSheet(const LoginBottomSheet());
                                  }

                                },
                                onChanged: (value) {
                                  if (UserStore.to.isLoggedIn) {
                                    if (controller.commentController.text.contains('@')) {
                                      controller.isMentionLoading = true;
                                      controller.fetchMentionUser(controller.commentController.text);
                                    } else {
                                      controller.isMentionLoading = false;
                                    }
                                  } else {
                                    Get.bottomSheet(const LoginBottomSheet());
                                  }
                                },
                                decoration: InputDecoration(
                                  hintText: '댓글을 입력해주세요',
                                  hintStyle: TextStyle(
                                    color: gray600,
                                    fontSize: 10.sp,
                                    fontWeight: FontWeight.w400,
                                  ),
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                if (UserStore.to.isLoggedIn) {

                                  FeedController.to.comment = FeedController.to.commentController.text;

                                  // 멘션 기능 추가
                                  if (FeedController.to.commentController.text.contains('@')) {
                                    // 사용자 검색
                                    FeedController.to.fetchMentionUser(FeedController.to.commentController.text);
                                  }

                                } else {
                                  Get.bottomSheet(const LoginBottomSheet());
                                }
                              },
                              child: InkWell(
                                onTap: () async {
                                  if (UserStore.to.isLoggedIn) {
                                    if (controller.commentController.text.isNotEmpty) {
                                      if (controller.isReply) {
                                        await FeedController.to.addReplyComment(
                                          feedIndex,
                                          FeedController.to.commentController.text,
                                          FeedController.to.feedList[feedIndex].seq ?? '',
                                        );
                                      } else {
                                        await FeedController.to.addComment(
                                          FeedController.to.feedList[feedIndex].seq ?? '',
                                          FeedController.to.commentController.text,
                                        );
                                      }
                                    } else {
                                      GlobalToastController.to.showToast(
                                        '댓글을 입력해주세요',
                                      );
                                    }
                                  } else {
                                    Get.bottomSheet(const LoginBottomSheet());
                                  }
                                },
                                child: Container(
                                  padding: EdgeInsets.all(10.w),
                                  child: SvgPicture.asset(
                                    'assets/images/ic_send.svg',
                                    colorFilter: ColorFilter.mode(
                                        gray400, BlendMode.srcIn),
                                    width: 20.w,
                                    height: 20.h,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      controller.mentionUserList.isEmpty
                          ? Container()
                          : feedCommentMentionList(),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  /// 댓글 리스트
  ListView buildComment(int feedIndex) {
    return ListView.separated(
      shrinkWrap: true,
      itemCount: controller.commentArrayList[feedIndex].length,
      itemBuilder: (context, commentIndex) {
        return SizedBox(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 댓글 작성자 정보
              Row(
                children: [
                  // 댓글 작성자 프로필
                  CachedNetworkImage(
                    imageUrl: controller.commentArrayList[feedIndex].isEmpty
                        ? ''
                        : controller.commentArrayList[feedIndex][commentIndex].userPhotoUrl ?? '',
                    imageBuilder: (context, imageProvider) => Container(
                      width: 30.w,
                      height: 30.h,
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
                      width: 30.w,
                      height: 30.h,
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
                  // 댓글 작성자 정보
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            controller.commentArrayList[feedIndex].isEmpty
                                ? ''
                                : controller.commentArrayList[feedIndex][commentIndex].userNickname ?? '',
                            style: TextStyleUtils().commentTitleTextStyle(),
                          ),
                          SizedBox(width: 4.w),
                          // 작성자 표시
                          // Container(
                          //   padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                          //   decoration: BoxDecoration(
                          //     color: Theme.of(context).colorScheme.secondary.withOpacity(0.2),
                          //     borderRadius: BorderRadius.circular(4.r),
                          //   ),
                          //   child: Text(
                          //     controller.commentArrayList[feedIndex][commentIndex].userNickname.toString() == UserStore.to.nickname.toString()
                          //         ? '작성자'
                          //         : '',
                          //     style: TextStyleUtils().commentContentTextStyle(),
                          //   ),
                          // ),
                        ],
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        controller.commentArrayList[feedIndex].isEmpty
                            ? ''
                            : HomeController.to.timeAgo(/* string을 date로 변환 */
                                DateTime.parse(
                                controller
                                    .commentArrayList[feedIndex][commentIndex]
                                    .createdAt
                                    .toString(),
                              )),
                        style: TextStyleUtils().commentContentTextStyle(),
                      ),
                    ],
                  ),
                ],
              ),
              // 댓글 내용
              feedCommentsItem(feedIndex, commentIndex),
            ],
          ),
        );
      },
      separatorBuilder: (context, index) {
        return SizedBox(height: 14.h);
      },
    );
  }

  /// 댓글 내용
  Widget feedCommentsItem(int feedIndex, int commentIndex) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: EdgeInsets.only(left: 40.w),
          child: Row(
            children: [
              Row(
                children: [
                  // 댓글 내용
                  Text(
                    controller.commentArrayList[feedIndex].isEmpty
                        ? ''
                        : controller.commentArrayList[feedIndex][commentIndex].comment ?? '',
                    style: TextStyleUtils().commentContentTextStyle(),
                  ),
                  SizedBox(width: 10.w),
                  // 답글 버튼
                  InkWell(
                    onTap: () {
                      controller.isReply = true;
                      controller.commentController.text =
                          '@${controller.commentArrayList[feedIndex][commentIndex].userNickname} ';
                    },
                    child: Text(
                      '답글',
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  //SizedBox(width: 10.w),
                  // 삭제 버튼
                  /*InkWell(
                    onTap: () async {
                      await FeedController.to.deleteComment(
                        FeedController.to.commentArrayList[feedIndex][commentIndex].feedId ?? '',
                        FeedController.to.commentArrayList[feedIndex][commentIndex].commentId ?? '',
                        feedIndex,
                      );
                    },
                    child: Text(
                      '삭제',
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),*/
                ],
              ),
              Spacer(),
              InkWell(
                onTap: () {
                  Get.bottomSheet(
                    Container(
                      width: 1.sw,
                      padding: EdgeInsets.symmetric(
                          horizontal: 10.w),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20.r),
                          topRight: Radius.circular(20.r),
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          ListTile(
                            onTap: () async {
                              // 댓글 삭제
                              //_logger.d('feedIndex: $feedIndex');
                              await FeedController.to.deleteComment(
                                FeedController.to.commentArrayList[feedIndex][commentIndex].feedId ?? '',
                                FeedController.to.commentArrayList[feedIndex][commentIndex].commentId ?? '',
                                feedIndex,
                              );
                            },
                            title: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '삭제',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                SvgPicture.asset(
                                  'assets/images/ic_delete.svg',
                                  color: gray500,
                                  width: 16.w,
                                  height: 16.h,
                                ),
                              ],
                            ),
                          ),
                          ListTile(
                            onTap: () {
                              Get.back();
                            },
                            title: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '신고하기',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Icon(
                                  Icons.report_gmailerrorred_outlined,
                                  color: Colors.red,
                                  size: 16.w,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    backgroundColor: Colors.transparent,
                    isScrollControlled: true,
                  );
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
                  child:
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      InkWell(
                        onTap: () {
                          //_logger.d('feedIndex: $feedIndex');
                          // 댓글 좋아요
                          FeedController.to.addCommentLike(
                              FeedController.to.commentArrayList[feedIndex][commentIndex].feedId ?? '',
                              FeedController.to.commentArrayList[feedIndex][commentIndex].commentId ?? '',
                              feedIndex);
                        },
                        child: Icon(
                          Icons.thumb_up_alt_outlined,
                          color: Theme.of(Get.context!).colorScheme.secondary,
                          size: 14.w,
                        ),
                      ),
                      SizedBox(width: 2.w),
                      Text(
                        FeedController.to.commentArrayList[feedIndex].isEmpty
                            ? ''
                            : FeedController.to.commentArrayList[feedIndex][commentIndex].likeCount.toString() ?? '',
                        style: TextStyle(
                          color: gray500,
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(width: 5.w),
                      Icon(
                        Icons.more_vert_outlined,
                        color: gray500,
                        size: 14.w,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        // 대댓글
        controller.commentArrayList[feedIndex][commentIndex].replyCommentList?.isEmpty == true
            ? Container()
            : buildReplies(feedIndex, commentIndex),
      ],
    );
  }

  /// 대댓글 내용
  Widget buildReplies(int feedIndex, int commentIndex) {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: controller.commentArrayList[feedIndex][commentIndex].replyCommentList?.length,
      itemBuilder: (context, replyIndex) {
        return Container(
          margin: EdgeInsets.only(left: 20.w, top: 4.h,),
          child: Container(
            margin: EdgeInsets.only(top: 4.h, left: 4.w),
            child: Column(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CachedNetworkImage(
                          imageUrl: controller.commentArrayList[feedIndex][commentIndex]
                              .replyCommentList![0].userPhotoUrl ??
                              '',
                          imageBuilder: (context, imageProvider) => Container(
                            width: 20.w,
                            height: 20.h,
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
                            width: 20.w,
                            height: 20.h,
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
                        Text(
                          controller.commentArrayList[feedIndex][commentIndex].replyCommentList![replyIndex].userNickname!,
                          style: TextStyleUtils().commentTitleTextStyle(),
                        ),
                      ],
                    ),
                    Container(
                      margin: EdgeInsets.only(left: 30.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            // timeago
                            HomeController.to.timeAgo(
                              DateTime.parse(
                                controller.commentArrayList[feedIndex][commentIndex]
                                    .replyCommentList![replyIndex].createdAt
                                    .toString(),
                              ),
                            ),
                            style: TextStyleUtils().commentContentTextStyle(),
                          ),
                          SizedBox(height: 10.h),
                          RichText(
                            text: controller.commentArrayList[feedIndex][commentIndex].replyCommentList?.isEmpty == true
                                ? TextSpan()
                                : TextSpan(children: [
                                    TextSpan(
                                      text: controller
                                              .commentArrayList[feedIndex][commentIndex]
                                              .replyCommentList![replyIndex]
                                              .comment!
                                              .startsWith('@')
                                          ? '${controller.commentArrayList[feedIndex][commentIndex].replyCommentList![replyIndex].comment!.split(' ')[0]} '
                                          : '',
                                      style: TextStyleUtils().commentContentSetColorTextStyle(Theme.of(Get.context!).colorScheme.secondary),
                                    ),
                                    TextSpan(
                                      text: // 골뱅이 제외 다 보여줌
                                          controller.commentArrayList[feedIndex][commentIndex]
                                                  .replyCommentList![replyIndex]
                                                  .comment!
                                                  .startsWith('@')
                                              ? controller
                                                  .commentArrayList[feedIndex][commentIndex]
                                                  .replyCommentList![replyIndex]
                                                  .comment!
                                                  .split(' ')
                                                  .sublist(1)
                                                  .join(' ')
                                              : controller
                                                  .commentArrayList[feedIndex][commentIndex]
                                                  .replyCommentList![replyIndex]
                                                  .comment!,
                                      style: TextStyleUtils().commentContentTextStyle(),
                                    ),
                                  ]),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// 멘션 유저 리스트
  Widget feedCommentMentionList() {
    return SizedBox(
      width: 1.sw,
      height: 40.h,
      child: ListView.builder(
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        itemCount: controller.mentionUserList.length,
        itemBuilder: (context, idx) {
          return InkWell(
            onTap: () {
              controller.commentController.text = controller.commentController.text.replaceAll('@${controller.mentionUserList[idx].nickname}', '');
              controller.commentController.text = '@${controller.mentionUserList[idx].nickname} ';
              controller.mentionUserList.clear();
              controller.isMentionLoading = false;
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
              child: Text(
                '@${controller.mentionUserList[idx].nickname}',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.secondary,
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

}
