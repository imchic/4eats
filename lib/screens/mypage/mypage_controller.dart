import 'package:cached_video_player_plus/cached_video_player_plus.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';

import '../../model/feed_model.dart';
import '../login/user_store.dart';

class MyPageController extends GetxController with GetSingleTickerProviderStateMixin {

  static MyPageController get to => Get.find();

  final _logger = Logger();

  // final List<Tab> tabs = <Tab>[
  //   const Tab(text: '내가 쓴 글'),
  //   const Tab(text: '북마크'),
  // ];

  late TabController tabController;

  RxList<FeedModel> myFeeds = <FeedModel>[].obs;
  List<FeedModel> get myFeedList => myFeeds;

  @override
  void onInit() {
    super.onInit();
    //tabController = TabController(length: tabs.length, vsync: this);
    UserStore.to.getUserProfile();
  }

  Future<void> getMyFeeds() async {
    myFeeds.clear();
    await FirebaseFirestore.instance
        .collection('feeds')
        .where('uid', isEqualTo: UserStore.to.userProfile.uid)
        .get()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        //final FeedModel feed = FeedModel.fromMap(doc.data() as Map<String, dynamic>);
        //myFeeds.add(feed);
      });
    });
  }

  convertVideoPlayTime(int playTime) {
    final int minutes = playTime ~/ 60;
    final int seconds = playTime % 60;
    if (seconds < 10) {
      return '$minutes:0$seconds';
    }
  }

}