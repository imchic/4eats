import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:logger/logger.dart';
import 'package:dio/dio.dart' as dio;

import '../../model/map_model.dart';
import 'location_service.dart';

import 'package:image/image.dart' as IMG;

class MapController extends GetxController {
  static MapController get to => Get.find();

  late GoogleMapController mapController;
  late TextEditingController searchController;

  final Logger _logger = Logger(
    filter: null, // Use the default LogFilter (-> only log in debug mode)
    printer: PrettyPrinter(
      methodCount: 2,
      // number of method calls to be displayed
      errorMethodCount: 8,
      // number of method calls if stacktrace is provided
      lineLength: 120,
      // width of the output
      colors: true,
      // Colorful log messages
      printEmojis: true,
      // Print an emoji for each log message
      printTime: false, // Should each log print contain a timestamp
    ),
    output: null, // Use the default LogOutput (-> send everything to console)
  );

  final RxList<MapModel> storeList = <MapModel>[].obs;
  final RxList<Marker> markers = <Marker>[].obs;

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

  @override
  Future<void> onInit() async {
    super.onInit();
    searchController = TextEditingController();
    await getCurrentLocation(
      Get.arguments['lonlat']
    );
    scrollController.addListener(() async {

      // 스크롤 처음
      // if (scrollController.position.pixels == 0) {
      //   _logger.d('스크롤 처음');
      //   if(page.value > 1) {
      //     page.value--;
      //     await fetchSearchPlace(searchPlace.value, page: page.value);
      //   } else {
      //     _logger.d('첫 페이지입니다.');
      //   }
      // }

      // 스크롤 끝
      // if (scrollController.position.pixels ==
      //     scrollController.position.maxScrollExtent) {
      //   _logger.d('스크롤 끝');
      //   page.value++;
      //   await fetchSearchPlace(searchPlace.value, page: page.value);
      // }

    });
  }

  @override
  void dispose() {
    super.dispose();
    searchController.dispose();
    storeList.clear();
    markers.clear();
  }

  void scrollToIndex(int index) {
    scrollController.jumpTo(index * 150.0);
  }

  Future<void> onMapCreated(GoogleMapController controller) async {
    mapController = controller;
    isMapLoading = false;
    Future.delayed(Duration(milliseconds: 500), () {
      mapController.showMarkerInfoWindow(MarkerId('currentLocation'));
    });
  }

  Future<void> onCameraMove(CameraPosition position) async {
    currentLocation.value = position.target;
  }

  Future<void> onCameraIdle() async {
    // _logger.d('onCameraIdle: ${currentLocation.value}');
    await convertLatLngToAddress(currentLocation.value);
  }

  Future<void> onCameraMoveStarted() async {
    searchController.clear();
    searchPlace.value = '';
    searchAddress.value = '';
    storeCategory.value = '';
    storeMenuInfo.value = '';
    storeContext.value = '';
    _logger.d('onCameraMoveStarted');
  }

  Future<void> onSearchPlace() async {
    _logger.d('onSearchPlace: ${searchController.text}');
    searchPlace.value = searchController.text;
    page.value = 1;
    await fetchSearchPlace(searchPlace.value, page: page.value);
  }

  /// 현재 위치 값 구하기
  Future<void> getCurrentLocation(argument) async {

    await LocationService.to.getLocation();
    currentLocation.value = LatLng(argument[0], argument[1]);

    addMarker(currentLocation.value, null);

    isMapLoading = false;
    await convertLatLngToAddress(currentLocation.value);
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
  Future<void> addMarker(LatLng latLng, MapModel? model) async {
    _logger.d('addMarker: $latLng');

    final Uint8List? markerIcon = await getBytesFromAsset('assets/images/ic_food.png', 130);

    markers.add(
      Marker(
        markerId: MarkerId('currentLocation'),
        position: latLng,
        icon: BitmapDescriptor.fromBytes(markerIcon!),
        infoWindow: InfoWindow(
          title: model == null ? '현재 위치' : model.name,
          //snippet: model == null ? '가게주소' : model.address,
          onTap: () {
            _logger.d('current location marker infoWindow tapped');
          }
        ),
        onTap: () {
          _logger.d('current location marker tapped');
        },
      ),
    );

  }

  /// 주소 변환 (위경도 -> 주소)
  convertLatLngToAddress(LatLng latLng) async {
    var lat = currentLocation.value.latitude.toString();
    var lng = currentLocation.value.longitude.toString();

    var reverseGeocodingUri = Uri.parse(
        'https://naveropenapi.apigw.ntruss.com/map-reversegeocode/v2/gc'
        '?request=coordsToaddr'
        '&coords=$lng,$lat'
        '&sourcecrs=epsg:4326'
        '&output=json'
        '&orders=roadaddr');

    //_logger.d('reverseGeocodingUri: $reverseGeocodingUri');

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
      _logger.d('주소가 없습니다.');
      return;
    }

    var sido = response.data['results'][0]['region']['area1']['name'];
    var sigungu = response.data['results'][0]['region']['area2']['name'];
    var dong = response.data['results'][0]['region']['area3']['name'];
    var land = response.data['results'][0]['land']['number1'];
    var ho = response.data['results'][0]['land']['number2'];

    searchAddress.value = '$sido $sigungu $dong $land $ho';
    //_logger.d('searchAddress: $searchAddress');
  }

