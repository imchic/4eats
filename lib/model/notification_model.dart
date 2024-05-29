import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:googleapis/content/v2_1.dart';

class NotificationModel {
  final String? title;
  final String? body;
  final DateTime? createdAt;
  final String? uid;
  final String? userId;
  final String? userName;
  final String? userNickname;
  final String? userPhotoUrl;
  final String? feedId;
  final String? comment;
  final String? type;
  final String? deepLink;
  final bool? isRead;

  NotificationModel({
    this.title,
    this.body,
    this.createdAt,
    this.uid,
    this.userId,
    this.userName,
    this.userNickname,
    this.userPhotoUrl,
    this.feedId,
    this.comment,
    this.type,
    this.deepLink,
    this.isRead,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      title: json['title'],
      body: json['body'],
      createdAt: json['createdAt'],
      uid: json['uid'],
      userId: json['userId'],
      userName: json['userName'],
      userNickname: json['userNickname'],
      userPhotoUrl: json['userPhotoUrl'],
      feedId: json['feedId'],
      comment: json['comment'],
      type: json['type'],
      deepLink: json['deepLink'],
      isRead: json['isRead'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['title'] = title;
    data['body'] = body;
    data['createdAt'] = createdAt;
    data['uid'] = uid;
    data['userId'] = userId;
    data['userName'] = userName;
    data['userNickname'] = userNickname;
    data['userPhotoUrl'] = userPhotoUrl;
    data['feedId'] = feedId;
    data['comment'] = comment;
    data['type'] = type;
    data['deepLink'] = deepLink;
    data['isRead'] = isRead;
    return data;
  }

  @override
  String toString() {
    return toJson().toString().replaceAll(",", ",\n");
  }

}