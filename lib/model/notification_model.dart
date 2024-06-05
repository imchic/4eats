import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel {
  String? title;
  String? body;
  String? uid;
  String? userId;
  String? userName;
  String? userNickname;
  String? userPhotoUrl;
  String? senderId;
  String? receiverId;
  String? feedId;
  String? comment;
  String? type;
  String? deepLink;
  bool? isRead;
  DateTime? createdAt;

  NotificationModel({
    this.title,
    this.body,
    this.createdAt,
    this.uid,
    this.userId,
    this.userName,
    this.userNickname,
    this.userPhotoUrl,
    this.senderId,
    this.receiverId,
    this.feedId,
    this.comment,
    this.type,
    this.deepLink,
    this.isRead,
  });

  NotificationModel.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    body = json['body'];
    createdAt = json['createdAt'].toDate();
    uid = json['uid'];
    userId = json['userId'];
    userName = json['userName'];
    userNickname = json['userNickname'];
    userPhotoUrl = json['userPhotoUrl'];
    senderId = json['senderId'];
    receiverId = json['receiverId'];
    feedId = json['feedId'];
    comment = json['comment'];
    type = json['type'];
    deepLink = json['deepLink'];
    isRead = json['isRead'];
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
    data['senderId'] = senderId;
    data['receiverId'] = receiverId;
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