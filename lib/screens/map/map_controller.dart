import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:custom_info_window/custom_info_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:foreats/model/store_model.dart';
import 'package:foreats/utils/toast_controller.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:dio/dio.dart' as dio;
import 'package:googleapis/admob/v1.dart';
import 'package:widget_marker_google_map/widget_marker_google_map.dart';

import '../../model/map_marker.dart';
import '../../model/map_model.dart';
import '../../utils/logger.dart';
import 'location_service.dart';

import 'package:image/image.dart' as IMG;

class MapController extends GetxController {
  static MapController get to => Get.find();

  final _fireStore = FirebaseFirestore.instance;

  late GoogleMapController mapController;
  late TextEditingController searchController;

  final RxList<MapModel> storeList = <MapModel>[].obs;
  final RxList<Marker> markers = <Marker>[].obs;

  // widgetMarker
  final List<WidgetMarker> tempMarkers = [];
  final RxList<WidgetMarker> widgetMarkers = <WidgetMarker>[].obs;

  final List<MapMarker> googleMarkers = [];
  //late final List<MapMarker> googleMarkers = [];

  final RxInt page = 1.obs;
  final RxString searchPlace = ''.obs;

  final RxBool _isMapLoading = true.obs;

  bool get isMapLoading => _isMapLoading.value;

  set isMapLoading(bool value) => _isMapLoading.value = value;

  final RxBool isSearchLoading = false.obs;
  final RxBool isPolylineLoading = false.obs;
  final RxInt selectIndex = 0.obs;

  final RxString searchAddress = ''.obs;
  final RxString storeCategory = ''.obs;
  final RxString storeMenuInfo = ''.obs;
  final RxString storeContext = ''.obs;

  Rx<LatLng> currentLocation = LatLng(37.566535, 126.97796919999996).obs;

  final ScrollController scrollController = ScrollController();

  final CustomInfoWindowController customInfoWindowController = CustomInfoWindowController();
  final List<CustomInfoWindowController> customInfoWindowControllerList = [];

  final containStoreList = <MapModel>[].obs;


  @override
  Future<void> onInit() async {
    super.onInit();
    searchController = TextEditingController();
    await getCurrentLocation();
  }

  @override
  void dispose() {
    super.dispose();
    searchController.dispose();
    storeList.clear();
    markers.clear();
    widgetMarkers.clear();
    googleMarkers.clear();
    customInfoWindowControllerList.clear();
    mapController.dispose();
  }

  /// 스크롤 위치로 이동
  void scrollToIndex(int index) {
    scrollController.jumpTo(index * 150.0);
  }

  /// 지도 생성
  Future<void> onMapCreated(GoogleMapController controller) async {

    AppLog.to.d('onMapCreated');
    mapController = controller;
    customInfoWindowController.googleMapController = controller;
    isMapLoading = false;

    await fetchSearchPlace('맛집', page: 1);
    await convertLatLngToAddress();

  }

  Future<void> onCameraMove(CameraPosition position) async {
    currentLocation.value = position.target;
  }

  Future<void> onCameraIdle() async {
    await convertLatLngToAddress();
  }

  Future<void> onCameraMoveStarted() async {
    searchController.clear();
    searchPlace.value = '';
    searchAddress.value = '';
    storeCategory.value = '';
    storeMenuInfo.value = '';
    storeContext.value = '';
    AppLog.to.d('onCameraMoveStarted');
  }

  Future<void> onSearchPlace() async {
    AppLog.to.d('onSearchPlace: ${searchController.text}');
    searchPlace.value = searchController.text;
    page.value = 1;
    //await fetchSearchPlace(searchPlace.value, page: page.value);
  }

  Future<LatLng> initCurrentLocation() async {

    // geolocator
    LocationPermission permission = await Geolocator.requestPermission(); //오류 해결 코드
    if (permission == LocationPermission.denied) {
      AppLog.to.d('위치 권한이 없습니다.');
      return currentLocation.value;
    } else {
      Position location = await Geolocator.
      getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

      currentLocation.value = LatLng(location.latitude, location.longitude);
      return currentLocation.value;
    }

  }


  /// 현재 위치 값 구하기
  Future<LatLng> getCurrentLocation() async {

    await initCurrentLocation();

    currentLocation.value = LatLng(currentLocation.value.latitude, currentLocation.value.longitude);

    await addMarker(currentLocation.value, null);
    await convertLatLngToAddress();

    isMapLoading = false;
    return currentLocation.value;

  }

