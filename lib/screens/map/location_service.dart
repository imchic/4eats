import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:foreats/utils/logger.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:googleapis/admob/v1.dart';
import 'package:googleapis/drive/v2.dart';
import 'package:location/location.dart';

/// 위치 조회 서비스
class LocationService extends GetxService {
  static LocationService get to => Get.find();

  /// 디바이스 정보
  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

  /// 위치 정보 가져오기 데이터
  late LocationData locationData = LocationData.fromMap({
    'latitude': 37.566535,
    'longitude': 126.97796919999996,
  });

  /// 위치 정보
  late Location location = Location();

  /// 위치 정보 가져오기 성공 여부
  RxBool serviceEnabled = false.obs;

  /// 위치 정보 가져오기 권한 여부
  late PermissionStatus permissionGranted;

  /// 위치 정보 가져오기
  Future<LocationData> getLocation() async {
    try {
      serviceEnabled.value = await location.serviceEnabled();
      AppLog.to.d('serviceEnabled: $serviceEnabled');
      if (!serviceEnabled.value) {
        serviceEnabled.value = await location.requestService();
        if (!serviceEnabled.value) {
          return locationData;
        }
      }

      permissionGranted = await location.hasPermission();
      if (permissionGranted == PermissionStatus.denied) {
        permissionGranted = await location.requestPermission();
        if (permissionGranted != PermissionStatus.granted) {
          return locationData;
        }
      }
      AppLog.to.d('permissionGranted: $permissionGranted');

      await location.getLocation().then((value) {
        locationData = value;
        AppLog.to.d('locationData: $locationData');
      });

    } catch (e) {
      AppLog.to.e('getLocation error: $e');
    }

    return locationData;

  }

}