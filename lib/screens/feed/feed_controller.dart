import 'dart:async';
import 'dart:convert';

import 'package:cached_video_player_plus/cached_video_player_plus.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk_share.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import '../../model/comment_model.dart';
import '../../model/feed_model.dart';
import '../../model/user_model.dart';
import '../../utils/app_routes.dart';
import '../../utils/global_toast_controller.dart';
import 'package:dio/dio.dart' as dio;

import '../../utils/logger.dart';
import '../login/user_store.dart';
import '../lounge/lounge_controller.dart';
import 'feed_service.dart';

// http
import 'package:http/http.dart' as http;


class FeedController extends GetxController {
  static FeedController get to => Get.find();
  

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final dio.Dio _dio = dio.Dio();

  List<List<CachedVideoPlayerPlusController>> videoControllerList = <List<CachedVideoPlayerPlusController>>[].obs;
  late CachedVideoPlayerPlusController videoController;
  late CachedVideoPlayerPlusController detailController;
  late List<CachedVideoPlayerPlusController> videoControllers;
  late CachedVideoPlayerPlusController videoDetailController;
  late PageController pageController;

  late TextEditingController commentController;
  String comment = '';

  Future<void> initializeVideoPlayerFuture = Future.value();

  RxInt currentFeedIndex = 0.obs;
  RxInt currentVideoUrlIndex = 0.obs;
  RxInt sumReplyCount = 0.obs;

  RxInt duration = 0.obs;
  List<RxInt> durationList = <RxInt>[].obs;

  final _feedList = <FeedModel>[].obs;
  List<FeedModel> get feedList => _feedList;

  final _detailFeed = FeedModel().obs;
  FeedModel get detailFeed => _detailFeed.value;
  set detailFeed(FeedModel value) => _detailFeed.value = value;

  final _commentArrayList = <List<CommentModel>>[].obs;
  List<List<CommentModel>> get commentArrayList => _commentArrayList;

  final _commentReplyArrayList =<List<CommentModel>>[].obs;
  List<List<CommentModel>> get commentReplyArrayList => _commentReplyArrayList;

  final _commentArray = <CommentModel>[].obs;
  List<CommentModel> get commentArray => _commentArray;

  final _commentReplyArray = <CommentModel>[].obs;
  List<CommentModel> get commentReplyArray => _commentReplyArray;

  final _thumbnailList = <String>[].obs;
  List<String> get thumbnailList => _thumbnailList;

  final _hashTags = <String>[].obs;
  List<String> get hashTags => _hashTags;

  final _mentionUserList = <UserModel>[].obs;
  List<UserModel> get mentionUserList => _mentionUserList;

  final _allUserList = <UserModel>[].obs;
  List<UserModel> get allUserList => _allUserList;

  final isVideoLoading = true.obs;
  final _isCommentLoading = false.obs;
  final _isMuted = true.obs;

  bool get isLoading => isVideoLoading.value;
  set isLoading(bool value) => isVideoLoading.value = value;

  bool get isCommentLoading => _isCommentLoading.value;
  set isCommentLoading(bool value) => _isCommentLoading.value = value;

  bool get isMuted => _isMuted.value;
  set isMuted(bool value) => _isMuted.value = value;

  final _isFeedMore = false.obs;
  bool get isFeedMore => _isFeedMore.value;
  set isFeedMore(bool value) => _isFeedMore.value = value;

  final _isFeedBookmark = false.obs;
  bool get isFeedBookmark => _isFeedBookmark.value;
  set isFeedBookmark(bool value) => _isFeedBookmark.value = value;

  final _isFeedLike = false.obs;
  bool get isFeedLike => _isFeedLike.value;
  set isFeedLike(bool value) => _isFeedLike.value = value;

  final _isMentionLoading = false.obs;
  bool get isMentionLoading => _isMentionLoading.value;
  set isMentionLoading(bool value) => _isMentionLoading.value = value;

  final _isReply = false.obs;
  bool get isReply => _isReply.value;
  set isReply(bool value) => _isReply.value = value;

  Timer? _debounce;

  @override
  Future<void> onInit() async {
    super.onInit();
    await pageInit();
  }

  @override
  void dispose() {
    super.dispose();
    detailController.dispose();
    videoControllerList[currentFeedIndex.value][currentVideoUrlIndex.value].dispose();
    allPause();
  }

  /// 페이지 초기화
  Future<void> pageInit() async {
    pageController = PageController();
    commentController = TextEditingController();
  }

