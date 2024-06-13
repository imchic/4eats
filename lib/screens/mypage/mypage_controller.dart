import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../model/feed_model.dart';
import '../../utils/logger.dart';
import '../login/user_store.dart';

class MyPageController extends GetxController
    with GetSingleTickerProviderStateMixin {
  static MyPageController get to => Get.find();

  final List<Tab> tabs = <Tab>[
    const Tab(text: '내가 쓴 글'),
    const Tab(text: '북마크'),
  ];

  late TabController tabController;

  RxList<FeedModel> myFeeds = <FeedModel>[].obs;

  List<FeedModel> get myFeedList => myFeeds;

  // bookmark
  RxList<FeedModel> bookmarks = <FeedModel>[].obs;

  List<FeedModel> get bookmarkList => bookmarks;

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(length: tabs.length, vsync: this);
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
      AppLog.to.e('getMyFeeds error: $e');
      return myFeeds;
    }
  }

  /// 북마크한 글 가져오기
  Future<RxList<FeedModel>> getMyBookmarks() async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .where('uid', isEqualTo: UserStore.to.user.value.uid)
          .get()
          .then((value) {
        for (var i = 0; i < value.docs.length; i++) {
          value.docs[i].reference.collection('bookmarks').get().then((value) {
            bookmarks.clear();
            for (final bookmark in value.docs) {
              FirebaseFirestore.instance
                  .collection('feeds')
                  .where('seq', isEqualTo: bookmark.data()['feedId'])
                  .get()
                  .then((value) {
                for (final feed in value.docs) {
                  bookmarks.add(FeedModel.fromJson(feed.data()));
                }
                AppLog.to.d('bookmarks: $bookmarks');
              });
            }
          });
        }
      });

      return bookmarks;
    } catch (e) {
      AppLog.to.e('getMyBookmarks error: $e');
      return bookmarks;
    }
  }
}
