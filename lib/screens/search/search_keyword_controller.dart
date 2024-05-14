import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../feed/feed_controller.dart';

class SearchKeywordController extends GetxController {
  final TextEditingController searchController = TextEditingController();

  RxList searchBestKeywords = [
    '한식',
    '부모님'
  ].obs;

  RxList searchKeywords = [].obs;
  RxList searchResults = [].obs;
  RxList searchRecentKeywords = [].obs;

  @override
  Future<void> onInit() async {
    super.onInit();
    await FirebaseFirestore.instance
        .collection('feeds')
        .get()
        .then((value) {
      value.docs.forEach((element) {
        searchKeywords.add(element['storeName']);
      });
    });
    getRecentKeywords();
    FeedController.to.allPause();
  }

  void dispose() {
    FeedController.to.recentPlay();
    searchController.dispose();
    super.dispose();
  }

  void search(String keyword) {
    print('검색어: $keyword');
    searchResults.clear();
    searchResults.addAll(searchKeywords
        .where((element) => element.contains(keyword))
        .toList());
    print('검색결과: $searchResults');
  }

  void clearSearchResults() {
    searchResults.clear();
  }

  Future<void> getRecentKeywords() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> recentKeywords = prefs.getStringList('recentKeywords') ?? [];
    searchRecentKeywords.value = recentKeywords;
  }

  Future<void> addRecentKeyword(String keyword) async {
    if (searchRecentKeywords.contains(keyword)) {
      searchRecentKeywords.remove(keyword);
    }
    searchRecentKeywords.insert(0, keyword);

    // 최근 검색어 로컬에 저장
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> recentKeywords =
        searchRecentKeywords.map((e) => e.toString()).toList();
    prefs.setStringList('recentKeywords', recentKeywords);
  }

  void removeRecentKeyword(String keyword) {
    searchRecentKeywords.remove(keyword);
    SharedPreferences.getInstance().then((prefs) {
      List<String> recentKeywords =
          searchRecentKeywords.map((e) => e.toString()).toList();
      prefs.setStringList('recentKeywords', recentKeywords);
    });
  }

  void clearRecentKeywords() {
    searchRecentKeywords.value = [];
    SharedPreferences.getInstance()
        .then((prefs) => prefs.remove('recentKeywords'));
  }
}