  /// 피드 목록 가져오기
  Future<void> fetchFeeds() async {

    try {

      _feedList.clear();
      _thumbnailList.clear();

      isVideoLoading.value = true;

      await FeedService.to.getFeedList().then((value) {
        _feedList.addAll(value);
        LoungeController.to.loungeFeedList.addAll(value);
      });

      if (_feedList.isNotEmpty) {
        await getFeedVideoList(videoControllerList);

        // 썸네일
        for (var i = 0; i < _feedList.length; i++) {
          _thumbnailList.add(_feedList[i].thumbnailUrls![0]);
        }

        // 북마크, 좋아요 갯수
        fetchComments(_feedList[currentFeedIndex.value].seq ?? '', currentFeedIndex.value);
        fetchLikes(_feedList[currentFeedIndex.value].seq ?? '');
        fetchBookmarks(_feedList[currentFeedIndex.value].seq ?? '');
        isVideoLoading.value = false;

      } else {
        isVideoLoading.value = false;
      }
    } catch (e) {
      AppLog.to.e('fetchFeeds error: $e');
      isVideoLoading.value = false;
    }

  }

  Future<void> initDetailVideoPlayer() async {
    try {

      detailController = CachedVideoPlayerPlusController.networkUrl(Uri.parse(_detailFeed.value.videoUrls![0]));

      final videoPlayerController = detailController;
      await videoPlayerController.initialize();

      videoPlayerController.addListener(() {
        if (videoPlayerController.value.isInitialized) {
          duration.value = videoPlayerController.value.duration!.inMilliseconds;
        }
      });

      videoPlayerController.setLooping(true);
      videoPlayerController.setVolume(0);
      videoPlayerController.play();

    } catch (e) {
      AppLog.to.e('initVideoPlayer error: $e');
    }
  }

  Future<void> fetchDetailFeed() async {
    try {
      _detailFeed.value = Get.arguments['detailFeed'];
      await initDetailVideoPlayer();

    } catch (e) {
      AppLog.to.e('fetchDetailFeed error: $e');
    }
  }

  /// 메뉴 리스트 스트링으로 변환
  /// menuInfo: 메뉴 리스트
  /// return: 메뉴 리스트 스트링
  String convertMenuList(String menuInfo) {
    try {

      var menuList = '';
      menuInfo
          .replaceAll('[', '')
          .replaceAll(']', '')
          .split(', ')
          .forEach((element) {
        menuList += '$element\n';
        // 마지막 개행 제거
      });
      menuList = menuList.substring(0, menuList.length - 1);

      return menuList;
    } catch (e) {
      AppLog.to.e('convertMenuList error: $e');
      return '';
    }
  }

  /// 네이버 플레이스 컨텍스트 해시태그로 변환
  String convertNaverPlaceContext(String naverPlaceContext) {
    try {

      var hashTag = '';
      // 콤마를 # 으로 변환
      naverPlaceContext
          .replaceAll('[', '')
          .replaceAll(']', '')
          .replaceAll(', ', ' #')
          .split('#')
          .forEach((element) {
        hashTag += '#$element';
      });

      if (hashTag.startsWith('#')) {
        hashTag = hashTag.substring(1);
      }

      return hashTag;
    } catch (e) {
      AppLog.to.e('convertNaverPlaceContext error: $e');
      return '';
    }
  }

  /// 비디오 플레이어 리스트 가져오기
  Future<void> getFeedVideoList(
      List<List<CachedVideoPlayerPlusController>> videoControllerList) async {
    try {
      for (var i = 0; i < _feedList.length; i++) {
        videoControllers = <CachedVideoPlayerPlusController>[];
        for (var j = 0; j < _feedList[i].videoUrls!.length; j++) {
          var videoController = CachedVideoPlayerPlusController.networkUrl(
              Uri.parse(_feedList[i].videoUrls![j]));
          videoControllers.add(videoController);
        }
        videoControllerList.add(videoControllers);
      }

      await initializeVideoPlayer(videoControllerList);
    } catch (e) {
      AppLog.to.e('getFeedVideoList error: $e');
    }
  }

  /// 비디오 플레이어 전체 제거
  Future<void> disposeVideoPlayer() async {
    try {
      for (var videoController in videoControllerList) {
        for (var element in videoController) {
          element.dispose();
        }
      }
    } catch (e) {
      AppLog.to.e('disposeVideoPlayer error: $e');
    }
  }

  /// 비디오 플레이어 초기화
  Future<void> initializeVideoPlayer(List<List<CachedVideoPlayerPlusController>> videoControllerList) async {
    try {

      // videoControllerList[currentFeedIndex.value][currentVideoUrlIndex.value].initialize().then((_) {
      //   initializeVideoPlayerFuture = videoControllerList[currentFeedIndex.value][currentVideoUrlIndex.value].play();
      //   // mute
      //   if (videoControllerList[currentFeedIndex.value].length == 1) {
      //     videoControllerList[currentFeedIndex.value][currentVideoUrlIndex.value].setLooping(true);
      //     videoControllerList[currentFeedIndex.value][currentVideoUrlIndex.value].setVolume(0);
      //   }
      //   //videoControllerList[currentFeedIndex.value][currentVideoUrlIndex.value].addListener(_onVideoPlayerStateChanged);
      //   return videoControllerList[currentFeedIndex.value][currentVideoUrlIndex.value];
      // });

      videoControllerList[currentFeedIndex.value][currentVideoUrlIndex.value].initialize().then((_) {
        videoControllerList[currentFeedIndex.value][currentVideoUrlIndex.value].play();
        videoControllerList[currentFeedIndex.value][currentVideoUrlIndex.value].setLooping(true);
        videoControllerList[currentFeedIndex.value][currentVideoUrlIndex.value].setVolume(0);
        videoControllerList[currentFeedIndex.value][currentVideoUrlIndex.value].addListener(_onVideoPlayerStateChanged);
      });

    } catch (e) {
      AppLog.to.e('_initializeVideoPlayer error: $e');
    }
  }