  /// 현재 위치로 이동
  Future<void> moveToCurrentLocation(LatLng value) async {
    await mapController.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: value,
          zoom: 15,
        ),
      ),
    );
  }

  /// 마커 추가
  /// latLng: 위경도
  /// model: 맛집 정보
  Future<void> addMarker(LatLng latLng, MapModel? model) async {

    WidgetMarker widgetMarker = WidgetMarker(
      markerId: model == null ? 'currentLocation' : model.name!,
      position: latLng,
      widget: SizedBox(
        height: 100.h,
        child: Center(
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(4.r),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      spreadRadius: 1,
                      blurRadius: 2,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Text(
                  model?.name ?? '',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Image.asset(
                'assets/images/ic_marker.png',
              ),
            ],
          ),
        ),
      ),
      onTap: () {
        onMarkerTapped(model!);
      },
    );
    widgetMarkers.add(widgetMarker);
  }

  /// 주소 변환 (위경도 -> 주소)
  Future<String> convertLatLngToAddress() async {

    await initCurrentLocation().then((value) => currentLocation.value = LatLng(value.latitude, value.longitude));

    var lat = currentLocation.value.latitude.toString();
    var lng = currentLocation.value.longitude.toString();

    var reverseGeocodingUri = Uri.parse(
        'https://naveropenapi.apigw.ntruss.com/map-reversegeocode/v2/gc'
        '?request=coordsToaddr'
        '&coords=$lng,$lat'
        '&sourcecrs=epsg:4326'
        '&output=json'
        '&orders=roadaddr');

    dio.Response response = await dio.Dio().get(
      reverseGeocodingUri.toString(),
      options: dio.Options(
        headers: {
          'X-NCP-APIGW-API-KEY-ID': "ilm1l1ctqq",
          'X-NCP-APIGW-API-KEY': "d4BhumaBIZwkf7Kg7aJtaGR1wGdng7IUJL2MSuZ3",
        },
      ),
    );

    if(response.data['results'].isEmpty) {
      AppLog.to.d('주소가 없습니다.');
      Position location = await Geolocator.
      getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      currentLocation.value = LatLng(location.latitude, location.longitude);
      return '';
    }

    var sido = response.data['results'][0]['region']['area1']['name'];
    var sigungu = response.data['results'][0]['region']['area2']['name'];
    var dong = response.data['results'][0]['region']['area3']['name'];
    var land = response.data['results'][0]['land']['number1'];
    var ho = response.data['results'][0]['land']['number2'];

    searchAddress.value = '$sido $sigungu $dong $land $ho';
    return searchAddress.value;
    //_logger.d('searchAddress: $searchAddress');
  }

  /// 지도 내 네이버 플레이스 검색해서 마커 표출
  /// value: 검색어
  /// page: 페이지
  Future<RxList<MapModel>> fetchSearchPlace(String value, {required page}) async {

    storeList.clear();
    containStoreList.clear();
    markers.clear();

    try {

      if(value.isEmpty) {
        AppLog.to.d('검색어가 없습니다.');
        return storeList;
      }

      isSearchLoading.value = true;
      LatLng latLng = currentLocation.value;

      var searchPlaceUrl =
              'https://map.naver.com/p/api/search/allSearch?query=$value&type=food&searchCoord=${latLng.longitude};${latLng.latitude}&page=$page&displayCount=50&isPlaceRecommendationReplace=true&lang=ko';

      AppLog.to.d('네이버 플레이스 검색: $searchPlaceUrl');

      dio.Response response = await dio.Dio().get(searchPlaceUrl).timeout(
            const Duration(seconds: 5),
            onTimeout: () {
              AppLog.to.d('timeout');
              isSearchLoading.value = false;
              return dio.Response(requestOptions: dio.RequestOptions(path: ''));
            },
          );

      var searchResultItem = response.data['result']['place']['list'];
      AppLog.to.d('네이버 플레이스 검색결과: $searchResultItem');

      var foodCategory = [
            '한식',
            '분식',
            '중식',
            '일식',
            '양식',
            '카페',
            '패스트푸드',
            '디저트',
            '베이커리',
            '커피',
            '펍',
            '이탈리안',
            '음식점',
            '맛집',
            '포장마차',
            '술집',
            '맥주,호프',
            '이탈리아음식',
            '스파게티,파스타전문',
            '해물,생선요리',
            '복어요리',
            '육류,고기요리',
            '정육식당',
            '닭갈비',
            '카페,디저트',
          ];

      for (var element in searchResultItem) {

        var menuInfo = element['menuInfo'];
        var contextInfo = element['context'];

        List<String> menuInfoList = [];
        // _logger.d('menuInfo: $menuInfo');
        if(menuInfo == null || contextInfo == null) {
          continue;
        }
        menuInfo.replaceAll('[', '').replaceAll(']', '').split(' | ').forEach((element) {
          menuInfoList.add(element);
        });

        List<String> contextList = [];
        contextInfo.join(', ').split(', ').forEach((element) {
          contextList.add(element);
        });


        var store = MapModel(
          name: element['name'],
          address: element['address'],
          category: element['category'].join(', '),
          roadAddress: element['roadAddress'],
          status: element['bizhourInfo'],
          thumbnail: element['thumUrl'] ?? '',
          tel: element['phone'],
          x: element['x'],
          y: element['y'],
          distance: double.parse(element['distance']).toString(),
          menuInfo: menuInfoList,
          contextInfo: contextList,
          isContain: false,
        );

        if(store.x == null || store.y == null) {
          AppLog.to.d('x, y 값이 없습니다.');
          continue;
        }

        if (!foodCategory.contains(store.category?.split(', ').first) ||
            store.category == null) {
          AppLog.to.w('추가되지 않아야하는 카테고리: ${store.category}');
        } else {
          //_logger.d('추가되어야하는 카테고리: ${store.category}');
          storeList.add(store);
        }
      }

      if(storeList.isEmpty) {
        AppLog.to.d('검색 결과가 없습니다.');
        ToastController.to.showToast('검색 결과가 없습니다');
        isSearchLoading.value = false;
        return storeList;
      }

      await checkContainsStore();

      storeList.removeWhere((element) => foodCategory.contains(element.category));

      // sort by distance
      storeList.sort((a, b) => double.parse(a.distance ?? '0.0').compareTo(double.parse(b.distance ?? '0.0')));

      isSearchLoading.value = false;

      return storeList;


    } catch (e) {
      AppLog.to.e('fetchSearchPlace error: $e');
      return storeList;
      //GlobalToastto.showToast('검색 결과가 없습니다');
    }

  }

  /// 지도 내 네이버 플레이스 검색해서 마커 표출
  Future<void> checkContainsStore() async {
    containStoreList.clear();
    QuerySnapshot<Map<String, dynamic>> querySnapshot = await _fireStore.collection('stores').get();
    querySnapshot.docs.forEach((element) {
      var x = element.data()['x'];
      var y = element.data()['y'];
      var totalPoint = element.data()['storePoint'];
      //AppLog.to.d('x: $x, y: $y >> total point >> $totalPoint');
      containStoreList.add(MapModel(
        name: element.data()['storeName'],
        x: double.parse(x.toString()).toString(),
        y: double.parse(y.toString()).toString(),
        totalPoint: int.parse(totalPoint.toString()).toString(),
        isContain: true,
      ));
    });

    for (var i = 0; i < storeList.length; i++) {
      for (var j = 0; j < containStoreList.length; j++) {
        if(storeList[i].name == containStoreList[j].name) {
          AppLog.to.d('storeList[i].name: ${storeList[i].name}, containStoreList[j].name: ${containStoreList[j].name}');
          storeList[i].isContain = true;
          storeList[i].totalPoint = containStoreList[j].totalPoint;
        } else {
          storeList[i].isContain = false;
          storeList[i].totalPoint = '0';
        }
      }
    }


    await setMarkers();

  }

  /// 마커 세팅
  Future<void> setMarkers() async {
    markers.clear();
    widgetMarkers.clear();

    for (var i = 0; i < storeList.length; i++) {
      await addMarker(LatLng(double.parse(storeList[i].y!), double.parse(storeList[i].x!)), storeList[i]);
    }

  }


  /// 미터를 킬로미터로 변환
  String convertKmToMeter(double meters) {
    // 1000m 이상이면 km로 변환
    var distance = meters.round();

    if (distance >= 1000) {
      return (distance / 1000).toStringAsFixed(1) + 'km';
    } else {
      return distance.toString() + 'm';
    }
  }

  /// 마커 클릭시 이벤트
  Future<void> onMarkerTapped(MapModel store) async {
    //AppLog.to.d('onMarkerTapped: ${store.name}');

    // get index
    selectIndex.value = storeList.indexWhere((element) => element.name == store.name);
    //AppLog.to.d('selectIndex: $selectIndex');

    scrollToIndex(selectIndex.value);

    scrollController.animateTo(
      Get.width * 0.75 * selectIndex.value,
      duration: Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );

    await mapController.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(double.parse(store.y!), double.parse(store.x!)),
          zoom: await mapController.getZoomLevel(),
        ),
      ),
    );
  }

  /// 이미지 리사이즈
  Uint8List? resizeImage(Uint8List data, width, height) {
    Uint8List? resizedData = data;
    IMG.Image? img = IMG.decodeImage(data);
    IMG.Image resized = IMG.copyResize(img!, width: width, height: height);
    resizedData = Uint8List.fromList(IMG.encodePng(resized));
    return resizedData;
  }

  /// 이미지 리사이즈
  Future<Uint8List?> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    Uint8List? bytes = data.buffer.asUint8List();
    return resizeImage(bytes, width, width);
  }

  /// 마커 정보창 보이기
  void showInfoWindow(String? x, String? y, String? name, String? address) {
    mapController.showMarkerInfoWindow(MarkerId('$name'));
  }

}
