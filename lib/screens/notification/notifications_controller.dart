import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:foreats/screens/login/user_store.dart';
import 'package:get/get.dart';

import '../../model/notification_model.dart';
import '../../utils/logger.dart';

class NotificationsController extends GetxController {
  final _fireStore = FirebaseFirestore.instance;

  // fetch
  Future<List<NotificationModel>?> fetchNotification() async {
    try {

      // AppLog.to.i('UserStore.to.user.value.uid: ${UserStore.to.user.value.nickname}');

      // final feedSnapshot = await _fireStore.collection('feeds')
      //     .where('uid', isEqualTo: UserStore.to.user.value.uid)
      //     // .where('userNickname', isEqualTo: UserStore.to.user.value.nickname)
      //     .get();

      // feedSnapshot.docs.forEach((element) {
      //   // get feed id
      //   final feedId = element.id;
      //   AppLog.to.i('feedId: $feedId');
      //
      //   final notiSnapshot = _fireStore.collection('notifications')
      //       // .where('feedId', isEqualTo: feedId)
      //       .get();
      // });

      final snapshot = await _fireStore.collection('notifications')
          .where('receiverId', isEqualTo: UserStore.to.user.value.id)
          //.orderBy('createdAt', descending: true)
          .get();
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
