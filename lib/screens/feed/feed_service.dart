import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';

import '../../model/feed_model.dart';
import 'feed_controller.dart';

class FeedService extends GetxService {
  static FeedService get to => Get.find();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;


  /// [getFeedList] returns a list of [FeedModel] from the Firestore database.
  Future<List<FeedModel>> getFeedList() async {
    final List<FeedModel> feedList = [];
    // snapshot
    final QuerySnapshot<Map<String, dynamic>> snapshot = await _firestore.collection('feeds').orderBy('createdAt', descending: true).get();
    // docs
    final List<QueryDocumentSnapshot<Map<String, dynamic>>> docs = snapshot.docs;
    // for each doc
    for (final QueryDocumentSnapshot<Map<String, dynamic>> doc in docs) {
      final Map<String, dynamic> data = doc.data();
      final FeedModel feed = FeedModel.fromJson(data);
      feedList.add(feed);
    }
    return feedList;
  }


}