  /// 비디오 플레이어 상태 변경
  _onVideoPlayerStateChanged() {
    try {
      if (videoControllerList[currentFeedIndex.value][currentVideoUrlIndex.value].value.isCompleted) {
        AppLog.to.d('isCompleted');

        if (currentVideoUrlIndex.value < videoControllerList[currentFeedIndex.value].length - 1) {
          currentVideoUrlIndex.value++;
          initializeVideoPlayer(videoControllerList);
        } else {
          currentVideoUrlIndex.value = 0;
          initializeVideoPlayer(videoControllerList);
        }
        AppLog.to.d('currentVideoUrlIndex: ${currentVideoUrlIndex.value}');
      }
    } catch (e) {
      AppLog.to.e('_onVideoPlayerStateChanged error: $e');
    }
  }

  /// 썸네일 다운로드
  thumbnailDownload(String videoUrl) async {
    try {
      final thumbnail = await VideoThumbnail.thumbnailFile(
        video: videoUrl,
        imageFormat: ImageFormat.WEBP,
        maxWidth: 128,
        quality: 25,
      );
      return thumbnail;
    } catch (e) {
      AppLog.to.e('thumbnailDownload error: $e');
    }
  }

  /// 음소거 상태 변경
  // unmute
  Future<void> mute() async {
    try {
      videoControllerList[currentFeedIndex.value][currentVideoUrlIndex.value].setVolume(0);
      isMuted = true;
    } catch (e) {
      AppLog.to.e('mute error: $e');
    }
  }

  Future<void> unMute() async {
    try {
      videoControllerList[currentFeedIndex.value][currentVideoUrlIndex.value].setVolume(1);
      isMuted = false;
    } catch (e) {
      AppLog.to.e('unmute error: $e');
    }
  }

  // 최근 영상 재생
  Future<void> recentPlay() async {
    try {
      videoControllerList[currentFeedIndex.value][currentVideoUrlIndex.value].play();
    } catch (e) {
      AppLog.to.e('recentPlay error: $e');
    }
  }

  /// 현재 영상 정지
  /// feedIndex: 현재 피드 인덱스
  /// videoIndex: 현재 비디오 인덱스
  /// isAllPause: 모든 영상 정지 여부
  /// isAllPause가 true인 경우 모든 영상 정지
  /// isAllPause가 false인 경우 현재 영상만 정지

  Future<void> currentPause(int feedIndex, int videoIndex, bool isAllPause) async {
    try {
      if (isAllPause) {
        for (var videoController in videoControllerList) {
          for (var element in videoController) {
            element.pause();
          }
        }
      } else {
        videoControllerList[feedIndex][videoIndex].pause();
      }
    } catch (e) {
      AppLog.to.e('currentPause error: $e');
    }
  }

  /// 모든 영상 정지
  Future<void> allPause() async {
    try {
      for (var videoController in videoControllerList) {
        for (var element in videoController) {
          element.pause();
        }
      }
    } catch (e) {
      AppLog.to.e('allPause error: $e');
    }
  }

  /// 모든 영상 재생
  Future<void> allMute() async {
    try {
      for (var videoController in videoControllerList) {
        for (var element in videoController) {
          element.setVolume(0);
        }
      }
      isMuted = true;
    } catch (e) {
      AppLog.to.e('allMute error: $e');
    }
  }

  /// Feed 상세 화면 이동
  showFeedDetail(int index) {
    Get.toNamed(AppRoutes.feedDetail, arguments: {
      'detailFeed': _feedList[index],
    });
  }

