import 'package:cached_network_image/cached_network_image.dart';
import 'package:cached_video_player_plus/cached_video_player_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:foreats/screens/feed/feed_controller.dart';
import 'package:foreats/screens/feed/feed_detail_controller.dart';
import 'package:foreats/utils/logger.dart';
import 'package:get/get.dart';

import '../../home/home_controller.dart';
import '../../model/feed_model.dart';
import '../../utils/colors.dart';
import '../../widget/description_text.dart';
import '../../widget/login_bottom_sheet.dart';
import '../login/user_store.dart';

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
          InkWell(
            onTap: () {
              AppLog.to.d('FeedController.to.isFeedMore: ${FeedController.to.isFeedMore}');
              FeedController.to.isFeedMore = !FeedController.to.isFeedMore;
            },
            child: Container(
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
                    _feedDetailComments(context),
                  ],
                )),
          )
        ],
      ),
    );
  }

// 게시물 상세 제목
  _feedDetailRegisterUserInfo(BuildContext context) {
    return Obx(() =>
      SizedBox(
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
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            feedDetail.usernickname ?? '',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w700,
                              height: 0,
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            '@${feedDetail.userid ?? ''}',
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
                    FeedController.to.isFeedBookmark
                        ? FeedController.to.removeBookmark(feedDetail.seq ?? '')
                        : FeedController.to.addBookmark(feedDetail.seq ?? '');
                  },
                  child: Container(
                    padding: EdgeInsets.only(top: 4.h),
                    child: Icon(
                      FeedController.to.isFeedBookmark
                          ? Icons.bookmark
                          : Icons.bookmark_border,
                      color: FeedController.to.isFeedBookmark
                          ? Theme.of(context).colorScheme.tertiary.withOpacity(0.8)
                          : Colors.white,
                      size: 20.w,
                    ),
                  ),
                ),
                SizedBox(width: 10.w),
                InkWell(
                  onTap: () {
                    // 좋아요
                    FeedController.to.isFeedLike
                        ? FeedController.to.removeLike(feedDetail.seq ?? '')
                        : FeedController.to.addLike(feedDetail.seq ?? '');
                  },
                  child: Container(
                    padding: EdgeInsets.only(top: 4.h),
                    child: Icon(
                      FeedController.to.isFeedLike
                          ? Icons.favorite
                          : Icons.favorite_border,
                      color: FeedController.to.isFeedLike
                          ? Colors.red
                          : Colors.white,
                      size: 20.w,
                    ),
                  ),
                ),
                SizedBox(width: 10.w),
                InkWell(
                  onTap: () {
                    // 공유
                    FeedController.to.shareFeed(feedDetail.seq ?? '');
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
    return Obx(() =>
      Container(
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
                FeedController.to.isFeedMore
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
                        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                        child: SingleChildScrollView(
                          child: Text(
                            FeedController.to.convertMenuList(feedDetail.storeMenuInfo ?? ''),
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: Colors.white,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 10.h),
                      FeedController.to.convertNaverPlaceContext(feedDetail.storeContext ?? '') != ''
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
                            FeedController.to.convertNaverPlaceContext(feedDetail.storeContext ?? ''),
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

  // 댓글
  _feedDetailComments(BuildContext context) {
    return Obx(() =>
        Container(
          width: 1.sw,
          margin: EdgeInsets.only(top: 10.h, left: 4.w),
          child: InkWell(
            onTap: () async {
              // 댓글 시트
              FeedController.to.commentController.clear();
              Get.bottomSheet(
                _commentSheet(context, 0),
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
                    FeedController.to.commentArrayList.isEmpty
                        ? '댓글 0개'
                        : '댓글 ${FeedController.to.commentArrayList[0].length}개',
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

  _commentSheet(BuildContext context, int feedIndex) {
    return Obx(() => FeedController.to.isCommentLoading
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
    Obx(() => SingleChildScrollView(
      child: Container(
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
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // 댓글 탑 메뉴
            // Container(
            //   width: 60.w,
            //   height: 2.h,
            //   decoration: BoxDecoration(
            //     color: Colors.grey[300],
            //     borderRadius: BorderRadius.circular(2.r),
            //   ),
            // ),
            // 댓글 리스트
            FeedController.to.commentArrayList[feedIndex].isEmpty
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
                :
            // 댓글 리스트
            Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: Get.width,
                  height: FeedController.to.commentArrayList[feedIndex].length < 10
                      ? 0.25.sh
                      : 0.8.sh,
                  child: Obx(() => RefreshIndicator(
                    onRefresh: () async {
                      // await controller.fetchComments(
                      //     controller.feedList[feedIndex].feedId ?? '',
                      //     feedIndex);
                    },
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: FeedController.to.commentArrayList[feedIndex].length,
                      itemBuilder: (context, commentIndex) {
                        return
                          SizedBox(
                            width: Get.width,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // 댓글 작성자 정보
                                    Row(
                                      children: [
                                        // 댓글 작성자 프로필
                                        CachedNetworkImage(
                                          imageUrl: FeedController.to.commentArrayList[feedIndex].isEmpty
                                              ? ''
                                              : FeedController.to.commentArrayList[feedIndex][commentIndex].userPhotoUrl ?? '',
                                          imageBuilder:
                                              (context, imageProvider) =>
                                              Container(
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
                                          errorWidget: (context, url, error) =>
                                              Container(
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
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            SizedBox(height: 4.h),
                                            Text(
                                              FeedController.to.commentArrayList[feedIndex].isEmpty
                                                  ? ''
                                                  : FeedController.to.commentArrayList[feedIndex][commentIndex].userId ?? '',
                                              style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 10.sp,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                            SizedBox(height: 4.h),
                                            Text(
                                              FeedController.to.commentArrayList[feedIndex].isEmpty
                                                  ? ''
                                                  : HomeController.to.timeAgo(
                                                // string을 date로 변환
                                                  DateTime.parse(
                                                    FeedController.to.commentArrayList[feedIndex][commentIndex]
                                                        .createdAt
                                                        .toString(),
                                                  )),
                                              style: TextStyle(
                                                color: gray600,
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
                                // 댓글 내용
                                Row(
                                  children: [
                                    Container(
                                      margin: EdgeInsets.only(left: 30.w),
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 10.w, vertical: 4.h),
                                      child: Text(
                                        FeedController.to.commentArrayList[feedIndex].isEmpty
                                            ? ''
                                            : FeedController.to.commentArrayList[feedIndex][commentIndex].comment ?? '',
                                        style: TextStyle(
                                          color: gray800,
                                          fontSize: 10.sp,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    // 댓글 삭제
                                    Spacer(),
                                    InkWell(
                                      onTap: () {
                                        Get.bottomSheet(
                                          Container(
                                            width: 1.sw,
                                            height: Get.height * 0.18,
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
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 10.w, vertical: 10.h),
                                        child: Row(
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
                                                color: Theme.of(context).colorScheme.secondary,
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
                                SizedBox(height: 10.h),
                              ],
                            ),
                          );
                      },
                    ),
                  ),
                  ),
                ),
              ],
            ),
            // 댓글작성 창
            Container(
              width: 1.sw,
              height: 40.h,
              padding: EdgeInsets.symmetric(horizontal: 10.w),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: FeedController.to.commentController,
                      onTap: () {
                        UserStore.to.isLoggedIn
                            ? FeedController.to.commentController.text = ''
                            : Get.bottomSheet(
                          const LoginBottomSheet(),
                        );
                      },
                      onChanged: (value) {
                        if(UserStore.to.isLoggedIn) {
                          FeedController.to.comment = FeedController.to.commentController.text;

                          // 멘션 기능 추가
                          if (FeedController.to.commentController.text.contains('@')) {
                            // 사용자 검색
                            FeedController.to.fetchMentionUser(FeedController.to.commentController.text);
                          }

                        } else {
                          FeedController.to.commentController.text = '';
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
                      if(UserStore.to.isLoggedIn) {
                        // 댓글 등록
                        // FeedController.to.addComment(
                        //     FeedController.to.feedList[feedIndex].seq ?? '',
                        //     FeedController.to.comment);

                        AppLog.to.d('FeedController.to.comment: ${FeedController.to.comment}');
                        AppLog.to.d('FeedController.to.comment: ${FeedController.to.feedList[feedIndex].seq}');
                      }
                    },
                    child: Container(
                      padding: EdgeInsets.all(10.w),
                      child: SvgPicture.asset(
                        'assets/images/ic_send.svg',
                        colorFilter:
                        ColorFilter.mode(gray400, BlendMode.srcIn),
                        width: 20.w,
                        height: 20.h,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
    ),
    );
  }

    @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }
}