  /// 지도 내 네이버 플레이스 검색해서 마커 표출
  /// value: 검색어
  /// page: 페이지
  Future<void> fetchSearchPlace(String value, {required page}) async {

    try {

      if(value.isEmpty) {
        _logger.d('검색어가 없습니다.');
        return;
      }

      isSearchLoading.value = true;

      markers.clear();
      storeList.clear();

      LatLng latLng = currentLocation.value;

      var searchPlaceUrl =
              'https://map.naver.com/p/api/search/allSearch?query=${searchPlace.value}&type=food&searchCoord=${latLng.longitude};${latLng.latitude}&page=$page&displayCount=50&isPlaceRecommendationReplace=true&lang=ko';

      _logger.d('네이버 플레이스 검색: $searchPlaceUrl');

      dio.Response response = await dio.Dio().get(searchPlaceUrl).timeout(
            const Duration(seconds: 5),
            onTimeout: () {
              _logger.d('timeout');
              isSearchLoading.value = false;
              return dio.Response(requestOptions: dio.RequestOptions(path: ''));
            },
          );

      var searchResultItem = response.data['result']['place']['list'];
      _logger.d('네이버 플레이스 검색결과: $searchResultItem');

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

        // _logger.d('contextList: $contextList');

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
        );

        if (!foodCategory.contains(store.category?.split(', ').first) ||
            store.category == null) {
          _logger.w('추가되지 않아야하는 카테고리: ${store.category}');
        } else {
          //_logger.d('추가되어야하는 카테고리: ${store.category}');
          storeList.add(store);
        }
      }

      if(storeList.isEmpty) {
        _logger.d('검색 결과가 없습니다.');
        isSearchLoading.value = false;
        return;
      }

      storeList.removeWhere((element) => foodCategory.contains(element.category));

      // sort by distance
      storeList.sort((a, b) => double.parse(a.distance ?? '0.0').compareTo(double.parse(b.distance ?? '0.0')));

      final Uint8List? markerIcon = await getBytesFromAsset('assets/images/ic_food.png', 130);

      markers.clear();

      // 마커 추가
      for (var i = 0; i < storeList.length; i++) {
        Marker marker = Marker(
          markerId: MarkerId(storeList[i].name!),
          position: LatLng(double.parse(storeList[i].y!), double.parse(storeList[i].x!)),
          icon: BitmapDescriptor.fromBytes(markerIcon!),
          infoWindow: InfoWindow(
            title: storeList[i].name!,
            snippet: storeList[i].address!,
            onTap: () {
              onMarkerTapped(storeList[i]);
            },
          ),
          onTap: () {
            onMarkerTapped(storeList[i]);
          },
        );
        markers.add(marker);
      }

      isSearchLoading.value = false;

    } catch (e) {
      _logger.e('fetchSearchPlace error: $e');
      //GlobalToastController.to.showToast('검색 결과가 없습니다');
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
    _logger.d('onMarkerTapped: ${store.name}');

    // get index
    selectIndex.value = storeList.indexWhere((element) => element.name == store.name);
    _logger.d('selectIndex: $selectIndex');

    //scrollToIndex(selectIndex.value);

    scrollController.animateTo(
      Get.width * 0.75 * selectIndex.value,
      duration: Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );

    await mapController.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(double.parse(store.y!), double.parse(store.x!)),
          zoom: 15,
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

  Future<Uint8List?> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    Uint8List? bytes = data.buffer.asUint8List();
    return resizeImage(bytes, width, width);
  }

  void showInfoWindow(String? x, String? y, String? name, String? address) {
    mapController.showMarkerInfoWindow(MarkerId(name!));
  }

}
