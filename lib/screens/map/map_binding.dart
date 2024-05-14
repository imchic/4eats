import 'package:get/get.dart';

import '../../utils/global_toast_controller.dart';
import 'location_service.dart';
import 'map_controller.dart';

class MapBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MapController>(() => MapController());
    Get.lazyPut<LocationService>(() => LocationService());
    Get.lazyPut(() => GlobalToastController());
  }
}