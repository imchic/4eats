import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class UserController extends GetxController {

  static UserController get to => Get.find();

  final _fireStore = FirebaseFirestore.instance;

  RxList<Map<String, dynamic>> getUserFeed = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

  /// 사용자의 피드 가져오기
  Future<List<Map<String, dynamic>>> fetchUsersFeed(String nickname) async {
    final querySnapshot = await _fireStore.collection('feeds').where('userNickname', isEqualTo: nickname).get();
    for (final query in querySnapshot.docs) {
      final user = query.data();
      getUserFeed.add(user);
    }
    return getUserFeed;
  }

}