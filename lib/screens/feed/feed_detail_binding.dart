import 'package:get/get.dart';

import 'feed_detail_controller.dart';

class FeedDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<FeedDetailController>(() => FeedDetailController());
  }
}