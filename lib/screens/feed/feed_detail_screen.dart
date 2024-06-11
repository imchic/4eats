import 'package:cached_network_image/cached_network_image.dart';
import 'package:cached_video_player_plus/cached_video_player_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../../home/home_controller.dart';
import '../../utils/app_routes.dart';
import '../../utils/colors.dart';
import '../../utils/dialog_util.dart';
import '../../utils/global_toast_controller.dart';
import '../../utils/logger.dart';
import '../../utils/text_style.dart';
import '../../widget/description_text.dart';
import '../../widget/login_bottomsheet.dart';
import '../login/user_store.dart';
import 'feed_controller.dart';

class FeedDetailScreen extends GetView<FeedController> {
  FeedDetailScreen({super.key});

  @override
  initState() {
    AppLog.to.d('FeedScreen');
  }

  @override
  Widget build(BuildContext context) {
    Get.put(AppLog());

    final logger = AppLog.to;
    logger.d('FeedDetailScreen');

    return Scaffold(
      body: FutureBuilder(
        future: controller.fetchDetailFeed(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return DialogUtil().buildLoadingDialog();
          } else {
            return Obx(() =>
                    Stack(
                      children: [
                        // 동영상
                        controller.detailController.value.isInitialized ? Positioned(
                          top: 0.h,
                          left: 0.w,
                          child: Container(
                            width: 1.sw,
                            height: 1.sh,
                            child: AspectRatio(
                              aspectRatio: controller.detailController.value.aspectRatio,
                              child: CachedVideoPlayerPlus(controller.detailController),
                            ),
                          ),
                        ) : Container(),
                        // 뒤로가기 버튼
                        Positioned(
                          top: 20.h,
                          left: 0.w,
                          child: Container(
                            width: 1.sw,
                            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                            child: Row(
                              children: [
                                InkWell(
                                  onTap: () {
                                    Get.back();
                                  },
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 10.w, vertical: 10.h),
                                    child: Icon(
                                      Icons.arrow_back_ios,
                                      color: Colors.white,
                                      size: 14.w,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        // 상단 메뉴
                        _topMenu(context, 0),
                        // 게시물 정보
                        _feedInfo(context, 0),
                      ],
                    ),
                );
          }
        },
      ),
    );
  }

  /// 상단 메뉴
  _topMenu(BuildContext context, int index) {
    return Column(
      children: [
        Container(
          width: 1.sw,
          margin: EdgeInsets.only(top: 44.h, left: 10.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: EdgeInsets.only(top: 24.h),
                padding: EdgeInsets.symmetric(horizontal: 10.w),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        // 시군구 표현
                        controller.detailFeed.storeAddress == 'null' || controller.detailFeed.storeAddress == ''
                            ? ''
                            : controller.detailFeed.storeAddress!.split(' ')[1],
                        style: TextStyleUtils.feedAddressTitle(),
                      ),
                    ]
                ),
              ),
              // 구분자
              Divider(
                height: 14.h,
                color: Colors.white,
                thickness: 1,
                indent: 10.w,
                endIndent: 10.w,
              ),
              // 가게상호명
              InkWell(
                onTap: () {
                  // 가게 상세 페이지로 이동
                  Get.toNamed(AppRoutes.store, arguments: {
                    'storeName': controller.detailFeed.storeName ?? '',
                    'storeAddress': controller.detailFeed.storeAddress ?? '',
                    'storeType': controller.detailFeed.storeType ?? '',
                    'storeMenu': controller.detailFeed.storeMenuInfo ?? '',
                    'storeContext': controller.detailFeed.storeContext ?? '',
                    'lonlat': [
                      double.parse(controller.detailFeed.storeLngLat!.split(',')[0]),
                      double.parse(controller.detailFeed.storeLngLat!.split(',')[1])
                    ]
                  });
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(controller.detailFeed.storeName ?? '', style: TextStyleUtils.feedAddressTitle(fontSize: 10.sp)),
                      SizedBox(width: 10.w),
                      Text(controller.detailFeed.storeType ?? '', style: TextStyleUtils.feedAddressTitle(fontSize: 8.sp, color: gray300)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
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
          //_logger.d('isFeedMore: ${controller.isFeedMore}');
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
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
                    // 프로필 사진
                    Container(
                      width: 50.w,
                      height: 50.h,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                      ),
                      child: Obx(
                            () => CachedNetworkImage(
                          imageUrl:
                          controller.detailFeed.userProfilePhoto ?? '',
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
                            width: 50.w,
                            height: 50.h,
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
                    // 닉네임
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          controller.detailFeed.userNickname ?? '',
                          style: TextStyleUtils.whiteTextStyle(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Container(
                          alignment: Alignment.center,
                          height: 0.028.sh,
                          padding: EdgeInsets.symmetric(
                              horizontal: 8.w, vertical: 4.h),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50.r),
                            gradient: LinearGradient(
                              colors: [
                                Color(0xffFF512F),
                                Color(0xffF09819),
                              ],
                              begin: Alignment.centerRight,
                              end: Alignment.centerLeft,
                            ),
                          ),
                          child: Text(
                            '포잇터',
                            textAlign: TextAlign.center,
                            style: TextStyleUtils.whiteTextStyle(
                              fontSize: 9.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        )
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
      width: Get.width,
      child: Obx(
            () => Container(
          child: DescriptionText(
            text: controller.detailFeed.description ?? '',
            fontSize: 11.sp,
            fontWeight: FontWeight.w400,
          ),
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
              // 확장이 되었을 경우
              controller.isFeedMore
                  ? Container(
                width: 0.8.sw,
                margin: EdgeInsets.only(top: 10.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '메뉴',
                      style: TextStyleUtils.whiteTextStyle(
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
                              controller.detailFeed.storeMenuInfo ??
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
                        controller.detailFeed.storeContext ??
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
                          // controller.detailFeed.storeContext ?? '',
                          // 스트링을 리스트로
                          controller.convertNaverPlaceContext(
                              controller.detailFeed
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
      margin: EdgeInsets.symmetric(horizontal: 10.w),
      height: 26.h,
      child: SizedBox(
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: controller.detailFeed.hashTags?.length ?? 0,
          itemBuilder: (context, idx) {
            return Container(
              alignment: Alignment.center,
              margin: EdgeInsets.only(right: 5.w),
              padding: EdgeInsets.symmetric(horizontal: 10.w),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4.r),
              ),
              child: Text(
                controller.detailFeed.hashTags?[idx] ?? '',
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

  /// 댓글
  _feedComments(BuildContext context, int index) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w),
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
        child: Container(
          width: 0.2.w,
          margin: EdgeInsets.only(top: 4.h, left: 4.w),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                '댓글 ${controller.sumReplyCount ?? 0}개',
                //'',
                style: TextStyleUtils.whiteTextStyle(
                  fontSize: 9.sp,
                  //fontWeight: FontWeight.w600,
                ),
              ),
            ],
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
                controller.commentArray.isEmpty
                    ? SizedBox(
                    width: Get.width,
                    height: 0.3.sh,
                    child: Center(
                      child: Text(
                        '댓글이 없어요 😢',
                        style: TextStyleUtils.bodyTextStyle(
                          color: gray400,
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ))
                // 댓글 리스트
                    : Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: Get.width,
                      height: 0.3.sh,
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
                            if (UserStore.to.isLoginCheck.value == true) {
                              if (controller.commentController.text
                                  .contains('@')) {
                                controller.isMentionLoading = true;
                                controller.fetchMentionUser(
                                    controller.commentController.text);
                              } else {
                                controller.isMentionLoading = false;
                              }
                            } else {
                              Get.bottomSheet(const LoginBottomSheet());
                            }
                          },
                          onChanged: (value) {
                            if (UserStore.to.isLoginCheck.value == true) {
                              if (controller.commentController.text
                                  .contains('@')) {
                                controller.isMentionLoading = true;
                                controller.fetchMentionUser(
                                    controller.commentController.text);
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
                              fontWeight: FontWeight.w500,
                            ),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          if (UserStore.to.isLoginCheck.value == true) {
                            FeedController.to.comment =
                                FeedController.to.commentController.text;

                            // 멘션 기능 추가
                            if (FeedController.to.commentController.text
                                .contains('@')) {
                              // 사용자 검색
                              FeedController.to.fetchMentionUser(FeedController.to.commentController.text);
                            }
                          } else {
                            Get.bottomSheet(const LoginBottomSheet());
                          }
                        },
                        child: InkWell(
                          onTap: () async {
                            if (UserStore.to.isLoginCheck.value == true) {
                              if (controller
                                  .commentController.text.isNotEmpty) {
                                if (controller.isReply) {
                                  await FeedController.to.addReplyComment(feedIndex, FeedController.to.commentController.text, FeedController.to.feedList[feedIndex].seq ?? '',);
                                } else {
                                  await FeedController.to.addComment(FeedController.to.feedList[feedIndex].seq ?? '', FeedController.to.commentController.text,);
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
  Widget buildComment(int feedIndex) {
    return ListView.separated(
      shrinkWrap: true,
      itemCount:
      controller.commentArray.isEmpty ? 0 : controller.commentArray.length,
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
                    imageUrl: controller.commentArray.isEmpty
                        ? ''
                        : controller.commentArray.isEmpty
                        ? ''
                        : controller
                        .commentArray[commentIndex].userPhotoUrl ??
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
                    placeholder: (context, url) => Container(
                      width: 20.w,
                      height: 20.h,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.grey[200],
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
                  // 댓글 작성자 정보
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            controller.commentArray.isEmpty
                                ? ''
                                : controller.commentArray[commentIndex]
                                .userNickname ??
                                '',
                            style: TextStyleUtils.bodyTextStyle(
                              color: Colors.black,
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w500,
                            ),
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
                          //     style: TextStyleUtils.commentContentTextStyle(),
                          //   ),
                          // ),
                        ],
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        // timeago
                        HomeController.to.timeAgo(
                          DateTime.parse(
                            controller.commentArray[commentIndex].createdAt
                                .toString(),
                          ),
                        ),
                        style: TextStyleUtils.bodyTextStyle(
                          color: Colors.grey,
                          fontSize: 9.sp,
                          fontWeight: FontWeight.w500,
                        ),
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
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // 댓글 내용
                  Text(
                    controller.commentArray.isEmpty
                        ? ''
                        : controller.commentArray[commentIndex].comment ?? '',
                    style: TextStyleUtils.bodyTextStyle(
                      color: gray700,
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(width: 10.w),
                  // 답글 버튼
                  InkWell(
                    onTap: () {
                      controller.isReply = true;
                      controller.commentController.text =
                      '@${controller.commentArray[commentIndex].userNickname} ';
                    },
                    child: Text(
                      '답글',
                      style: TextStyleUtils.bodyTextStyle(
                        color: Colors.grey,
                        fontSize: 9.sp,
                        fontWeight: FontWeight.w500,
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
                      height: 0.2.sh,
                      padding: EdgeInsets.symmetric(horizontal: 10.w),
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
                                FeedController
                                    .to.commentArray[commentIndex].feedId ??
                                    '',
                                FeedController.to.commentArray[commentIndex]
                                    .commentId ??
                                    '',
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
                  padding:
                  EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      InkWell(
                        onTap: () {
                          //_logger.d('feedIndex: $feedIndex');
                          // 댓글 좋아요
                          FeedController.to.addCommentLike(
                              FeedController
                                  .to.commentArray[commentIndex].feedId ??
                                  '',
                              FeedController.to.commentArray[commentIndex]
                                  .commentId ??
                                  '',
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
                        controller.commentArray[commentIndex].likeCount
                            .toString(),
                        style: TextStyleUtils.bodyTextStyle(
                          color: Colors.grey,
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

        // 대댓글 작성 창
        // Text(
        //   controller.commentArray.isEmpty
        //       ? ''
        //       : controller.commentArray[commentIndex].replyCommentList?.isEmpty ?? true
        //           ? ''
        //           : controller.commentArray[commentIndex].replyCommentList![0].comment ?? '',
        //   style: TextStyleUtils.commentContentTextStyle(),
        // )

        // 대댓글 리스트
        //buildReplies(feedIndex, commentIndex),
        controller.commentArray.isEmpty
            ? Container()
            : controller.commentArray[commentIndex].replyCommentList?.isEmpty ??
            true
            ? Container()
            : buildReplies(feedIndex, commentIndex),
      ],
    );
  }

  /// 대댓글 내용
  Widget buildReplies(int feedIndex, int commentIndex) {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: controller.commentArray.isEmpty
          ? 0
          : controller.commentArray[commentIndex].replyCommentList?.isEmpty ??
          true
          ? 0
          : controller.commentArray[commentIndex].replyCommentList!.length,
      itemBuilder: (context, replyIndex) {
        return Container(
          margin: EdgeInsets.only(
            left: 20.w,
            top: 4.h,
          ),
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
                          imageUrl: controller.commentArray.isEmpty
                              ? ''
                              : controller.commentArray[commentIndex]
                              .replyCommentList?.isEmpty ??
                              true
                              ? ''
                              : controller
                              .commentArray[commentIndex]
                              .replyCommentList![replyIndex]
                              .userPhotoUrl ??
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
                          controller.commentArray.isEmpty
                              ? ''
                              : controller.commentArray[commentIndex]
                              .replyCommentList?.isEmpty ??
                              true
                              ? ''
                              : controller
                              .commentArray[commentIndex]
                              .replyCommentList![replyIndex]
                              .userNickname ??
                              '',
                          style: TextStyleUtils.bodyTextStyle(
                            color: Colors.black,
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w500,
                          ),
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
                                controller.commentArray[commentIndex]
                                    .replyCommentList![replyIndex].createdAt
                                    .toString(),
                              ),
                            ),
                            style: TextStyleUtils.bodyTextStyle(
                              color: Colors.grey[400]!,
                              fontSize: 9.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 10.h),
                          RichText(
                            text: controller.commentArray.isEmpty
                                ? TextSpan()
                                : TextSpan(children: [
                              TextSpan(
                                text: controller
                                    .commentArray[commentIndex]
                                    .replyCommentList![replyIndex]
                                    .comment!
                                    .startsWith('@')
                                    ? '${controller.commentArray[commentIndex].replyCommentList![replyIndex].comment!.split(' ')[0]} '
                                    : '',
                                style: TextStyleUtils.bodyTextStyle(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .secondary,
                                  fontSize: 10.sp,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              TextSpan(
                                text: // 골뱅이 제외 다 보여줌
                                controller
                                    .commentArray[commentIndex]
                                    .replyCommentList![replyIndex]
                                    .comment!
                                    .startsWith('@')
                                    ? controller
                                    .commentArray[commentIndex]
                                    .replyCommentList![replyIndex]
                                    .comment!
                                    .split(' ')
                                    .sublist(1)
                                    .join(' ')
                                    : controller
                                    .commentArray[commentIndex]
                                    .replyCommentList![replyIndex]
                                    .comment!,
                                style: TextStyleUtils.bodyTextStyle(
                                  color: gray700,
                                  fontSize: 10.sp,
                                  fontWeight: FontWeight.w500,
                                ),
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
              controller.commentController.text =
                  controller.commentController.text.replaceAll(
                      '@${controller.mentionUserList[idx].nickname}', '');
              controller.commentController.text =
              '@${controller.mentionUserList[idx].nickname} ';
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
