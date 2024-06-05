import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:foreats/screens/map/map_controller.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';

import '../../model/feed_model.dart';
import '../../model/map_model.dart';
import '../../model/user_model.dart';
import '../../utils/logger.dart';
import '../login/user_store.dart';

class LoungeController extends GetxController {

  final _logger = Logger();
  static LoungeController get to => Get.find();

  final userStore = UserStore.to;
  late TextEditingController searchController;

  final _loungeFeedList = <FeedModel>[].obs;
  List<FeedModel> get loungeFeedList => _loungeFeedList;
  set loungeFeedList(List<FeedModel> value) => _loungeFeedList.value = value;

  final _supportersList = <UserModel>[].obs;
  List<UserModel> get supportersList => _supportersList;
  set supportersList(List<UserModel> value) => _supportersList.value = value;

  final _loungeThumbnailList = <String>[].obs;
  List<String> get loungeThumbnailList => _loungeThumbnailList;

  final RxString location = ''.obs;

  RxList<double> lonlat = [0.0, 0.0].obs;
  RxInt locationIndex = 0.obs;

  RxList<UserModel> users = <UserModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    searchController = TextEditingController();
  }

  // 서포터즈 리스트 가져오기
  Future<List<UserModel>> fetchSupportersList() async {
    try {
      final supportersList = <UserModel>[];
      final querySnapshot = await FirebaseFirestore.instance.collection('users').get();
      for (final query in querySnapshot.docs) {
        final user = UserModel.fromJson(query.data() as Map<String, dynamic>);
        supportersList.add(user);
      }

      final feedList = <FeedModel>[];
      final feedQuerySnapshot = await FirebaseFirestore.instance.collection('feeds').get();
      for (final query in feedQuerySnapshot.docs) {
        final feed = FeedModel.fromJson(query.data() as Map<String, dynamic>);
        feedList.add(feed);
      }

      // 피드가 많은순으로 정렬
      supportersList.sort((a, b) => feedList.where((feed) => feed.userNickname == b.nickname).length.compareTo(feedList.where((feed) => feed.userNickname == a.nickname).length));
      //AppLog.to.d('supportersList: $supportersList');

      _supportersList.value = supportersList;
      return supportersList;
    } catch (e) {
      _logger.d('fetchSupportersList error: $e');
      return [];
    }
  }

  /// 라운지 피드 가져오기
  Future<List<FeedModel>> fetchLoungeFeedList(String searchKeyword) async {
    try {
      final loungeFeedList = <FeedModel>[];
      final querySnapshot = await FirebaseFirestore.instance.collection('feeds').where('storeAddress', isGreaterThanOrEqualTo: searchKeyword).get();
      for (final query in querySnapshot.docs) {
        final feed = FeedModel.fromJson(query.data() as Map<String, dynamic>);
        loungeFeedList.add(feed);
      }
      _loungeFeedList.value = loungeFeedList;
      return loungeFeedList;
    } catch (e) {
      _logger.d('fetchLoungeFeedList error: $e');
      return [];
    }
  }

  /// 라운지 피드 검색 결과 가져오기
  Future<List<FeedModel>> fetchLoungeFeedSearchResult(String searchKeyword) async {
    try {
      final loungeFeedList = <FeedModel>[];
      final querySnapshot = await FirebaseFirestore.instance.collection('feeds').where('storeAddress', isGreaterThanOrEqualTo: searchKeyword).get();
      for (final query in querySnapshot.docs) {
        final feed = FeedModel.fromJson(query.data() as Map<String, dynamic>);
        loungeFeedList.add(feed);
      }
      _loungeFeedList.value = loungeFeedList;
      return loungeFeedList;
    } catch (e) {
      _logger.d('fetchLoungeFeedSearchResult error: $e');
      return [];
    }
  }

  /// 현재 지역구 좌표값 주소 변환
  Future<String> fetchCurrentLocation() async {
    try {
      await MapController.to.initCurrentLocation();
      return await MapController.to.convertLatLngToAddress();
    } catch (e) {
      _logger.d('fetchCurrentLocation error: $e');
      return '';
    }
  }

  /// 주변 지역구 리스트 가져오기
  Future<RxList<MapModel>> fetchSearchPlace(String? keyword) async {
    try {
      AppLog.to.d('fetchSearchPlace: $keyword');
     return MapController.to.fetchSearchPlace(keyword ?? '맛집', page: 1);
    } catch (e) {
      _logger.d('fetchLoungeThumbnailList error: $e');
      return RxList<MapModel>();
    }
  }

}