  /// [FirebaseFirestore] Feed 좋아요
  ///
  /// feedId: 피드 ID
  /// commentId: 댓글 내용
  Future<void> addComment(String feedId, String comment) async {

    try {

      // 로딩바 보여주기
      _isCommentLoading.value = true;

      await _firestore
          .collection('feeds')
          .where('seq', isEqualTo: feedId)
          .get()
          .then((value) async {
        for (var i = 0; i < value.docs.length; i++) {

          // commmentId 생성
          var commentId = value.docs[i].reference.collection('comments').doc().id;

          value.docs[i].reference.collection('comments').add({
            'comment': comment,
            'createdAt': Timestamp.now(),
            'uid': '',
            'userId': UserStore.to.user.value.id,
            'userName': UserStore.to.user.value.displayName,
            'userNickname': UserStore.to.user.value.nickname,
            'userPhotoUrl': UserStore.to.user.value.profileImage,
            'feedId': feedId,
            'commentId': commentId,
            'likeCount': 0,
            'likeUserIds': [],
            'isReply': _isReply.value,
            'replyCommentId': '',
            'replyCommentList': [],
          });
        }
      });

      _isCommentLoading.value = false;

      await refreshComments(feedId, currentFeedIndex.value);

      // fcm 발송
      await sendFcm(feedId, comment, '댓글');

    } catch (e) {
      AppLog.to.e('addComment error: $e');
    }
  }

  /// 대댓글
  Future<void> addReplyComment(int index, String comment, String feedId) async {

    try {

      // await _firestore
      //     .collection('feeds')
      //     .where('seq', isEqualTo: feedId)
      //     .snapshots()
      //     .listen((value) {
      //   for (var i = 0; i < value.docs.length; i++) {
      //       value.docs[i].reference.collection('comments').where('commentId', isEqualTo: commentArrayList[currentFeedIndex.value][index].commentId).get().then((value) {
      //         for (var j = 0; j < value.docs.length; j++) {
      //           Map<String, dynamic> replyComment = {
      //             'comment': comment,
      //             'createdAt': Timestamp.now(),
      //             'uid': '',
      //             'userId': UserStore.to.user.value.id,
      //             'userName': UserStore.to.user.value.displayName,
      //             'userNickname': UserStore.to.user.value.nickname,
      //             'userPhotoUrl': UserStore.to.user.value.profileImage,
      //             'feedId': feedId,
      //             'commentId': commentArrayList[currentFeedIndex.value][index].commentId,
      //             'likeCount': 0,
      //             'likeUserIds': [],
      //             'isReply': true,
      //             'replyCommentId': value.docs[j].data()['commentId'],
      //             'replyCommentList': [],
      //           };
      //           // update
      //           value.docs[j].reference.update({
      //             'replyCommentList': FieldValue.arrayUnion([replyComment]),
      //           });
      //         }
      //       });
      //     }
      // });

      // 댓글 추가
      await _firestore
          .collection('feeds')
          .where('seq', isEqualTo: feedId)
          .get()
          .then((value) {
        for (var i = 0; i < value.docs.length; i++) {
          AppLog.to.d('value.docs.length: ${value.docs.length}');
          value.docs[i].reference.collection('comments').where('commentId', isEqualTo: commentArray[index].commentId).get().then((value) {
            for (var j = 0; j < value.docs.length; j++) {
              Map<String, dynamic> replyComment = {
                'comment': comment,
                'createdAt': Timestamp.now(),
                'uid': '',
                'userId': UserStore.to.user.value.id,
                'userName': UserStore.to.user.value.displayName,
                'userNickname': UserStore.to.user.value.nickname,
                'userPhotoUrl': UserStore.to.user.value.profileImage,
                'feedId': feedId,
                'commentId': commentArray[index].commentId,
                'likeCount': 0,
                'likeUserIds': [],
                'isReply': true,
                'replyCommentId': value.docs[j].data()['commentId'],
                'replyCommentList': [],
              };
              // update
              value.docs[j].reference.update({
                'replyCommentList': FieldValue.arrayUnion([replyComment]),
              });
            }
          });
        }
      });

      // 코멘트 초기화
      commentController.clear();

    } catch (e) {
      AppLog.to.e('addReplyComment error: $e');
    }
  }

  /// 댓글 새로고침
  Future<void> refreshComments(String feedId, int feedIndex) async {

    try {
      _isCommentLoading.value = true;

      _commentArrayList.clear();
      _commentReplyArrayList.clear();

      //await fetchComments(feedId, feedIndex);
      //sumReplyCount.value = 0;

      _isCommentLoading.value = false;
      commentController.clear();

    } catch (e) {
      AppLog.to.e('fetchComments error: $e');
    }

  }

  /// [FirebaseFirestore] Feed 댓글 조회
  Future<void> fetchComments(String feedId, int feedIndex) async {

    try {

      //AppLog.to.d('feedId: $feedId');

      sumReplyCount.value = 0;

      // 실시간 댓글
      _firestore
          .collection('feeds')
          .where('seq', isEqualTo: feedId)
          .get()
          .then((value) {
        for (var i = 0; i < value.docs.length; i++) {
          //AppLog.to.d('value.docs.length: ${value.docs.length}');

          value.docs[i].reference.collection('comments').orderBy('createdAt', descending: true).snapshots().listen((event) {
            _commentArray.clear();
            _commentReplyArray.clear();
            event.docs.forEach((element) {
              if (element.data()['replyCommentList'].isNotEmpty) {
                _commentArray.add(CommentModel.fromJson(element.data()));
                var comment = CommentModel.fromJson(element.data());
                //AppLog.to.d('comment: $comment');
                sumReplyCount.value += comment.replyCommentList!.length;
              } else {
                _commentArray.add(CommentModel.fromJson(element.data()));
              }
            });
            sumReplyCount.value += event.docs.length;
          });
        }
      });
    } catch (e) {
      AppLog.to.e('fetchComments error: $e');
    }
  }

