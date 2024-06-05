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
  }

  Future<RxList<FeedModel>> getMyFeeds() async {
    try {
      final feeds = await FirebaseFirestore.instance
          .collection('feeds')
          .where('uid', isEqualTo: UserStore.to.user.value.uid)
          .orderBy('createdAt', descending: true)
          .get();
      myFeeds.clear();
      for (final feed in feeds.docs) {
        myFeeds.add(FeedModel.fromJson(feed.data()));
      }
      //AppLog.to.d('myFeeds: $myFeeds');
      return myFeeds;
    } catch (e) {
      _logger.e('getMyFeeds error: $e');
      return myFeeds;
    }
  }

}