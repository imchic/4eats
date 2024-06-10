import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../feed/feed_controller.dart';

class SearchKeywordController extends GetxController {
  final TextEditingController searchController = TextEditingController();

  final _firebase = FirebaseFirestore.instance;

  RxList searchBestKeywords = [

  ].obs;

  RxList searchKeywords = [].obs;
  RxList searchResults = [].obs;
  RxList searchRecentKeywords = [].obs;

  @override
  Future<void> onInit() async {
    super.onInit();
    await _firebase
        .collection('feeds')
        .get()
        .then((value) {
      value.docs.forEach((element) {
        searchKeywords.add(element['storeName']);
        // searchKeywords.add(element['storeType']);
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
    //searchResults.addAll(searchKeywords.where((element) => element.contains(keyword)).toList());//print('검색결과: $searchResults');
    searchResults.addAll(searchKeywords.where((element) => element.toString().toLowerCase().contains(keyword.toLowerCase())).toList());
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
    List<String> recentKeywords = searchRecentKeywords.map((e) => e.toString()).toList();
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

  // 서버 내 인기검색어 불러오기
  Future<void> getBestKeywords() async {
    // await _firebase
    //     .collection('search_keywords')
    //     .orderBy('count', descending: true)
    //     .limit(10)
    //     .get().then((event) {
    //   searchBestKeywords.clear();
    //   // 중복제거
    //   event.docs.forEach((element) {
    //     if(!searchBestKeywords.contains(element['keyword'])) {
    //       searchBestKeywords.add(element['keyword']);
    //     }
    //   });
    // });
    await _firebase
        .collection('search_keywords')
        .orderBy('count', descending: true)
        .limit(10)
        .get()
        .then((value) {
      searchBestKeywords.clear();
      value.docs.forEach((element) {
        if(!searchBestKeywords.contains(element['keyword'])) {
          searchBestKeywords.add(element['keyword']);
        }
      });
    });
  }

  // 서버 내 인기검색어 저장
  Future<void> saveBestKeywords(String keyword) async {

    if(keyword.isNotEmpty) {

      if(searchBestKeywords.contains(keyword)) {
        await _firebase
            .collection('search_keywords')
            .where('keyword', isEqualTo: keyword)
            .get()
            .then((value) {
          value.docs.forEach((element) {
            int count = element['count'] + 1;
            element.reference.update({'count': count});
          });
        });
      } else {
        await _firebase.collection('search_keywords').add({
          'keyword': keyword,
          'timestamp': FieldValue.serverTimestamp(),
          'count': 1,
        });
      }

      await _firebase
          .collection('search_keywords')
          .orderBy('timestamp', descending: true)
          .limit(5)
          .get()
          .then((value) {
        searchBestKeywords.clear();
        value.docs.forEach((element) {
          searchBestKeywords.add(element['keyword']);
        });
      });

    }


  }

}
