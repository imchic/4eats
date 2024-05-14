import 'package:get/get.dart';

class StoreController extends GetxController {

  static StoreController get to => Get.find();

  // final StoreRepository repository;
  // StoreController({required this.repository}) : assert(repository != null);
  //
  // final _storeList = <Store>[].obs;
  // get storeList => this._storeList;
  // set storeList(value) => this._storeList.value = value;
  //
  // @override
  // void onInit() {
  //   fetchStoreList();
  //   super.onInit();
  // }
  //
  // void fetchStoreList() async {
  //   final result = await repository.fetchStoreList();
  //   if (result != null) {
  //     storeList = result;
  //   }
  // }
}