  /// 댓글 삭제
  Future<void> deleteComment(
      String feedId, String commentId, int feedIndex) async {
    try {

      AppLog.to.d('feedId: $feedId');
      AppLog.to.d('commentId: $commentId');
      AppLog.to.d('feedIndex: $feedIndex');

      QuerySnapshot<Map<String, dynamic>> feedSnapshot = await _firestore
          .collection('feeds')
          .where('seq', isEqualTo: feedId)
          .get();

      AppLog.to.d('feedSnapshot.docs.length: ${feedSnapshot.docs.length}');

      for (var i = 0; i < feedSnapshot.docs.length; i++) {
        feedSnapshot.docs[i].reference.collection('comments').where('commentId', isEqualTo: commentId).get().then((value) {
          for (var j = 0; j < value.docs.length; j++) {
            value.docs[j].reference.delete();
          }
        });
      }

      await refreshComments(feedId, feedIndex);
      Get.back();

    } catch (e) {
      AppLog.to.e('deleteComment error: $e');
    }
  }

  /// 댓글 좋아요
  Future<void> addCommentLike(String feedId, String commentId, int feedIndex) async {

    try {

      QuerySnapshot<Map<String, dynamic>> feedSnapshot = await _firestore
          .collection('feeds')
          .where('seq', isEqualTo: feedId)
          .get();

      for (var i = 0; i < feedSnapshot.docs.length; i++) {
        feedSnapshot.docs[i].reference.collection('comments').where('commentId', isEqualTo: commentId).get().then((value) {
          for (var j = 0; j < value.docs.length; j++) {

            // 이미 좋아요를 누른 경우
            if (value.docs[j].data()['likeUserIds'].contains(UserStore.to.user.value.id)) {
              GlobalToastController.to.showToast('이미 좋아요를 누르셨습니다.');
              return;
            }

            // 자신이 올린 게시물 제외
            if (UserStore.to.user.value.id == value.docs[j].data()['userId']) {
              GlobalToastController.to.showToast('자신이 작성한 게시물은 좋아요를 누를 수 없습니다.');
              return;
            }

            value.docs[j].reference.update({
              'likeCount': FieldValue.increment(1),
              'likeUserIds': FieldValue.arrayUnion([UserStore.to.user.value.id]),
            });
          }
        });
      }

      await refreshComments(feedId, feedIndex);

    } catch (e) {
      AppLog.to.e('likeComment error: $e');
    }
  }

  /// 댓글 좋아요 취소
  /// feedId: 피드 ID
  /// commentId: 댓글 ID
  /// feedIndex: 피드 인덱스
  Future<void> cancelCommentLike(
      String feedId, String commentId, int feedIndex) async {
    try {
      await _firestore
          .collection('feeds')
          .doc(feedId)
          .collection('comments')
          .where('commentId', isEqualTo: commentId)
          .get()
          .then((value) async {
        for (var i = 0; i < value.docs.length; i++) {
          value.docs[i].reference.update({
            'likeCount': FieldValue.increment(-1),
            'likeUserIds': FieldValue.arrayRemove([UserStore.to.user.value.id]),
          });
        }
        await refreshComments(feedId, feedIndex);
      });
    } catch (e) {
      AppLog.to.e('cancelCommentLike error: $e');
    }
  }

  /// 댓글 수정
  Future<void> updateComment(
      String feedId, String commentId, String comment, int feedIndex) async {
    try {
      await _firestore
          .collection('feeds')
          .doc(feedId)
          .collection('comments')
          .where('commentId', isEqualTo: commentId)
          .get()
          .then((value) async {
        for (var i = 0; i < value.docs.length; i++) {
          value.docs[i].reference.update({
            'comment': comment,
          });
        }
        await refreshComments(feedId, feedIndex);
      });
    } catch (e) {
      AppLog.to.e('updateComment error: $e');
    }
  }

  /// 피드 북마크 조회
  /// feedId: 피드 ID
  /// return: 북마크 여부
  /// 북마크 여부를 확인하여 북마크 여부를 반환
  Future<void> fetchBookmarks(String feedId) async {
    try {
      await _firestore
          .collection('users')
          .doc(UserStore.to.user.value.id)
          .collection('bookmarks')
          .where('feedId', isEqualTo: feedId)
          .get()
          .then((value) {
        if (value.docs.isNotEmpty) {
          FeedController.to.feedList[currentFeedIndex.value].isBookmark = true;
          isFeedBookmark = true;
        } else {
          FeedController.to.feedList[currentFeedIndex.value].isBookmark = false;
          isFeedBookmark = false;
        }
        // AppLog.to.d('isFeedBookmark: $isFeedBookmark');
      });
    } catch (e) {
      AppLog.to.e('fetchBookmarks error: $e');
    }
  }

