import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:foreats/screens/map/map_controller.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';

import '../../model/feed_model.dart';
import '../../model/map_model.dart';
import '../../model/user_model.dart';
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

  List<String> locationList = [
    '제주',
    '강원',
    '서울',
    '부산',
    '경기도',
    '인천',
    '여수',
    '경상북도',
  ];

  List<String> locationIconList = [
    'assets/images/ic_jeju.svg',
    'assets/images/ic_gangwon.svg',
    'assets/images/ic_seoul.svg',
    'assets/images/ic_busan.svg',
    'assets/images/ic_gyeonggi.svg',
    'assets/images/ic_incheon.svg',
    'assets/images/ic_yeosu.svg',
    'assets/images/ic_north_gyeongsang.svg',
  ];

  List<String> locationThumbnailList = [
    'https://i0.wp.com/blog.findmybucketlist.com/wp-content/uploads/2020/10/%EC%A0%9C%EC%A3%BC%EB%8F%84-2.jpg?resize=792%2C446&ssl=1',
    'https://www.gtdc.or.kr/dzSmart/upfiles/Tours/2018August/34/0cbd16f8edf5e3e1ec23f1da43b791de_1534734408.jpg',
    'https://res.cloudinary.com/kyte/image/upload/w_1080,h_1560,q_auto,f_auto,e_sharpen:50,c_fill,g_auto/v1636358904/hotel/square_lab/KR/65339_46',
    'https://www.visitbusan.net/uploadImgs/files/cntnts/20191229153531987_oen',
    'https://www.gtdc.or.kr/dzSmart/upfiles/Tours/2018August/34/0cbd16f8edf5e3e1ec23f1da43b791de_1534734408.jpg',
    'https://a.cdn-hotels.com/gdcs/production181/d952/77e61a1a-d4ef-4f09-b657-ff490a477dff.jpg?impolicy=fcrop&w=800&h=533&q=medium',
    'https://cdn.dbltv.com/news/photo/202110/17780_19417_5311.jpg',
    'https://a.cdn-hotels.com/gdcs/production186/d1111/adb0a404-7e1e-4d39-9a05-16aa1e179c1c.jpg?impolicy=fcrop&w=800&h=533&q=medium',
  ];

  RxList<double> lonlat = [0.0, 0.0].obs;
  RxInt locationIndex = 0.obs;

  RxList<UserModel> users = <UserModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    searchController = TextEditingController();
    fetchLoungeFeedList();
  }

  Future<void> moveToLocation() async {

    if (locationIndex.value == 0) {
      lonlat.value = [33.489011, 126.498302];
    }
    // 강원
    if (locationIndex.value == 1) {
      lonlat.value = [37.885907, 127.729971];
    }
    // 서울
    if (locationIndex.value == 2) {
      lonlat.value = [37.5665, 126.9780];
    }
    // 부산
    if (locationIndex.value == 3) {
      lonlat.value = [35.1796, 129.0756];
    }
    // 경기도
    if (locationIndex.value == 4) {
      lonlat.value = [37.4138, 127.5183];
    }

    // 인천
    if (locationIndex.value == 5) {
      lonlat.value = [37.4563, 126.7052];
    }

    // 여수
    if (locationIndex.value == 6) {
      lonlat.value = [34.7604, 127.6622];
    }
    // 경상북도
    if (locationIndex.value == 7) {
      lonlat.value = [36.5763, 128.5053];
    }

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
      //_logger.d('fetchSupportersList: $supportersList');
      _supportersList.value = supportersList;
      return supportersList;
    } catch (e) {
      _logger.d('fetchSupportersList error: $e');
      return [];
    }
  }

  /// 라운지 피드 가져오기
  Future<List<FeedModel>> fetchLoungeFeedList() async {
    try {
      final loungeFeedList = <FeedModel>[];
      final querySnapshot = await FirebaseFirestore.instance.collection('feeds').get();
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

  /// 현재 지역구 좌표값 주소 변환
  Future<String> fetchCurrentLocation() async {
    try {
      await MapController.to.initCurrentLocation();
      var result = await MapController.to.convertLatLngToAddress();
      return result;
    } catch (e) {
      _logger.d('fetchCurrentLocation error: $e');
      return '';
    }
  }

  /// 주변 지역구 리스트 가져오기
  Future<RxList<MapModel>> fetchSearchPlace() async {
    try {
     return MapController.to.fetchSearchPlace('맛집', page: 1);
    } catch (e) {
      _logger.d('fetchLoungeThumbnailList error: $e');
      return RxList<MapModel>();
    }
  }

}