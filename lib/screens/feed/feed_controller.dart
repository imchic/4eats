import 'dart:async';

import 'package:cached_video_player_plus/cached_video_player_plus.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import '../../model/comment_model.dart';
import '../../model/feed_model.dart';
import '../../utils/app_routes.dart';
import '../../utils/global_toast_controller.dart';
import '../login/user_store.dart';
import '../lounge/lounge_controller.dart';
import 'feed_service.dart';

class FeedController extends GetxController {
  static FeedController get to => Get.find();
  final Logger _logger = Logger(
    filter: null, // Use the default LogFilter (-> only log in debug mode)
    printer: PrettyPrinter(
      lineLength: 120,
      colors: true,
      printEmojis: true,
      printTime: false, // Should each log print contain a timestamp
    ),
  );

  List<List<CachedVideoPlayerPlusController>> videoControllerList = <List<CachedVideoPlayerPlusController>>[].obs;
  late CachedVideoPlayerPlusController videoController;
  late List<CachedVideoPlayerPlusController> videoControllers;
  late PageController pageController;

  late TextEditingController commentController;
  String comment = '';

  Future<void> initializeVideoPlayerFuture = Future.value();

  RxInt currentFeedIndex = 0.obs;
  RxInt currentVideoUrlIndex = 0.obs;

  RxInt duration = 0.obs;
  List<RxInt> durationList = <RxInt>[].obs;

  final _feedList = <FeedModel>[].obs;
  List<FeedModel> get feedList => _feedList;

  // final _commentList = <CommentModel>[].obs;
  // List<CommentModel> get commentList => _commentList;

  final _commentArrayList = <List<CommentModel>>[].obs;
  List<List<CommentModel>> get commentArrayList => _commentArrayList;

  final _thumbnailList = <String>[].obs;
  List<String> get thumbnailList => _thumbnailList;

  final _hashTags = <String>[].obs;
  List<String> get hashTags => _hashTags;

  final isVideoLoading = true.obs;
  final _isCommentLoading = false.obs;
  final _isMuted = false.obs;

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

  @override
  Future<void> onInit() async {
    super.onInit();
    await pageInit();
    await fetchFeeds();
  }