  /// 피드 북마크 추가
  Future<void> addBookmark(String feedId) async {
    try {
      // 피드 북마크 수 추가
      var feed = _feedList.firstWhere((element) => element.seq == feedId);
      var target = _feedList.indexWhere((element) => element.seq == feedId);

      // 자신이 올린 게시물 제외
      if (UserStore.to.user.value.id == feed.userid) {
        GlobalToastController.to.showToast('자신이 작성한 게시물은 북마크를 누를 수 없습니다.');
        return;
      }

      // 유저 북마크 추가
      await _firestore
          .collection('users')
          .doc(UserStore.to.user.value.id)
          .collection('bookmarks')
          .doc(feedId)
          .set({
        'feedId': feedId,
        'createdAt': Timestamp.now(),
      });

      await _firestore
          .collection('feeds').get().then((value) {
        for (var i = 0; i < value.docs.length; i++) {
          if (feed.seq == value.docs[i].data()['seq']) {
            value.docs[i].reference.update({
              'bookmarkCount': FieldValue.increment(1),
            });
            _feedList[target].bookmarkCount =
                value.docs[i].data()['bookmarkCount'] + 1;
            AppLog.to.d('add bookmarkCount: ${_feedList[target].bookmarkCount}');
          }
        }
      });

      // fcm 발송
      await sendFcm(feedId, comment, '북마크');

      fetchBookmarks(feedId);
      GlobalToastController.to.showToast('북마크에 추가되었습니다.');
    } catch (e) {
      AppLog.to.e('addBookmark error: $e');
    }
  }

  /// 피드 북마크 삭제
  Future<void> removeBookmark(String feedId) async {
    try {
      await _firestore
          .collection('users')
          .doc(UserStore.to.user.value.id)
          .collection('bookmarks')
          .where('feedId', isEqualTo: feedId)
          .get()
          .then((value) {
        for (var i = 0; i < value.docs.length; i++) {
          value.docs[i].reference.delete();
        }
      });

      var feed = _feedList.firstWhere((element) => element.seq == feedId);
      var target = _feedList.indexWhere((element) => element.seq == feedId);

      await _firestore.collection('feeds').get().then((value) {
        for (var i = 0; i < value.docs.length; i++) {
          if (feed.seq == value.docs[i].data()['seq']) {
            value.docs[i].reference.update({
              'bookmarkCount': FieldValue.increment(-1),
            });
            _feedList[target].bookmarkCount =
                value.docs[i].data()['bookmarkCount'] - 1;
            AppLog.to
                .d('remove bookmarkCount: ${_feedList[target].bookmarkCount}');
          }
        }
      });

      fetchBookmarks(feedId);
      GlobalToastController.to.showToast('북마크에서 삭제되었습니다.');
    } catch (e) {
      AppLog.to.e('deleteBookmark error: $e');
    }
  }

  /// 피드 좋아요 조회
  /// feedId: 피드 ID
  /// return: 좋아요 여부
  /// 좋아요 여부를 확인하여 좋아요 여부를 반환
  Future<void> fetchLikes(String feedId) async {
    try {
      await _firestore
          .collection('users')
          .doc(UserStore.to.user.value.id)
          .collection('likes')
          .where('feedId', isEqualTo: feedId)
          .get()
          .then((value) {
        if (value.docs.isNotEmpty) {
          FeedController.to.feedList[currentFeedIndex.value].isLike = true;
          isFeedLike = true;
        } else {
          FeedController.to.feedList[currentFeedIndex.value].isLike = false;
          isFeedLike = false;
        }
        // AppLog.to.d('isLike: ${FeedController.to.feedList[currentFeedIndex.value].isLike}');
      });
    } catch (e) {
      AppLog.to.e('fetchLikes error: $e');
    }
  }

  /// 피드 좋아요 추가
  Future<void> addLike(String feedId) async {
    try {

      var feed = _feedList.firstWhere((element) => element.seq == feedId);
      var target = _feedList.indexWhere((element) => element.seq == feedId);

      // 자신이 올린 게시물 제외
      if (UserStore.to.user.value.id == feed.userid) {
        GlobalToastController.to.showToast('자신이 작성한 게시물은 좋아요를 누를 수 없습니다.');
        return;
      }

      await _firestore
          .collection('users')
          .doc(UserStore.to.user.value.id)
          .collection('likes')
          .doc(feedId)
          .set({
        'feedId': feedId,
        'createdAt': Timestamp.now(),
      });

      // 피드 좋아요 수 추가
      await _firestore.collection('feeds').get().then((value) {
        for (var i = 0; i < value.docs.length; i++) {
          if (feed.seq == value.docs[i].data()['seq']) {
            value.docs[i].reference.update({
              'likeCount': FieldValue.increment(1),
            });
            _feedList[target].likeCount = value.docs[i].data()['likeCount'] + 1;
            AppLog.to.d('add likeCount: ${_feedList[target].likeCount}');
          }
        }
      });

      // fcm 발송
      await sendFcm(feedId, comment, '좋아요');

      fetchLikes(feedId);
      GlobalToastController.to.showToast('좋아요를 눌렀습니다.');
    } catch (e) {
      AppLog.to.e('addLike error: $e');
    }
  }

