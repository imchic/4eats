import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

import '../../model/notification_model.dart';
import '../../utils/logger.dart';

class NotificationsController extends GetxController {
  final _fireStore = FirebaseFirestore.instance;

  // fetch
  Future<List<NotificationModel>?> fetchNotification() async {
    try {
      final snapshot = await _fireStore.collection('notifications').get();
      final data = snapshot.docs
          .map((e) => NotificationModel.fromJson(e.data()))
          .toList();
      return data;
    } catch (e) {
      AppLog.to.e('fetchNotification : ${e.toString()}');
      return null;
    }
  }
}
