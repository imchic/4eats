import 'package:foreats/screens/store/store_controller.dart';
import 'package:foreats/utils/logger.dart';
import 'package:get/get.dart';

class StoreBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<StoreController>(() => StoreController());
    Get.lazyPut(() => AppLog());
  }
}