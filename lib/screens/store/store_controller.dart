import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

import '../../model/store_model.dart';

class StoreController extends GetxController {

  static StoreController get to => Get.find();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  RxList<StoreModel> storeList = <StoreModel>[].obs;

  @override
  void onInit() {
    super.onInit();
  }

  /// Firestore에서 가게 정보를 가져온다.
  Future<List<Map<String, dynamic>>> fetchStores(String storename) async {
    QuerySnapshot<Map<String, dynamic>> querySnapshot = await _firestore.collection('stores').where('storeName', isEqualTo: storename).get();
    return querySnapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
  }

}