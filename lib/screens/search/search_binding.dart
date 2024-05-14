import 'package:foreats/screens/search/search_keyword_controller.dart';
import 'package:get/get.dart';

class SearchBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SearchKeywordController>(() => SearchKeywordController());
  }
}