  /// 피드 좋아요 삭제
  Future<void> removeLike(String feedId) async {
    try {
      await _firestore
          .collection('users')
          .doc(UserStore.to.user.value.id)
          .collection('likes')
          .where('feedId', isEqualTo: feedId)
          .get()
          .then((value) {
        for (var i = 0; i < value.docs.length; i++) {
          value.docs[i].reference.delete();
        }
      });

      var feed = _feedList.firstWhere((element) => element.seq == feedId);
      var target = _feedList.indexWhere((element) => element.seq == feedId);

      // 피드 좋아요 수 추가
      await _firestore.collection('feeds').get().then((value) {
        for (var i = 0; i < value.docs.length; i++) {
          if (feed.seq == value.docs[i].data()['seq']) {
            value.docs[i].reference.update({
              'likeCount': FieldValue.increment(-1),
            });
            _feedList[target].likeCount = value.docs[i].data()['likeCount'] - 1;
            AppLog.to.d('remove likeCount: ${_feedList[target].likeCount}');
          }
        }
      });

      fetchLikes(feedId);
      GlobalToastController.to.showToast('좋아요를 취소했습니다.');
    } catch (e) {
      AppLog.to.e('removeLike error: $e');
    }
  }

  /// 피드 공유
  Future<void> shareFeed(
    String feedId,
  ) async {
    try {

      // var feed = _feedList.firstWhere((element) => element.seq == feedId);
      // var shareText = '포잇에서 공유한 글입니다.\n\n';
      // shareText += '제목: ${feed.storeName}\n';
      // shareText += '위치: ${feed.storeAddress}\n';
      //
      // // 클립보드 복사
      // await Clipboard.setData(ClipboardData(text: shareText));
      // GlobalToastController.to.showToast('클립보드에 복사되었습니다.');

      // 1. 공유 종류 선택

      // 카카오톡 공유
      bool isKakaoTalkSharingAvailable = await ShareClient.instance.isKakaoTalkSharingAvailable();

      final LocationTemplate locationTemplate = LocationTemplate(
        address: _feedList[currentFeedIndex.value].storeAddress ?? '',
        addressTitle: '포잇',
        content: Content(
          title: '포잇에서 공유한 글이에요',
          description: _feedList[currentFeedIndex.value].storeName ?? '',
          link: Link(
            //mobileWebUrl: 'https://play.google.com/store/apps/details?id=com.poit.poit',
            //webUrl: 'https://play.google.com/store/apps/details?id=com.poit.poit',
          ),
        ),
        social: Social(
          likeCount: _feedList[currentFeedIndex.value].likeCount ?? 0,
          // commentCount: _feedList[currentFeedIndex.value].bookmarkCount ?? 0,
          // sharedCount: _feedList[currentFeedIndex.value].bookmarkCount ?? 0,
        ),
        buttons: [
          Button(
            title: '앱으로 이동',
            link: Link(
              //mobileWebUrl: 'https://play.google.com/store/apps/details?id=com.poit.poit',
              //webUrl: 'https://play.google.com/store/apps/details?id=com.poit.poit',
            ),
          ),
        ],
      );


      if (isKakaoTalkSharingAvailable) {
        AppLog.to.i('카카오톡으로 공유 가능');
        try {
          Uri uri =
          await ShareClient.instance.shareDefault(template: locationTemplate);
          await ShareClient.instance.launchKakaoTalk(uri);
          AppLog.to.i('카카오톡 공유 완료');
        } catch (error) {
          AppLog.to.w('카카오톡 공유 실패 $error');
        }
      } else {
        AppLog.to.e('카카오톡 미설치: 웹 공유 기능 사용 권장');
        GlobalToastController.to.showToast('카카오톡이 설치되어 있지 않아 웹으로 공유합니다.');
      }


    } catch (e) {
      AppLog.to.e('shareFeed error: $e');
    }
  }

