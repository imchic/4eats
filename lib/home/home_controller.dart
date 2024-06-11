import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:foreats/screens/notification/notifications_controller.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';

import '../screens/biz/biz_screen.dart';
import '../screens/feed/feed_controller.dart';
import '../screens/feed/feed_screen.dart';
import '../screens/feed/merge_feed_screen.dart';
import '../screens/login/user_store.dart';
import '../screens/lounge/lounge_screen.dart';
import '../screens/mypage/mypage_screen.dart';
import '../screens/upload/upload_screen.dart';
import '../utils/firebase_message.dart';
import '../widget/login_bottomsheet.dart';

class HomeController extends GetxController {
  static HomeController get to => Get.find();
  final _logger = Logger();

  RxInt _currentIndex = 0.obs;
  RxInt _prevIndex = 0.obs;

  int get currentIndex => _currentIndex.value;
  int get prevIndex => _prevIndex.value;

  @override
  void onInit() {
    super.onInit();
    FirebaseMessageApi().initNotifications();
  }

  final List<Widget> _screens = [
    FeedScreen(),
    LoungeScreen(),
    BizScreen(),
    const MyPageScreen(),
  ];

  List<Widget> get screens => _screens;
  Widget get currentScreen => _screens[_currentIndex.value];

  // 페이지 이동
  void moveToPage(int index) {

    if(index == 0){
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.black,
        systemNavigationBarIconBrightness: Brightness.light,
      ));
    }

    if (index == 2 || index == 3) {
      if(UserStore.to.isLoginCheck.value) {
        _currentIndex.value = index;
      } else {
        Get.bottomSheet(
          const LoginBottomSheet(),
        ).whenComplete(() {
          _currentIndex.value = 0;
          _logger.d('whenComplete');
          FeedController.to.currentPause(
            FeedController.to.currentFeedIndex.value,
            FeedController.to.currentVideoUrlIndex.value,
            false
          );
        });
      }
    }

    if(index == 0){
      FeedController.to.recentPlay();
    } else {
      FeedController.to.allPause();
    }

    _currentIndex.value = index;
  }

  /// 페이지 초기화
  String timeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    var result = '';
    if (difference.inDays > 0) {
      //print('${difference.inDays}일 전');
      result = '${difference.inDays}일 전';
    } else if (difference.inHours > 0) {
      //print('${difference.inHours}시간 전');
      result = '${difference.inHours}시간 전';
    } else if (difference.inMinutes > 0) {
      //print('${difference.inMinutes}분 전');
      result = '${difference.inMinutes}분 전';
    } else {
      //print('방금 전');
      result = '방금 전';
    }

    return result;
  }
}
