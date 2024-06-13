import 'package:foreats/screens/notification/notifications_controller.dart';
import 'package:foreats/utils/logger.dart';
import 'package:get/get.dart';

import '../screens/biz/biz_controller.dart';
import '../screens/feed/feed_controller.dart';
import '../screens/feed/feed_service.dart';
import '../screens/history/history_controller.dart';
import '../screens/login/login_controller.dart';
import '../screens/login/user_store.dart';
import '../screens/lounge/lounge_controller.dart';
import '../screens/map/location_service.dart';
import '../screens/map/map_controller.dart';
import '../screens/mypage/mypage_controller.dart';
import '../screens/upload/upload_controller.dart';
import '../utils/toast_controller.dart';
import 'home_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AppLog>(() => AppLog());
    Get.lazyPut<HomeController>(() => HomeController());
    Get.lazyPut<LoginController>(() => LoginController());
    Get.lazyPut<FeedController>(() => FeedController());
    Get.lazyPut<FeedService>(() => FeedService());
    Get.lazyPut<LoungeController>(() => LoungeController());
    Get.lazyPut<UploadController>(() => UploadController());
    Get.lazyPut<HistoryController>(() => HistoryController());
    Get.lazyPut<UserStore>(() => UserStore());
    Get.lazyPut<MyPageController>(() => MyPageController());
    Get.lazyPut<MapController>(() => MapController());
    Get.lazyPut<LocationService>(() => LocationService());
    Get.lazyPut<ToastController>(() => ToastController());
    Get.lazyPut<BizController>(() => BizController());
    Get.lazyPut<NotificationsController>(() => NotificationsController());
  }
}