  /// 푸시메세지 발송
  Future<void> sendFcm(String feedId, String comment, String type) async {
    try {
      var feed = _feedList.firstWhere((element) => element.seq == feedId);

      var userLoginType = UserStore.to.user.value.loginType;
      AppLog.to.i('userLoginType: $userLoginType');

      await _firestore
          .collection('users')
          .where('id', isEqualTo: feed.userid)
          .get()
          .then((value) async {

        var fcmToken = value.docs.first.data()['fcmToken'];
        var nickname = UserStore.to.user.value.nickname;

        AppLog.to.i('fcmToken: $fcmToken , nickname: $nickname');

        // datetime to timestamp
        var timestamp = Timestamp.fromDate(DateTime.now());

        // add notification
        await _firestore.collection('notifications').add({
          'title': '포잇',
          'body': type == '댓글' || type  =='대댓글' ? '$nickname님이 회원님의 게시글에 $type을 남겼어요 ${comment}' : '$nickname님이 회원님의 게시글에 $type를 눌렀어요',
          'createdAt': timestamp,
          'uid': UserStore.to.user.value.uid,
          'userId': UserStore.to.user.value.id,
          'userName': UserStore.to.user.value.displayName,
          'userNickname': UserStore.to.user.value.nickname,
          'userPhotoUrl': UserStore.to.user.value.profileImage,
          // 수신자
          'receiverId': feed.userid,
          // 발신자
          'senderId': UserStore.to.user.value.id,
          'feedId': feedId,
          'comment': comment,
          'type': type,
          'isRead': false,
        });

        if(type == '댓글'){
          sendPushMessage(fcmToken, '포잇', '${UserStore.to.user.value.nickname}님이 회원님의 게시글에 $type을 남겼어요 $comment');
        } else {
          sendPushMessage(fcmToken, '포잇', '${UserStore.to.user.value.nickname}님이 회원님의 게시글에 $type를 눌렀어요');
        }

      });

      // 새로고침
      await refreshComments(feedId, currentFeedIndex.value);

    } catch (e) {
      AppLog.to.e('sendFcm error: $e');
    }
  }


  /// 푸시메세지 발송
  /// fcmToken: FCM 토큰
  /// title: 제목
  /// comment: 내용
  Future<void> sendPushMessage(String fcmToken, String title, String comment) async {
    try {

      NotificationSettings settings = await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        provisional: false,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        AppLog.to.i('User granted permission');
      } else {
        AppLog.to.i('User declined or has not accepted permission');
      }

      AppLog.to.i('fcmToken: $fcmToken');

      // get assets
      final accountCredentials = ServiceAccountCredentials.fromJson(
        jsonDecode(await rootBundle.loadString('assets/debrix-app-fc46f-fdcffe4749b7.json')),
      );

      const scope = 'https://www.googleapis.com/auth/firebase.messaging';
      final client = await obtainAccessCredentialsViaServiceAccount(
        accountCredentials,
        [scope],
        http.Client(),
      );

      final accessToken = client.accessToken.data;
      AppLog.to.i('accessToken: $accessToken');

      final message = {
        // 토큰 값 사용
        'message' : {
          'token': fcmToken,
          'notification': {
            'title': title,
            'body': comment,
          },
          'data': {
            'click_action': 'FLUTTER_NOTIFICATION_CLICK',
            'sound': 'default',
            'status': 'done',
          },
        },

      };

      // fLDzYBDWRBuSdMssaPpWxp:APA91bHJB-9EqiPm02vio0BaDRBwF94B7fvpqIzsFiDj1RU9bYBAD0Xgv3F26YMGd4BSBgSSDifOsbSkdA3t_Zhof1sSWIV1UetuWoeeF-j0YGpHq6yo9Pwu5t8VnJbRBA8QGcD0zI-x

      final response = await http.post(
        Uri.parse('https://fcm.googleapis.com/v1/projects/debrix-app-fc46f/messages:send'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode(message),
      );

      if (response.statusCode == 200) {
        AppLog.to.i('Message sent successfully');

      } else {
        AppLog.to.e('Error sending message: ${response.statusCode}');
        AppLog.to.e('Response body: ${response.body}');
      }

    } catch (e) {
      AppLog.to.e('sendPushMessage error: $e');
    }
  }

  /// 멘션 유저 조회
  Future<void> fetchMentionUser(String keyword) async {
    try {

      if(_debounce?.isActive ?? false) _debounce?.cancel();
      _debounce = Timer(const Duration(milliseconds: 300), () async {
        _isMentionLoading.value = true;

        // 멘션 유저 조회
        await _firestore
            .collection('users')
            .get()
            .then((value) {

          _mentionUserList.clear();
          _allUserList.clear();

          for (var i = 0; i < value.docs.length; i++) {
            var user = UserModel.fromJson(value.docs[i].data());
            //AppLog.to.d('nickname: ${user.nickname}');
            _allUserList.add(user);
          }

          if (keyword.length > 1) {
            for (var i = 0; i < _allUserList.length; i++) {
              if (_allUserList[i].nickname!.contains(keyword.substring(1))) {
                //AppLog.to.d('nickname: ${_allUserList[i].nickname}');
                _mentionUserList.add(_allUserList[i]);
              }
              _isMentionLoading.value = false;
            }
          }

        });
      });

    } catch (e) {
      AppLog.to.e('fetchMentionUser error: $e');
    }
  }



}