  @override
  void dispose() {
    super.dispose();
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
      isVideoLoading.value = true;

      await FeedService.to.getFeedList().then((value) {
        _feedList.addAll(value);
        LoungeController.to.loungeFeedList.addAll(value);
      });

      // 북마크 & 좋아요 여부 확인
      for (var i = 0; i < _feedList.length; i++) {
        await fetchBookmarks(_feedList[i].seq ?? '');
        await fetchLikes(_feedList[i].seq ?? '');
      }

      if (_feedList.isNotEmpty) {

        await getFeedVideoList(videoControllerList);

        // 썸네일
        for (var i = 0; i < _feedList.length; i++) {
          _thumbnailList.add(await thumbnailDownload(_feedList[i].videoUrls![0]));
          await fetchComments(feedList[i].seq ?? '', i);
        }

        isVideoLoading.value = false;

      } else {
        isVideoLoading.value = false;
      }

    } catch (e) {
      _logger.e('fetchFeeds error: $e');
    }
  }

  /// 메뉴 리스트 스트링으로 변환
  /// menuInfo: 메뉴 리스트
  /// return: 메뉴 리스트 스트링
  String convertMenuList(String menuInfo) {
    try {
      // var menuList = '';
      // menuInfo.trim().replaceAll('[', '').replaceAll(']', '').split(' , ').forEach((element) {
      //   menuList += '${element.trim()}\n';
      //   // 마지막 개행 제거
      // });
      // menuList = menuList.substring(0, menuList.length - 1);


      var menuList = '';
      menuInfo.replaceAll('[', '').replaceAll(']', '').split(', ').forEach((element) {
        menuList += '${element}\n';
        // 마지막 개행 제거
      });
      menuList = menuList.substring(0, menuList.length - 1);

      return menuList;
    } catch (e) {
      _logger.e('convertMenuList error: $e');
      return '';
    }
  }

  /// 네이버 플레이스 컨텍스트 해시태그로 변환
  String convertNaverPlaceContext(String naverPlaceContext) {
    try {
      var hashTag = '';
      // 콤마를 # 으로 변환
      naverPlaceContext.replaceAll('[', '').replaceAll(']', '').replaceAll(', ', ' #').split('#').forEach((element) {
        hashTag +='#$element';
      });

      if(hashTag.startsWith('#')) {
        hashTag = hashTag.substring(1);
      }

      return hashTag;
    } catch (e) {
      _logger.e('convertNaverPlaceContext error: $e');
      return '';
    }
  }

  /// 비디오 플레이어 리스트 가져오기
  Future<void> getFeedVideoList(List<List<CachedVideoPlayerPlusController>> videoControllerList) async {
    try {

      for (var i = 0; i < _feedList.length; i++) {
        videoControllers = <CachedVideoPlayerPlusController>[];
        for (var j = 0; j < _feedList[i].videoUrls!.length; j++) {
          var videoController = CachedVideoPlayerPlusController.networkUrl(Uri.parse(_feedList[i].videoUrls![j]));
          videoControllers.add(videoController);
        }
        videoControllerList.add(videoControllers);
      }

      await initializeVideoPlayer(videoControllerList);

    } catch (e) {
      _logger.e('getFeedVideoList error: $e');
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
      _logger.e('disposeVideoPlayer error: $e');
    }
  }

  /// 비디오 플레이어 초기화
  Future<void> initializeVideoPlayer(List<List<CachedVideoPlayerPlusController>> videoControllerList) async {

    try {

      videoControllerList[currentFeedIndex.value][currentVideoUrlIndex.value].initialize().then((_) {
        initializeVideoPlayerFuture = videoControllerList[currentFeedIndex.value][currentVideoUrlIndex.value].play();
        videoControllerList[currentFeedIndex.value][currentVideoUrlIndex.value].play();
        // mute
        if(videoControllerList[currentFeedIndex.value].length == 1) {
          //videoControllerList[currentFeedIndex.value][currentVideoUrlIndex.value].setVolume(0);
          videoControllerList[currentFeedIndex.value][currentVideoUrlIndex.value].setLooping(true);
        }
        videoControllerList[currentFeedIndex.value][currentVideoUrlIndex.value].addListener(_onVideoPlayerStateChanged);
      });

    } catch (e) {
      _logger.e('_initializeVideoPlayer error: $e');
    }
  }

  /// 비디오 플레이어 상태 변경
  _onVideoPlayerStateChanged() {
    try {

      if (videoControllerList[currentFeedIndex.value][currentVideoUrlIndex.value].value.isCompleted) {

        _logger.e('isCompleted');

        if (currentVideoUrlIndex.value < videoControllerList[currentFeedIndex.value].length - 1) {
          currentVideoUrlIndex.value++;
          initializeVideoPlayer(videoControllerList);
        } else {
          currentVideoUrlIndex.value = 0;
          initializeVideoPlayer(videoControllerList);
        }
        _logger.d('currentVideoUrlIndex: ${currentVideoUrlIndex.value}');
      }

    } catch (e) {
      _logger.e('_onVideoPlayerStateChanged error: $e');
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
      _logger.e('thumbnailDownload error: $e');
    }
  }

  /// 음소거 상태 변경
  Future<void> changeMute(int index) async {
    try {

      // for (var videoController in videoControllerList) {
      //   for (var element in videoController) {
      //     element.setVolume(isMuted ? 0 : 1);
      //   }
      // }
      //
      isMuted = !isMuted;
      videoControllerList[currentFeedIndex.value][currentVideoUrlIndex.value].setVolume(isMuted ? 0 : 1);


    } catch (e) {
      _logger.e('changeMute error: $e');
    }
  }

  // 최근 영상 재생
  Future<void> recentPlay() async {
    try {
      videoControllerList[currentFeedIndex.value][currentVideoUrlIndex.value].play();
    } catch (e) {
      _logger.e('recentPlay error: $e');
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
      _logger.e('currentPause error: $e');
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
      _logger.e('allPause error: $e');
    }
  }

  /// 모든 영상 재생
  Future<void> allMute() async {
    try {
      for (var videoController in videoControllerList) {
        for (var element in videoController) {
          element.setVolume(isMuted ? 0 : 1);
        }
      }
      isMuted = !isMuted;
    } catch (e) {
      _logger.e('allMute error: $e');
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

      var doc = FirebaseFirestore.instance.collection('feeds').doc(feedId).collection('comments').doc();

      var userLoginType = UserStore.to.loginType.value;
      _logger.i('userLoginType: $userLoginType');

      if(userLoginType == 'kakao') {
        await FirebaseFirestore.instance
            .collection('feeds')
            .doc(feedId)
            .collection('comments')
            .add({
          'comment': comment,
          'commentId': doc.id,
          'createdAt': Timestamp.now(),
          'uid': '',
          'userName': UserStore.to.displayName.value,
          'userPhotoUrl': UserStore.to.photoUrl.value,
          'feedId': feedId,
          'registerUserId': UserStore.to.id.value,
          'likeCount' : 0,
          'userId': UserStore.to.id.value,
          'likeUserIds': [],
        });
      } else if(userLoginType == 'google') {
        await FirebaseFirestore.instance
            .collection('feeds')
            .doc(feedId)
            .collection('comments')
            .add({
          'comment': comment,
          'commentId': doc.id,
          'createdAt': Timestamp.now(),
          'uid': FirebaseAuth.instance.currentUser!.uid ?? '',
          'userName': FirebaseAuth.instance.currentUser!.displayName ?? '',
          'userPhotoUrl': FirebaseAuth.instance.currentUser!.photoURL,
          'feedId': feedId,
          'registerUserId': UserStore.to.id.value,
          'likeCount' : 0,
          'userId': UserStore.to.id.value,
          'likeUserIds': [],
        });
      }

      // 새로고침
      await refreshComments(feedId, currentFeedIndex.value);

    } catch (e) {
      _logger.e('addComment error: $e');
    }
  }

  /// 댓글 새로고침
  Future<void> refreshComments(String feedId, int feedIndex) async {
    try {

      //_commentArrayList[feedIndex].clear();
      _isCommentLoading.value = true;

      // 댓글 조회
      var tempList = <CommentModel>[];

      await FirebaseFirestore.instance
          .collection('feeds')
          .doc(feedId)
          .collection('comments')
          .orderBy('createdAt', descending: true)
          .snapshots()
          .listen((value) {
        tempList.clear();
        for (var i = 0; i < value.docs.length; i++) {
          final comment = CommentModel.fromJson(value.docs[i].data());
          tempList.add(comment);
        }

        _commentArrayList[feedIndex] = tempList;

        commentController.clear();
        _isCommentLoading.value = false;

      });

    } catch (e) {
      _logger.e('fetchComments error: $e');
    }
  }

  /// [FirebaseFirestore] Feed 댓글 조회
  Future<void> fetchComments(String feedId, int feedIndex) async {
    try {

      // 댓글 조회
      var tempList = <CommentModel>[];

      FirebaseFirestore.instance
          .collection('feeds')
          .doc(feedId)
          .collection('comments')
          .orderBy('createdAt', descending: true)
          .snapshots().listen((event) {
        tempList.clear();

        for (var i = 0; i < event.docs.length; i++) {
          final comment = CommentModel.fromJson(event.docs[i].data());
          tempList.add(comment);
        }

        _commentArrayList.insert(feedIndex, tempList);
        _isCommentLoading.value = false;
      });


    } catch (e) {
      _logger.e('fetchComments error: $e');
    }
  }

  /// 댓글 삭제
  Future<void> deleteComment(String feedId, String commentId, int feedIndex) async {
    try {

      await FirebaseFirestore.instance
          .collection('feeds')
          .doc(feedId)
          .collection('comments')
          .where('commentId', isEqualTo: commentId)
          .snapshots()
          .listen((value) async {
        for (var i = 0; i < value.docs.length; i++) {
          value.docs[i].reference.delete();
        }
        await refreshComments(feedId, feedIndex);
        Get.back();
      });

    } catch (e) {
      _logger.e('deleteComment error: $e');
    }
  }

  /// 댓글 좋아요
  Future<void> addCommentLike(String feedId, String commentId, int feedIndex) async {
    try {

      // 자신이 올린 게시물 제외
      if (UserStore.to.id.value == _commentArrayList[feedIndex].firstWhere((element) => element.commentId == commentId).userId) {
        GlobalToastController.to.showToast('자신이 작성한 댓글은 좋아요를 누를 수 없습니다.');
        return;
      }

      // 이미 좋아요를 누른 경우
      if (_commentArrayList[feedIndex].firstWhere((element) => element.commentId == commentId).likeUserIds!.contains(UserStore.to.id.value)) {
        GlobalToastController.to.showToast('이미 좋아요를 누르셨습니다.');
        return;
      }

      await FirebaseFirestore.instance
          .collection('feeds')
          .doc(feedId)
          .collection('comments')
          .where('commentId', isEqualTo: commentId)
          .get()
          .then((value) async {
        for (var i = 0; i < value.docs.length; i++) {
          value.docs[i].reference.update({
            'likeCount': FieldValue.increment(1),
            'likeUserIds': FieldValue.arrayUnion([UserStore.to.id.value]),
          });
        }
        await refreshComments(feedId, feedIndex);
      });

    } catch (e) {
      _logger.e('likeComment error: $e');
    }
  }


  /// 댓글 좋아요 취소
  /// feedId: 피드 ID
  /// commentId: 댓글 ID
  /// feedIndex: 피드 인덱스
  Future<void> cancelCommentLike(String feedId, String commentId, int feedIndex) async {
    try {

      await FirebaseFirestore.instance
          .collection('feeds')
          .doc(feedId)
          .collection('comments')
          .where('commentId', isEqualTo: commentId)
          .get()
          .then((value) async {
        for (var i = 0; i < value.docs.length; i++) {
          value.docs[i].reference.update({
            'likeCount': FieldValue.increment(-1),
            'likeUserIds': FieldValue.arrayRemove([UserStore.to.id.value]),
          });
        }
        await refreshComments(feedId, feedIndex);
      });

    } catch (e) {
      _logger.e('cancelCommentLike error: $e');
    }
  }

  /// 댓글 수정
  Future<void> updateComment(String feedId, String commentId, String comment, int feedIndex) async {
    try {

      await FirebaseFirestore.instance
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
      _logger.e('updateComment error: $e');
    }
  }

  /// 피드 북마크 조회
  /// feedId: 피드 ID
  /// return: 북마크 여부
  /// 북마크 여부를 확인하여 북마크 여부를 반환
  Future<void> fetchBookmarks(String feedId) async {
    try {

      await FirebaseFirestore.instance
          .collection('users')
          .doc(UserStore.to.id.value)
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
        _logger.d('isFeedBookmark: $isFeedBookmark');
      });

    } catch (e) {
      _logger.e('fetchBookmarks error: $e');
    }
  }

  /// 피드 북마크 추가
  Future<void> addBookmark(String feedId) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(UserStore.to.id.value)
          .collection('bookmarks')
          .doc(feedId)
          .set({
        'feedId': feedId,
        'createdAt': Timestamp.now(),
      });

      // 피드 북마크 수 추가
      await FirebaseFirestore.instance
          .collection('feeds')
          .get()
          .then((value) {
        for (var i = 0; i < value.docs.length; i++) {
          if(currentFeedIndex.value == i){
            value.docs[i].reference.update({
              'bookmarkCount': FieldValue.increment(1),
            });
          }
        }
      });

      fetchBookmarks(feedId);
      GlobalToastController.to.showToast('북마크에 추가되었습니다.');
    } catch (e) {
      _logger.e('addBookmark error: $e');
    }
  }

  /// 피드 북마크 삭제
  Future<void> removeBookmark(String feedId) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(UserStore.to.id.value)
          .collection('bookmarks')
          .where('feedId', isEqualTo: feedId)
          .get()
          .then((value) {
        for (var i = 0; i < value.docs.length; i++) {
          value.docs[i].reference.delete();
        }
      });

      // 피드 북마크 수 삭제
      await FirebaseFirestore.instance
          .collection('feeds')
          .get()
          .then((value) {
        for (var i = 0; i < value.docs.length; i++) {
          if(currentFeedIndex.value == i){
            value.docs[i].reference.update({
              'bookmarkCount': FieldValue.increment(-1),
            });
          }
        }
      });

      fetchBookmarks(feedId);
      GlobalToastController.to.showToast('북마크에서 삭제되었습니다.');
    } catch (e) {
      _logger.e('deleteBookmark error: $e');
    }
  }

  /// 피드 좋아요 조회
  /// feedId: 피드 ID
  /// return: 좋아요 여부
  /// 좋아요 여부를 확인하여 좋아요 여부를 반환
  Future<void> fetchLikes(String feedId) async {
    try {

      await FirebaseFirestore.instance
          .collection('users')
          .doc(UserStore.to.id.value)
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
        _logger.d('isLike: ${FeedController.to.feedList[currentFeedIndex.value].isLike}');
      });

    } catch (e) {
      _logger.e('fetchLikes error: $e');
    }
  }

  /// 피드 좋아요 추가
  Future<void> addLike(String feedId) async {
    try {

      await FirebaseFirestore.instance
          .collection('users')
          .doc(UserStore.to.id.value)
          .collection('likes')
          .doc(feedId)
          .set({
        'feedId': feedId,
        'createdAt': Timestamp.now(),
      });

      // 피드 좋아요 수 추가
      await FirebaseFirestore.instance
          .collection('feeds')
          .get()
          .then((value) {
        for (var i = 0; i < value.docs.length; i++) {
          if(currentFeedIndex.value == i){
            value.docs[i].reference.update({
              'likeCount': FieldValue.increment(1),
            });
            _feedList[i].likeCount = value.docs[i].data()['likeCount'] + 1;
            _logger.d('add likeCount: ${_feedList[i].likeCount}');
          }
        }
      });

      fetchLikes(feedId);
      GlobalToastController.to.showToast('좋아요를 눌렀습니다.');
    } catch (e) {
      _logger.e('addLike error: $e');
    }
  }

  /// 피드 좋아요 삭제
  Future<void> removeLike(String feedId) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(UserStore.to.id.value)
          .collection('likes')
          .where('feedId', isEqualTo: feedId)
          .get()
          .then((value) {
        for (var i = 0; i < value.docs.length; i++) {
          value.docs[i].reference.delete();
        }
      });

      // 피드 좋아요 수 삭제
      await FirebaseFirestore.instance
          .collection('feeds')
          .get()
          .then((value) {
        for (var i = 0; i < value.docs.length; i++) {
          if(currentFeedIndex.value == i){
            value.docs[i].reference.update({
              'likeCount': FieldValue.increment(-1),
            });
            _feedList[i].likeCount = value.docs[i].data()['likeCount'] - 1;
            _logger.d('remove likeCount: ${_feedList[i].likeCount}');
          }
        }
      });

      fetchLikes(feedId);
      GlobalToastController.to.showToast('좋아요를 취소했습니다.');

    } catch (e) {
      _logger.e('removeLike error: $e');
    }
  }

  /// 피드 공유
  Future<void> shareFeed(String feedId,) async {
    try {
      var feed = _feedList.firstWhere((element) => element.seq == feedId);
      var shareText = '포잇에서 공유한 글입니다.\n\n';
      shareText += '제목: ${feed.storeName}\n';
      shareText += '위치: ${feed.storeAddress}\n';

      // 클립보드 복사
      await Clipboard.setData(ClipboardData(text: shareText));
      GlobalToastController.to.showToast('클립보드에 복사되었습니다.');

    } catch (e) {
      _logger.e('shareFeed error: $e');
    }
  }


}
